import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParameterContainer, checkPrerequirements, getClubComponent, saveStatistic} from "../utils";

/**
 * @summary
 * Changes payement state of fine with given fine id.
 *
 * Saved statistik:
 *  - name: changeFinePayed
 *  - properties:
 *      - fineId (string): id of the fine with changed payed state
 *      - state (string): state of the payment of the fine (`payed`, `settled`, `unpayed`)
 *      - payDate (number | null): pay date of the fine (provided if state is `payed`)
 *      - inApp (boolean | null): indicates if the fine is payed in app (provided if state is `payed`)
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - clubId (string): id of the club to change the fine
 *  - fineId (string): id of the fine to change the payed state
 *  - state (string): state of the payment of the fine (`payed`, `settled`, `unpayed`)
 *  - payDate (number | null): pay date of the fine (has to be provided if state is `payed`)
 *  - inApp (boolean | null): indicates if the fine is payed in app (has to be provided if state is `payed`)
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *                        or if a parameter hasn't the right type
 *                        or if clubLevel isn't `regular`, `debug` or `testing`
 *                        or if state isn't `payed`, `settled` or `unpayed`
 *    - internal: if couldn't change payed state in database
 */
export const changeFinePayedCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to payed state of the fine
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth);
    const clubPath = getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter<string>("clubId", "string").toUpperCase();
    const path = clubPath + "/fines/" + parameterContainer.getParameter<string>("fineId", "string").toUpperCase() + "/payed";
    const ref = admin.database().ref(path);

    // Get payed state
    const state = parameterContainer.getParameter<string>("state", "string");
    let payed = null;
    if (state == "payed") {
        payed = {
            state: state,
            payDate: parameterContainer.getParameter<number>("payDate", "number"),
            inApp: parameterContainer.getParameter<boolean>("inApp", "boolean"),
        };
    } else if (state == "settled" || state == "unpayed") {
        payed = {state: state};
    } else {
        throw new functions.https.HttpsError("invalid-argument", "Argument state is invalid \"" + state + "\"");
    }

    // Set payed state
    let errorOccured = false;
    await ref.set(payed, (error) => {
        errorOccured = error != null;
    });
    if (errorOccured) {
        throw new functions.https.HttpsError( "internal", "Couldn't update payed state." );
    }

    // Save statistic
    await saveStatistic(clubPath, {
        name: "changeFinePayed",
        properties: {
            ...payed,
            fineId: parameterContainer.getParameter<string>("fineId", "string").toUpperCase(),
        },
    });
});
