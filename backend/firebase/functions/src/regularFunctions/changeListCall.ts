/* eslint-disable @typescript-eslint/ban-types */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParameterContainer, checkPrerequirements, getClubComponent, existsData, saveStatistic, Result, SuccessResult, FailureResult} from "../utils";
import {Person, StatisticsFine, ReasonTemplate, StatisticsTransaction, FineProperties, TransactionProperties, ReasonTemplateProperties, PayedState, FineReasonTemplate, FineReasonCustom, PersonProperties, StatisticsFineReason} from "../typeDefinitions";

/**
 * @summary
 * Changes a element of person, fine or reason list.
 *
 * Saved statistik:
 *  - name: changeList
 *  - properties:
 *      - listType (string): type of the list to change (`person`, `fine`, `reason`, `transaction`)
 *      - previousItem ({@link Person} | {@link StatisticsFine} | {@link ReasonTemplate} | {@link StatisticsTransaction} | null): Previous item to change
 *      - changedItem ({@link Person} | {@link StatisticsFine} | {@link ReasonTemplate} | {@link StatisticsTransaction} | { id: string; }}): Changed item or only id if change type is `delete`
 *
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - clubId (string): id of the club to force sign out the person
 *  - listType (string): type of the list to change (`person`, `fine`, `reason`, `transaction`)
 *  - itemId (string): id of the item to change
 *  - changeType (string): type of the change (`update`, `delete`)
 *  - for person update:
 *    - firstName (string): first name of the person to update
 *    - lastName (string | null): last name of the person to update
 *  - for fine update:
 *    - personId (string): person id of the fine to update
 *    - number (number): number of the fine to update
 *    - date (number): date of the fine to update
 *    - payedState (string): state of the payment of the fine to update (`payed`, `settled`, `unpayed`)
 *    - payedPayDate (number | null): pay date of the fine to update (has to be provided if payedState is `payed`)
 *    - payedInApp (boolean | null): indicates if the fine to update is payed in app (has to be provided if payedState is `payed`)
 *    - templateId (string | null): id of associated reason template of the fine to update (templateId or reason, amount and importanse has to be provided)
 *    - reason (string | null): reason of the fine to update (templateId or reason, amount and importanse has to be provided)
 *    - amount (number | null): amount of the fine to update (templateId or reason, amount and importanse has to be provided)
 *    - importance (string | null): importance of the fine to update (`high`, `medium`, `low`) (templateId or reason, amount and importanse has to be provided)
 *  - for reason update:
 *    - reason (string): reason of the reason to update
 *    - amount (number): amount of the reason to update
 *    - importance (string): importance of the reason to update (`high`, `medium`, `low`)
 *  - for transaction update:
 *    - approved (boolean): indicates whether the transaction is approved
 *    - fineIds (string[]): ids of fines payed with the transaction
 *    - firstName (string | null): first name of the person who payed the transaction
 *    - lastName (string | null): last name of the person who payed the transaction
 *    - payDate (number): date of payment
 *    - personId (string): id of the person who payed the transaction
 *    - payoutId (string | null): id of payout
 *
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *      or if a parameter hasn't the right type
 *      or if clubLevel isn't `regular`, `debug` or `testing`
 *      or if list type isn't `person`, `fine` or `reason`
 *      or if change type isn't `update` or `delete`
 *      or if change type is `update` and list type is `fine` and the fine has no valid reason
 *      or if change type is `update`and list type is `fine` and payed state isn't `payed`, `settled` or `unpayed`
 *    - unavailable: if change is deletion of an already signed in person
 *    - internal: if couldn't change item in database
 */
export const changeListCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to the item to change
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth);
    const clubPath = `${getClubComponent(parameterContainer)}/${parameterContainer.getParameter<string>("clubId", "string").toUpperCase()}`;

    // Get previous item
    const itemRef = admin.database().ref(`${clubPath}/${parameterContainer.getParameter<string>("listType", "string")}s/${parameterContainer.getParameter<string>("itemId", "string").toUpperCase()}`);
    const itemSnapshot = await itemRef.once("value");
    let previousItem: Person | StatisticsFine | ReasonTemplate | StatisticsTransaction | null = null;
    if (itemSnapshot.exists()) {
        previousItem = (await getStatisticsItem(clubPath, parameterContainer, itemSnapshot.val())).get();
    }

    // Change item
    const changeType = parameterContainer.getParameter<string>("changeType", "string");
    let changedItem: Person | StatisticsFine | ReasonTemplate | StatisticsTransaction | { id: string; };
    switch (changeType) {
    case "delete": // Delete list item
        const result = await deleteItem(clubPath, parameterContainer);
        if (result[0] != null) {
            throw result[0];
        }
        if (!result[1]) {
            return;
        }
        changedItem = {id: parameterContainer.getParameter<string>("itemId", "string").toUpperCase()};
        break;

    case "update": // Set / update list item
        const item = (await updateItem(clubPath, parameterContainer)).get();
        changedItem = (await getStatisticsItem(clubPath, parameterContainer, item)).get();
        break;

    // Throw error if change type is invalid
    default:
        throw new functions.https.HttpsError("invalid-argument", `Argument changeType is invalid "${changeType}"`);
    }

    // Save statistic
    await saveStatistic(clubPath, {
        name: "changeList",
        properties: {
            listType: parameterContainer.getParameter<string>("listType", "string"),
            previousItem: previousItem,
            changedItem: changedItem,
        },
    });
});

async function deleteItem(clubPath: string, parameterContainer: ParameterContainer): Promise<[functions.https.HttpsError | null, boolean]> { // Seconde boolean value indicates if a item was deleted (`true`) or if item didn't already exists (`false`)
    const itemRef = admin.database().ref(`${clubPath}/${parameterContainer.getParameter<string>("listType", "string")}s/${parameterContainer.getParameter<string>("itemId", "string").toUpperCase()}`);

    // Check if list type is invalid
    const listType = parameterContainer.getParameter<string>("listType", "string");
    if (listType != "person" && listType != "fine" && listType != "reason" && listType != "transaction") {
        return [new functions.https.HttpsError("invalid-argument", `Argument listType is invalid "${listType}"`), true];
    }

    // Check if person to delete is already signed in
    if (listType == "person" && await existsData(itemRef.child("signInData"))) {
        return [new functions.https.HttpsError("unavailable", "Person is already signed in!"), true];
    }

    // Delete item
    let errorOccured = false;
    if (await existsData(itemRef)) {
        await itemRef.remove((error) => {
            errorOccured = error != null;
        });
    } else {
        return [null, false];
    }
    if (errorOccured) {
        return [new functions.https.HttpsError("internal", "Couldn't delete item."), true];
    }
    return [null, true];
}

async function updateItem(clubPath: string, parameterContainer: ParameterContainer): Promise<Result<PersonProperties | FineProperties | ReasonTemplateProperties | TransactionProperties, functions.https.HttpsError>> {
    const itemRef = admin.database().ref(`${clubPath}/${parameterContainer.getParameter<string>("listType", "string")}s/${parameterContainer.getParameter<string>("itemId", "string").toUpperCase()}`);
    const itemResult = await decodeItem(clubPath, parameterContainer);
    const item = itemResult.getValue();
    let errorOccured = false;
    if (item != null) {
        await itemRef.set(item, (error) => {
            errorOccured = error != null;
        });
    }
    if (errorOccured) {
        return new FailureResult(new functions.https.HttpsError("internal", "Couldn't update item."));
    }
    return itemResult;
}

/**
 * Returns decoded item of parameter container according to list type for saving to database
 * @param {string} clubPath path to club in database
 * @param {ParameterContainer} parameterContainer container with all parameters
 * @return {Promise<Result<PersonProperties | FineProperties | ReasonTemplateProperties | TransactionProperties, functions.https.HttpsError>>} Result of decoded item or an error if decoding isn't possible
 */
async function decodeItem(clubPath: string, parameterContainer: ParameterContainer): Promise<Result<PersonProperties | FineProperties | ReasonTemplateProperties | TransactionProperties, functions.https.HttpsError>> {
    const listType = parameterContainer.getParameter<string>("listType", "string");
    switch (listType) {
    case "person": // Decode person
        return await decodePerson(clubPath, parameterContainer);
    case "fine": // Decode fine
        return decodeFine(parameterContainer);
    case "reason": // Decode reason
        return decodeReason(parameterContainer);
    case "tranaction": // Decode transaction
        return decodeTransaction(parameterContainer);
    default: // Throw error if change type is invalid
        return new FailureResult(new functions.https.HttpsError("invalid-argument", `Argument listType is invalid "${listType}"`));
    }
}

async function decodePerson(clubPath: string, parameterContainer: ParameterContainer): Promise<Result<PersonProperties, functions.https.HttpsError>> {
    // Get sign in data
    const signInDataRef = admin.database().ref(`${clubPath}/${parameterContainer.getParameter<string>("listType", "string")}s/${parameterContainer.getParameter<string>("itemId", "string").toUpperCase()}/signInData`);
    const signInDataSnapshot = await signInDataRef.once("value");
    let signInData: {
        cashier: boolean;
        userId: string;
        signInDate: number;
    } | null = null;
    if (signInDataSnapshot.exists()) {
        signInData = signInDataSnapshot.val();
    }

    // Return person
    return new SuccessResult({
        name: {
            first: parameterContainer.getParameter<string>("firstName", "string"),
            last: parameterContainer.getOptionalParameter<string>("lastName", "string"),
        },
        signInData: signInData,
    });
}

function decodeFine(parameterContainer: ParameterContainer): Result<FineProperties, functions.https.HttpsError> {
    // Get fine reason
    const templateId = parameterContainer.getOptionalParameter<string>("templateId", "string");
    const reason = parameterContainer.getOptionalParameter<string>("reason", "string");
    const amount = parameterContainer.getOptionalParameter<number>("amount", "number");
    const importance = parameterContainer.getOptionalParameter<string>("importance", "string");
    let reasonTemplate: FineReasonTemplate | FineReasonCustom;
    if (templateId != null) {
        reasonTemplate = {
            templateId: templateId,
        };
    } else if (reason != null && amount != null && importance != null) {
        if (importance != "high" && importance != "medium" && importance != "low") {
            return new FailureResult(new functions.https.HttpsError("invalid-argument", `Argument importance is invalid "${importance}"`));
        }
        reasonTemplate = {
            reason: reason,
            amount: amount,
            importance: importance,
        };
    } else {
        return new FailureResult(new functions.https.HttpsError("invalid-argument", "Fine has no valid reason."));
    }

    // Get payed state
    const payedState = parameterContainer.getParameter<string>("payedState", "string");
    let payed: PayedState;
    if (payedState == "payed") {
        payed = {
            state: "payed",
            payDate: parameterContainer.getParameter<number>("payedPayDate", "number"),
            inApp: parameterContainer.getParameter<boolean>("payedInApp", "boolean"),
        };
    } else if (payedState == "settled" || payedState == "unpayed") {
        payed = {state: payedState};
    } else {
        return new FailureResult(new functions.https.HttpsError("invalid-argument", `Argument state is invalid "${payedState}"`));
    }

    // Return fine
    return new SuccessResult({
        personId: parameterContainer.getParameter<string>("personId", "string"),
        payed: payed,
        number: parameterContainer.getParameter<number>("number", "number"),
        date: parameterContainer.getParameter<number>("date", "number"),
        reason: reasonTemplate,
    });
}

function decodeReason(parameterContainer: ParameterContainer): Result<ReasonTemplateProperties, functions.https.HttpsError> {
    const importance = parameterContainer.getParameter<string>("importance", "string");
    if (importance != "high" && importance != "medium" && importance != "low") {
        return new FailureResult(new functions.https.HttpsError("invalid-argument", `Argument importance is invalid "${importance}"`));
    }
    return new SuccessResult({
        reason: parameterContainer.getParameter<string>("reason", "string"),
        amount: parameterContainer.getParameter<number>("amount", "number"),
        importance: importance,
    });
}

function decodeTransaction(parameterContainer: ParameterContainer): Result<TransactionProperties, functions.https.HttpsError> {
    return new SuccessResult({
        approved: parameterContainer.getParameter<boolean>("approved", "boolean"),
        fineIds: parameterContainer.getParameter<object>("fineIds", "object") as string[],
        name: {
            first: parameterContainer.getOptionalParameter<string>("firstName", "string"),
            last: parameterContainer.getOptionalParameter<string>("lastName", "string"),
        },
        payDate: parameterContainer.getParameter<number>("payDate", "number"),
        personId: parameterContainer.getParameter<string>("payDate", "string"),
        payoutId: parameterContainer.getOptionalParameter<string>("payoutId", "string"),
    });
}

async function getStatisticsItem(clubPath: string, parameterContainer: ParameterContainer, item: PersonProperties | FineProperties | ReasonTemplateProperties | TransactionProperties): Promise<Result<Person | StatisticsFine | ReasonTemplate | StatisticsTransaction, functions.https.HttpsError>> {
    const listType = parameterContainer.getParameter<string>("listType", "string");
    switch (listType) {
    case "person":
        return new SuccessResult({
            id: parameterContainer.getParameter<string>("itemId", "string"),
            name: (item as PersonProperties).name,
        });

    case "fine":
        return await getStatisticsFine(clubPath, item as FineProperties, parameterContainer.getParameter<string>("itemId", "string"));

    case "reason":
        return new SuccessResult({
            id: parameterContainer.getParameter<string>("itemId", "string"),
            ...(item as ReasonTemplateProperties),
        });

    case "tranaction":

        // Get person for transaction
        const personRef = admin.database().ref(`${clubPath}/persons/${(item as TransactionProperties).personId.toUpperCase()}`);
        const personSnapshot = await personRef.once("value");
        if (!personSnapshot.exists || personSnapshot.key == null) {
            return new FailureResult(new functions.https.HttpsError("internal", "Couldn't get person for previous fine."));
        }
        const person: Person = {
            id: personSnapshot.key,
            name: personSnapshot.child("name").val(),
        };

        // Get fines for transaction
        const fineList: StatisticsFine[] = [];
        for (const fineId of (item as TransactionProperties).fineIds) {
            const fineRef = admin.database().ref(`${clubPath}/fines/${fineId.toUpperCase()}`);
            const fineSnapshot = await fineRef.once("value");
            if (!fineSnapshot.exists()) {
                return new FailureResult(new functions.https.HttpsError("internal", "Couldn't get fine for statistics transaction."));
            }
            try {
                fineList.push((await getStatisticsFine(clubPath, fineSnapshot.val(), fineId)).get());
            } catch (error) {
                return new FailureResult(error);
            }
        }

        // Return statistics transaction
        return new SuccessResult({
            id: parameterContainer.getParameter<string>("itemId", "string"),
            approved: (item as TransactionProperties).approved,
            fines: fineList,
            name: (item as TransactionProperties).name,
            payDate: (item as TransactionProperties).payDate,
            person: person,
        });

    default:
        return new FailureResult(new functions.https.HttpsError("invalid-argument", `Argument listType is invalid "${listType}"`));
    }
}

async function getStatisticsFine(clubPath: string, fine: FineProperties, id: string): Promise<Result<StatisticsFine, functions.https.HttpsError>> {
    // Get person for fine
    const personRef1 = admin.database().ref(`${clubPath}/persons/${fine.personId.toUpperCase()}`);
    const personSnapshot1 = await personRef1.once("value");
    if (!personSnapshot1.exists || personSnapshot1.key == null) {
        return new FailureResult(new functions.https.HttpsError("internal", "Couldn't get person for statistics fine."));
    }
    const person1: Person = {
        id: personSnapshot1.key,
        name: personSnapshot1.child("name").val(),
    };

    // Get reason for fine if fine has template id
    let fineReason: StatisticsFineReason = fine.reason as FineReasonCustom;
    const templateId = (fine.reason as FineReasonTemplate).templateId;
    if (templateId != null) {
        const reasonRef = admin.database().ref(`${clubPath}/reasons/${templateId.toUpperCase()}`);
        const reasonSnapshot = await reasonRef.once("value");
        if (!reasonSnapshot.exists()) {
            return new FailureResult(new functions.https.HttpsError("internal", "Couldn't get reason for statistics fine."));
        }
        fineReason = {
            ...reasonSnapshot.val(),
            id: templateId,
        };
    }

    // return statistics fine
    return new SuccessResult({
        id: id,
        person: person1,
        payed: fine.payed,
        number: fine.number,
        date: fine.date,
        reason: fineReason,
    });
}
