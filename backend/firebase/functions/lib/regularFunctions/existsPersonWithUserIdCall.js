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
exports.existsPersonWithUserIdCall = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const utils_1 = require("../utils");
/**
 * Checks if a person with given user id exists.
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - userId (string): user id to search in database
 * @returns (boolean): `true`if a person with given user id exists
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *                        or if a parameter hasn't the right type
 *                        or if clubLevel isn't `regular`, `debug` or `testing`
 */
exports.existsPersonWithUserIdCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to all clubs
    const parameterContainer = new utils_1.ParameterContainer(data);
    await utils_1.checkPrerequirements(parameterContainer, context.auth, false);
    const path = utils_1.getClubComponent(parameterContainer);
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
//# sourceMappingURL=existsPersonWithUserIdCall.js.map