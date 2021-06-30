import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParameterContainer, checkPrerequirements, getClubComponent, saveStatistic, Result, FailureResult, SuccessResult} from "../utils";
import {Fine, FineReasonCustom, FineReasonTemplate, PayedState, Person, StatisticsFine, StatisticsFineReason} from "../typeDefinitions";

/**
 * @summary
 * Changes payement state of fine with given fine id.
 *
 * Saved statistik:
 *  - name: changeFinePayed
 *  - properties:
 *      - previousFine ({@link StatisticsFine}}): fine before the change
 *      - changedState ({@link PayedState}): payed state after the change
 *
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - clubId (string): id of the club to change the fine
 *  - fineId (string): id of the fine to change the payed state
 *  - state (string): state of the payment of the fine (`payed`, `settled`, `unpayed`)
 *  - payDate (number | null): pay date of the fine (has to be provided if state is `payed`)
 *  - inApp (boolean | null): indicates if the fine is payed in app (has to be provided if state is `payed`)
 *
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *      or if a parameter hasn't the right type
 *      or if clubLevel isn't `regular`, `debug` or `testing`
 *      or if state isn't `payed`, `settled` or `unpayed`
 *    - internal: if couldn't change payed state in database
 *      or if reason with reason template id doesn't exist
 *    - failed-precondition: if there is no fine with payed state to update
 */
export const changeFinePayedCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to payed state of the fine
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth);
    const clubPath = `${getClubComponent(parameterContainer)}/${parameterContainer.getParameter<string>("clubId", "string").toUpperCase()}`;

    // Get statistics fine
    const statisticsFine = (await getStatisticsFineResult(clubPath, parameterContainer.getParameter<string>("fineId", "string").toUpperCase())).get();

    // Get payed state
    const state = parameterContainer.getParameter<string>("state", "string");
    let payed: PayedState;
    if (state == "payed") {
        payed = {
            state: "payed",
            payDate: parameterContainer.getParameter<number>("payDate", "number"),
            inApp: parameterContainer.getParameter<boolean>("inApp", "boolean"),
        };
    } else if (state == "settled" || state == "unpayed") {
        payed = {state: state};
    } else {
        throw new functions.https.HttpsError("invalid-argument", `Argument state is invalid "${state}"`);
    }

    // Set payed state
    const payedRef = admin.database().ref(`${clubPath}/fines/${parameterContainer.getParameter<string>("fineId", "string").toUpperCase()}/payed`);
    let errorOccured = false;
    await payedRef.set(payed, (error) => {
        errorOccured = error != null;
    });
    if (errorOccured) {
        throw new functions.https.HttpsError("internal", "Couldn't update payed state.");
    }

    // Save statistic
    await saveStatistic(clubPath, {
        name: "changeFinePayed",
        properties: {
            previousFine: statisticsFine,
            changedState: payed,
        },
    });
});

async function getStatisticsFineResult(clubPath: string, fineId: string): Promise<Result<StatisticsFine, functions.https.HttpsError>> {
    // Get previous payed state
    const finePath = `${clubPath}/fines/${fineId}`;
    const fineRef = admin.database().ref(finePath);
    const payedSnapshot = await fineRef.once("value");
    if (!payedSnapshot.exists()) {
        return new FailureResult(new functions.https.HttpsError("failed-precondition", "No fine payed state to change."));
    }
    const previousFine: Fine = payedSnapshot.val();

    // Set person of previous fine
    const personRef = admin.database().ref(`${clubPath}/persons/${previousFine.personId.toUpperCase()}`);
    const personSnapshot = await personRef.once("value");
    if (!personSnapshot.exists || personSnapshot.key == null) {
        return new FailureResult(new functions.https.HttpsError("internal", "Couldn't get person for previous fine."));
    }
    const person: Person = {
        id: personSnapshot.key,
        name: personSnapshot.child("name").val(),
    };

    // Set reason of previous fine if fine has template id
    let fineReason: StatisticsFineReason = previousFine.reason as FineReasonCustom;
    const templateId = (previousFine.reason as FineReasonTemplate).templateId;
    if (templateId != null) {
        const reasonRef = admin.database().ref(`${clubPath}/reasons/${templateId.toUpperCase()}`);
        const reasonSnapshot = await reasonRef.once("value");
        if (!reasonSnapshot.exists()) {
            return new FailureResult(new functions.https.HttpsError("internal", "Couldn't get reason for previous fine."));
        }
        fineReason = {
            ...reasonSnapshot.val(),
            id: templateId,
        };
    }

    // Get statistics fine
    return new SuccessResult({
        id: fineId,
        person: person,
        payed: previousFine.payed,
        number: previousFine.number,
        date: previousFine.date,
        reason: fineReason,
    });
}
