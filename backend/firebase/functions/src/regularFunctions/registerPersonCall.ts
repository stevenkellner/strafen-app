import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParameterContainer, checkPrerequirements, getClubComponent, saveStatistic} from "../utils";

/**
 * @summary
 * Register person to club with given club id.
 *
 * Saved statistik:
 *  - name: registerPerson
 *  - properties:
 *      - personId (string): id of the person to be registered
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - clubId (string): id of the club to register the person
 *  - id (string): id of the person to be registered
 *  - firstName (string): first name of the person to be registered
 *  - lastName (string | null): last name of the person to be registered
 *  - userId (string): user id of the person to be registered
 *  - signInDate (number): date of sign in of the person to be registered
 * @returns
 *  - clubIdentifier: (string): identifier of the club the person is registered to
 *  - clubName (string): name of the club the person is registered to
 *  - regionCode (string): region code of the club the person is registered to
 *  - inAppPayment: (boolean): indicates whether in app payment is active for the club the person is registered to
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *                        or if a parameter hasn't the right type
 *                        or if clubLevel isn't `regular`, `debug` or `testing`
 *    - failed-precondition: if function is called while no person is sign in or the person doesn't belong to the club
 *    - internal: if an error occurs while register person in database
 *                or if couldn't get club properties to return
 */
export const registerPersonCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to the club and the person and person user id
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth);
    const clubPath = getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter<string>("clubId", "string").toUpperCase();
    const personPath = clubPath + "/persons/" + parameterContainer.getParameter<string>("id", "string").toUpperCase();
    const personUserIdPath = clubPath + "/personUserIds/" + parameterContainer.getParameter<string>("userId", "string");
    const clubRef = admin.database().ref(clubPath);
    const personRef = admin.database().ref(personPath);
    const personUserIdRef = admin.database().ref(personUserIdPath);

    // Get person properties
    const person = {
        name: {
            first: parameterContainer.getParameter<string>("firstName", "string"),
            last: parameterContainer.getOptionalParameter<string>("lastName", "string"),
        },
        signInData: {
            cashier: false,
            userId: parameterContainer.getParameter<string>("userId", "string"),
            signInDate: parameterContainer.getParameter<number>("signInDate", "number"),
        },
    };

    // Register person
    let errorOccured = false;
    await personRef.set(person, (error) => {
        errorOccured = errorOccured || error != null;
    });
    await personUserIdRef.set(parameterContainer.getParameter<string>("id", "string").toUpperCase(), (error) => {
        errorOccured = errorOccured || error != null;
    });
    if (errorOccured) {
        throw new functions.https.HttpsError("internal", "Couldn't register person to database.");
    }

    // Get club properties to return
    let clubIdentifier: string | null = null;
    let clubName: string | null = null;
    let regionCode: string | null = null;
    let inAppPaymentActive = false;
    await clubRef.child("identifier").once("value", (snapshot) => {
        clubIdentifier = snapshot.val();
    });
    await clubRef.child("name").once("value", (snapshot) => {
        clubName = snapshot.val();
    });
    await clubRef.child("regionCode").once("value", (snapshot) => {
        regionCode = snapshot.val();
    });
    await clubRef.child("inAppPaymentActive").once("value", (snapshot) => {
        inAppPaymentActive = snapshot.val();
    });
    if (clubIdentifier == null || clubName == null || regionCode == null) {
        throw new functions.https.HttpsError("internal", "Couldn't get club properties to return.");
    }

    // Save statistic
    await saveStatistic(clubPath, {
        name: "registerPerson",
        properties: {
            personId: parameterContainer.getParameter<string>("id", "string").toUpperCase(),
        },
    });

    // Return club properties
    return {
        clubIdentifier: clubIdentifier,
        clubName: clubName,
        regionCode: regionCode,
        inAppPaymentActive: inAppPaymentActive,
    };
});
