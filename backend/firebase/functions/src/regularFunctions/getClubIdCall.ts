import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {checkPrerequirements, getClubComponent} from "../utils";

/**
 * Get club id with given club identifier
 * @params
 *  - privateKey: private key to check whether the caller is authenticated to use this function
 *  - clubLevel: level of the club (`regular`, `debug`, `testing`)
 *  - identifier: identifer of the club to search
 * @returns: club id of club with given identifer
 * @throws 
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - onvalid-argument: if a required parameter isn't give over
 *    - failed-precondition: if function is called while no person is sign in
 *    - not-found: if no club with given identifier exists
 */
export const getClubIdCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to all clubs
    await checkPrerequirements(data, context, ["identifier"], false);
    const path = getClubComponent(data);
    const ref = admin.database().ref(path);

    // Get club id
    let clubId = null;
    await ref.once("value", (snapshot) => {
        snapshot.forEach((child) => {
            const identifier = child.child("identifier").val();
            if (identifier == data.identifier) {
                clubId = child.key;
            }
        });
    });

    // Return club id
    if (clubId == null) {
        throw new functions.https.HttpsError("not-found", "Club doesn't exists.");
    }
    return clubId;
});
