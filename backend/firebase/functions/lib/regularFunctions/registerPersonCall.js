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
exports.registerPersonCall = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const utils_1 = require("../utils");
/**
 * Register person to club with given club id
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
exports.registerPersonCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to the club and the person and person user id
    const parameterContainer = new utils_1.ParameterContainer(data);
    await utils_1.checkPrerequirements(parameterContainer, context.auth);
    const clubPath = utils_1.getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter("clubId", "string").toUpperCase();
    const personPath = clubPath + "/persons/" + parameterContainer.getParameter("id", "string").toUpperCase();
    const personUserIdPath = clubPath + "/personUserIds/" + parameterContainer.getParameter("userId", "string");
    const clubRef = admin.database().ref(clubPath);
    const personRef = admin.database().ref(personPath);
    const personUserIdRef = admin.database().ref(personUserIdPath);
    // Get person properties
    const person = {
        name: {
            first: parameterContainer.getParameter("firstName", "string"),
            last: parameterContainer.getOptionalParameter("lastName", "string"),
        },
        signInData: {
            cashier: false,
            userId: parameterContainer.getParameter("userId", "string"),
            signInDate: parameterContainer.getParameter("signInDate", "number"),
        },
    };
    // Register person
    let errorOccured = false;
    await personRef.set(person, (error) => {
        errorOccured = errorOccured || error != null;
    });
    await personUserIdRef.set(parameterContainer.getParameter("id", "string").toUpperCase(), (error) => {
        errorOccured = errorOccured || error != null;
    });
    if (errorOccured) {
        throw new functions.https.HttpsError("internal", "Couldn't register person to database.");
    }
    // Get club properties to return
    let clubIdentifier = null;
    let clubName = null;
    let regionCode = null;
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
    // Return club properties
    return {
        clubIdentifier: clubIdentifier,
        clubName: clubName,
        regionCode: regionCode,
        inAppPaymentActive: inAppPaymentActive,
    };
});
//# sourceMappingURL=registerPersonCall.js.map