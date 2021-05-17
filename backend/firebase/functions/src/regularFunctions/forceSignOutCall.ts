import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParameterContainer, checkPrerequirements, getClubComponent, existsData} from "../utils";

/**
 * Force sign out a person
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - clubId (string): id of the club to force sign out the person
 *  - personId (string): id of person to be force signed out
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *                        or if a parameter hasn't the right type
 *                        or if clubLevel isn't `regular`, `debug` or `testing`
 *    - internal: if an error occurs while force sign out the person in database
 */
export const forceSignOutCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to the person sign in data
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth);
    const clubPath = getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter<string>("clubId", "string").toUpperCase();
    const signInDataPath = clubPath + "/persons/" + parameterContainer.getParameter<string>("personId", "string").toUpperCase() + "/signInData";
    const signInDataRef = admin.database().ref(signInDataPath);

    // Force sign out
    if (await existsData(signInDataRef)) {
        let userId = null;
        await signInDataRef.child("userId").once("value", (snapshot) => {
            userId = snapshot.val();
        });
        let errorOccured = false;
        await signInDataRef.remove((error) => {
            errorOccured = errorOccured || error != null;
        });
        if (userId == null) {
            throw new functions.https.HttpsError("internal", "Couldn't force sign out person in database.");
        }
        const personUserIdPath = clubPath + "/personUserIds/" + userId;
        const personUserIdRef = admin.database().ref(personUserIdPath);
        if (await existsData(personUserIdRef)) {
            await personUserIdRef.remove((error) => {
                errorOccured = errorOccured || error != null;
            });
        }
        if (errorOccured) {
            throw new functions.https.HttpsError("internal", "Couldn't force sign out person in database.");
        }
    }
});
