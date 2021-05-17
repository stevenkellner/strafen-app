import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParameterContainer, checkPrerequirements, getClubComponent, existsData} from "../utils";

/**
 * Creates a new club with given properties.
 *
 * Doesn't update club, if already a club with same club id exists.
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - clubId (sting): id of the club to be created
 *  - clubName (string): name of the club to be created
 *  - personId: (string): id of the person who creates the club
 *  - personFirstName (string): first name of the person who creates the club
 *  - personLastName (string | null): last name of the person who creates the club
 *  - clubIdentifier (string): identifier of the club to be created
 *  - userId (string): user id of the person who creates the club
 *  - signInDate (number): date of sign in of the person who creates the club
 *  - regionCode (string): region code of the club to be created
 *  - inAppPayment (boolean): indicates whether in app payment is active for the club to be created
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *                        or if a parameter hasn't the right type
 *                        or if clubLevel isn't `regular`, `debug` or `testing`
 *    - failed-precondition: if function is called while no person is sign in
 *    - already-exists: if already a club with given identifier exists
 *    - internal: if an error occurs while setting club properties in database
 */
export const newClubCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to all clubs
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth, false);
    const allClubsPath = getClubComponent(parameterContainer);
    const allclubsRef = admin.database().ref(allClubsPath);

    // Check if identifier already exists
    let clubExists = false;
    const clubIdentifier = parameterContainer.getParameter<string>("clubIdentifier", "string");
    await allclubsRef.once("value", (snapshot) => {
        snapshot.forEach((child) => {
            const identifier = child.child("identifier").val();
            if (identifier == clubIdentifier) {
                clubExists = true;
            }
        });
    });
    if (clubExists) {
        throw new functions.https.HttpsError( "already-exists", "Club identifier already exists");
    }

    // Get a reference to the club to be created
    const path = getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter<string>("clubId", "string");
    const ref = admin.database().ref(path);

    // Check if club already exists with given id
    if (await existsData(ref)) {
        return;
    }

    // Properties of club to be created
    const personList: { [key: string]: any } = {};
    personList[parameterContainer.getParameter<string>("personId", "string").toUpperCase()] = {
        name: {
            first: parameterContainer.getParameter<string>("personFirstName", "string"),
            last: parameterContainer.getOptionalParameter<string>("personLastName", "string"),
        },
        signInData: {
            cashier: true,
            userId: parameterContainer.getParameter<string>("userId", "string"),
            signInDate: parameterContainer.getParameter<number>("signInDate", "number"),
        },
    };
    const personUserIds: { [key: string]: any } = {};
    personUserIds[parameterContainer.getParameter<string>("userId", "string")] = parameterContainer.getParameter<string>("personId", "string").toUpperCase();
    const clubProperties = {
        identifier: parameterContainer.getParameter<string>("clubIdentifier", "string"),
        name: parameterContainer.getParameter<string>("clubName", "string"),
        regionCode: parameterContainer.getParameter<string>("regionCode", "string"),
        inAppPaymentActive: parameterContainer.getParameter<boolean>("inAppPayment", "boolean"),
        persons: personList,
        personUserIds: personUserIds,
    };

    // Set club properties
    let errorOccured = false;
    await ref.set(clubProperties, async (error) => {
        if (error != null) {
            if (await existsData(ref)) {
                ref.remove();
            }
            errorOccured = true;
        }
    });
    if (errorOccured) {
        throw new functions.https.HttpsError("internal", "Couldn't add new club to database.");
    }
});
