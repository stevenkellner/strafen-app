/* eslint-disable @typescript-eslint/ban-types */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParameterContainer, checkPrerequirements, getClubComponent, existsData} from "../utils";

/**
 * Changes a element of person, fine or reason list
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
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *                        or if a parameter hasn't the right type
 *                        or if clubLevel isn't `regular`, `debug` or `testing`
 *                        or if list type isn't `person`, `fine` or `reason`
 *                        or if change type isn't `update` or `delete`
 *                        or if change type is `update` and list type is `fine` and the fine has no valid reason
 *                        or if change type is `update`and list type is `fine` and payed state isn't `payed`, `settled` or `unpayed`
 *    - unavailable: if change is deletion of an already signed in person
 *    - internal: if couldn't change item in database
 */
export const changeListCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to the item to change
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth);
    let path = getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter<string>("clubId", "string").toUpperCase() + "/" + parameterContainer.getParameter<string>("listType", "string") + "s/" + parameterContainer.getParameter<string>("itemId", "string").toUpperCase();
    if (parameterContainer.getParameter<string>("changeType", "string") == "update" && parameterContainer.getParameter<string>("listType", "string") == "person") {
        path = path + "/name";
    }
    const ref = admin.database().ref(path);

    const changeType = parameterContainer.getParameter<string>("changeType", "string");
    let errorOccured = false;
    switch (changeType) {
    // Delete list item
    case "delete":
        const listType = parameterContainer.getParameter<string>("listType", "string");
        if (listType != "person" && listType != "fine" && listType != "reason" && listType != "transaction") {
            throw new functions.https.HttpsError("invalid-argument", "Argument listType is invalid \"" + listType + "\"");
        }
        if (listType == "person") {
            if (await existsData(ref.child("signInData"))) {
                throw new functions.https.HttpsError("unavailable", "Person is already signed in!");
            }
        }
        errorOccured = false;
        if (await existsData(ref)) {
            await ref.remove((error) => {
                errorOccured = error != null;
            });
        }
        if (errorOccured) {
            throw new functions.https.HttpsError( "internal", "Couldn't delete item." );
        }
        break;

    // Set / update list item
    case "update":
        const item = getItem(parameterContainer);
        errorOccured = false;
        await ref.set(item, (error) => {
            errorOccured = error != null;
        });
        if (errorOccured) {
            throw new functions.https.HttpsError( "internal", "Couldn't update item." );
        }
        break;

    // Throw error if change type is invalid
    default:
        throw new functions.https.HttpsError("invalid-argument", "Argument changeType is invalid \"" + changeType + "\"");
    }
});


function getItem(parameterContainer: ParameterContainer): object {
    const listType = parameterContainer.getParameter<string>("listType", "string");
    let importance = null;
    switch (listType) {
    // Get person
    case "person":
        return {
            first: parameterContainer.getParameter<string>("firstName", "string"),
            last: parameterContainer.getOptionalParameter<string>("lastName", "string"),
        };

    // Get fine
    case "fine":
        const templateId = parameterContainer.getOptionalParameter<string>("templateId", "string");
        const reason = parameterContainer.getOptionalParameter<string>("reason", "string");
        const amount = parameterContainer.getOptionalParameter<number>("amount", "number");
        importance = parameterContainer.getOptionalParameter<string>("importance", "string");
        let reasonTemplate = null;
        if (templateId != null) {
            reasonTemplate = {
                templateId: templateId,
            };
        } else if (reason != null && amount != null && importance != null) {
            if (importance != "high" && importance != "medium" && importance != "low") {
                throw new functions.https.HttpsError("invalid-argument", "Argument importance is invalid \"" + importance + "\"");
            }
            reasonTemplate = {
                reason: reason,
                amount: amount,
                importance: importance,
            };
        } else {
            throw new functions.https.HttpsError("invalid-argument", "Fine has no valid reason.");
        }
        const payedState = parameterContainer.getParameter<string>("payedState", "string");
        let payed = null;
        if (payedState == "payed") {
            payed = {
                state: payedState,
                payDate: parameterContainer.getParameter<number>("payedPayDate", "number"),
                inApp: parameterContainer.getParameter<boolean>("payedInApp", "boolean"),
            };
        } else if (payedState == "settled" || payedState == "unpayed") {
            payed = {state: payedState};
        } else {
            throw new functions.https.HttpsError("invalid-argument", "Argument payedState is invalid \"" + payedState + "\"");
        }
        return {
            personId: parameterContainer.getParameter<string>("personId", "string"),
            payed: payed,
            number: parameterContainer.getParameter<number>("number", "number"),
            date: parameterContainer.getParameter<number>("date", "number"),
            reason: reasonTemplate,
        };

    // Get reason
    case "reason":
        importance = parameterContainer.getOptionalParameter<string>("importance", "string");
        if (importance != "high" && importance != "medium" && importance != "low") {
            throw new functions.https.HttpsError("invalid-argument", "Argument importance is invalid \"" + importance + "\"");
        }
        return {
            reason: parameterContainer.getOptionalParameter<string>("reason", "string"),
            amount: parameterContainer.getOptionalParameter<number>("amount", "number"),
            importance: importance,
        };

    // Get transaction
    case "tranaction":
        return {
            approved: parameterContainer.getParameter<boolean>("approved", "boolean"),
            fineids: parameterContainer.getParameter<object>("fineIds", "object"),
            name: {
                first: parameterContainer.getOptionalParameter<string>("firstName", "string"),
                last: parameterContainer.getOptionalParameter<string>("lastName", "string"),
            },
            payDate: parameterContainer.getParameter<number>("payDate", "number"),
            personId: parameterContainer.getParameter<string>("payDate", "string"),
            payoutId: parameterContainer.getOptionalParameter<string>("payoutId", "string"),
        };

    // Throw error if change type is invalid
    default:
        throw new functions.https.HttpsError("invalid-argument", "Argument listType is invalid \"" + listType + "\"");
    }
}
