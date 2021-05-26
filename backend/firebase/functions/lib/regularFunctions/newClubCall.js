"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.newClubCall = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const utils_1 = require("../utils");
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
exports.newClubCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to all clubs
    const parameterContainer = new utils_1.ParameterContainer(data);
    await utils_1.checkPrerequirements(parameterContainer, context.auth, false);
    const allClubsPath = utils_1.getClubComponent(parameterContainer);
    const allclubsRef = admin.database().ref(allClubsPath);
    // Check if identifier already exists
    let clubExists = false;
    const clubIdentifier = parameterContainer.getParameter("clubIdentifier", "string");
    await allclubsRef.once("value", (snapshot) => {
        snapshot.forEach((child) => {
            const identifier = child.child("identifier").val();
            if (identifier == clubIdentifier) {
                clubExists = true;
            }
        });
    });
    if (clubExists) {
        throw new functions.https.HttpsError("already-exists", "Club identifier already exists");
    }
    // Get a reference to the club to be created
    const path = utils_1.getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter("clubId", "string");
    const ref = admin.database().ref(path);
    // Check if club already exists with given id
    if (await utils_1.existsData(ref)) {
        return;
    }
    // Properties of club to be created
    const personList = {};
    personList[parameterContainer.getParameter("personId", "string").toUpperCase()] = {
        name: {
            first: parameterContainer.getParameter("personFirstName", "string"),
            last: parameterContainer.getOptionalParameter("personLastName", "string"),
        },
        signInData: {
            cashier: true,
            userId: parameterContainer.getParameter("userId", "string"),
            signInDate: parameterContainer.getParameter("signInDate", "number"),
        },
    };
    const personUserIds = {};
    personUserIds[parameterContainer.getParameter("userId", "string")] = parameterContainer.getParameter("personId", "string").toUpperCase();
    const clubProperties = {
        identifier: parameterContainer.getParameter("clubIdentifier", "string"),
        name: parameterContainer.getParameter("clubName", "string"),
        regionCode: parameterContainer.getParameter("regionCode", "string"),
        inAppPaymentActive: parameterContainer.getParameter("inAppPayment", "boolean"),
        persons: personList,
        personUserIds: personUserIds,
    };
    // Set club properties
    let errorOccured = false;
    await ref.set(clubProperties, async (error) => {
        if (error != null) {
            if (await utils_1.existsData(ref)) {
                ref.remove();
            }
            errorOccured = true;
        }
    });
    if (errorOccured) {
        throw new functions.https.HttpsError("internal", "Couldn't add new club to database.");
    }
});
//# sourceMappingURL=newClubCall.js.map