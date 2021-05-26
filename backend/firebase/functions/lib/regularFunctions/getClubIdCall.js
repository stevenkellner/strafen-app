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
exports.getClubIdCall = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const utils_1 = require("../utils");
/**
 * Get club id with given club identifier
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - identifier (string): identifer of the club to search
 * @returns (string): club id of club with given identifer
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *                        or if a parameter hasn't the right type
 *                        or if clubLevel isn't `regular`, `debug` or `testing`
 *    - failed-precondition: if function is called while no person is sign in
 *    - not-found: if no club with given identifier exists
 */
exports.getClubIdCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to all clubs
    const parameterContainer = new utils_1.ParameterContainer(data);
    await utils_1.checkPrerequirements(parameterContainer, context.auth, false);
    const path = utils_1.getClubComponent(parameterContainer);
    const ref = admin.database().ref(path);
    // Get club id
    let clubId = null;
    await ref.once("value", (snapshot) => {
        snapshot.forEach((child) => {
            const identifier = child.child("identifier").val();
            if (identifier == parameterContainer.getParameter("identifier", "string")) {
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
//# sourceMappingURL=getClubIdCall.js.map