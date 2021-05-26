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
exports.forceSignOutCall = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const utils_1 = require("../utils");
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
exports.forceSignOutCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to the person sign in data
    const parameterContainer = new utils_1.ParameterContainer(data);
    await utils_1.checkPrerequirements(parameterContainer, context.auth);
    const clubPath = utils_1.getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter("clubId", "string").toUpperCase();
    const signInDataPath = clubPath + "/persons/" + parameterContainer.getParameter("personId", "string").toUpperCase() + "/signInData";
    const signInDataRef = admin.database().ref(signInDataPath);
    // Force sign out
    if (await utils_1.existsData(signInDataRef)) {
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
        if (await utils_1.existsData(personUserIdRef)) {
            await personUserIdRef.remove((error) => {
                errorOccured = errorOccured || error != null;
            });
        }
        if (errorOccured) {
            throw new functions.https.HttpsError("internal", "Couldn't force sign out person in database.");
        }
    }
});
//# sourceMappingURL=forceSignOutCall.js.map