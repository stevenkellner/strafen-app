import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParameterContainer, checkPrerequirements, getClubComponent} from "../utils";

/**
 * Checks if club with given identifier already exists
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - identifier (string): identifer of the club to search
 * @returns (boolean): `true` if a club with given identifier already exists, `false` otherwise
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *    - invalid-argument: if a parameter hasn't the right type
 *    - failed-precondition: if function is called while no person is sign in
 */
export const existsClubWithIdentifierCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to all clubs
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth, false);
    const path = getClubComponent(parameterContainer);
    const ref = admin.database().ref(path);

    // Check if club identifier exists
    let clubExists = false;
    await ref.once("value", (snapshot) => {
        snapshot.forEach((child) => {
            const identifier = child.child("identifier").val();
            if (identifier == parameterContainer.getParameter<string>("identifier", "string")) {
                clubExists = true;
            }
        });
    });
    return clubExists;
});
