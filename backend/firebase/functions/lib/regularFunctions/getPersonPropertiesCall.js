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
exports.getPersonPropertiesCall = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const utils_1 = require("../utils");
/**
 * Returns club and person properties of user id
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - userId (string): user id to search in database
 * @returns:
 *  - clubProperties:
 *    - id (string): id of the club the person is in
 *    - name (string): name of the club the person is in
 *    - identifier (string): identifer of the club the person is in
 *    - regionCode (string): region code of the club the person is in
 *    - inAppPaymentActive (Bool): indicates if in app payment is active
 *  - id (string): id of the person
 *  - signInDate (number): sign in date of the person
 *  - isCashier (boolean): indicates whether the person is cashier
 *  - name:
 *    - first (string): first name of the person
 *    - last (string | null): last name of the person
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *                        or if a parameter hasn't the right type
 *                        or if clubLevel isn't `regular`, `debug` or `testing`
 *    - not-found: if no person with given user id was found
 */
exports.getPersonPropertiesCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to all clubs
    const parameterContainer = new utils_1.ParameterContainer(data);
    await utils_1.checkPrerequirements(parameterContainer, context.auth, false);
    const path = utils_1.getClubComponent(parameterContainer);
    const ref = admin.database().ref(path);
    // Get person properties
    let personProperties = null;
    await ref.once("value", (clubsSnapshot) => {
        clubsSnapshot.forEach((club) => {
            club.child("persons").forEach((person) => {
                const userId = person.child("signInData").child("userId").val();
                if (userId == parameterContainer.getParameter("userId", "string")) {
                    const isCashier = person.child("signInData").child("cashier").val();
                    const signInDate = person.child("signInData").child("signInDate").val();
                    const firstName = person.child("name").child("first").val();
                    const lastName = person.child("name").child("last").val();
                    const clubName = club.child("name").val();
                    const clubIdentifier = club.child("identifier").val();
                    const regionCode = club.child("regionCode").val();
                    const inAppPaymentActive = club.child("inAppPaymentActive").val();
                    personProperties = {
                        clubProperties: {
                            id: club.key,
                            name: clubName,
                            identifier: clubIdentifier,
                            regionCode: regionCode,
                            inAppPaymentActive: inAppPaymentActive,
                        },
                        id: person.key,
                        signInDate: signInDate,
                        isCashier: isCashier,
                        name: {
                            first: firstName,
                            last: lastName,
                        },
                    };
                }
            });
        });
    });
    // Return person properties
    if (personProperties == null) {
        throw new functions.https.HttpsError("not-found", "Person doesn't exist.");
    }
    return personProperties;
});
//# sourceMappingURL=getPersonPropertiesCall.js.map