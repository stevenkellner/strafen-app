import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParameterContainer, checkPrerequirements, getClubComponent} from "../utils";

/**
 * @summary
 * Checks if a person with given user id exists.
 * 
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - userId (string): user id to search in database
 * 
 * @returns (boolean): `true`if a person with given user id exists
 * 
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *      or if a parameter hasn't the right type
 *      or if clubLevel isn't `regular`, `debug` or `testing`
 */
export const existsPersonWithUserIdCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to all clubs
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth, false);
    const path = getClubComponent(parameterContainer);
    const ref = admin.database().ref(path);

    // Check if person exists
    let personExists = false;
    await ref.once("value", (snapshot) => {
        snapshot.forEach((club) => {
            club.child("persons").forEach((person) => {
                const userId = person.child("signInData").child("userId").val();
                if (userId == data.userId) {
                    personExists = true;
                }
            });
        });
    });
    return personExists;
});
