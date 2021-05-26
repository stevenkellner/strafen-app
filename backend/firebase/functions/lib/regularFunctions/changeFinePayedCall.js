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
exports.changeFinePayedCall = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const utils_1 = require("../utils");
/**
 * Changes payement state of fine with given fine id
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - clubId (string): id of the club to change the fine
 *  - fineId (string): id of the fine to change the payed state
 *  - state (string): state of the payment of the fine  (`payed`, `settled`, `unpayed`)
 *  - payDate (number | null): pay date of the fine (has to be provided if state is `payed`)
 *  - inApp (boolean | null): indicates if the fine is payed in app (has to be provided if state is `payed`)
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *                        or if a parameter hasn't the right type
 *                        or if clubLevel isn't `regular`, `debug` or `testing`
 *                        or if state isn't `payed`, `settled` or `unpayed`
 *    - internal: if couldn't change payed state in database
 */
exports.changeFinePayedCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to payed state of the fine
    const parameterContainer = new utils_1.ParameterContainer(data);
    await utils_1.checkPrerequirements(parameterContainer, context.auth);
    const path = utils_1.getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter("clubId", "string").toUpperCase() + "/fines/" + parameterContainer.getParameter("fineId", "string").toUpperCase() + "/payed";
    const ref = admin.database().ref(path);
    // Get payed state
    const state = parameterContainer.getParameter("state", "string");
    let payed = null;
    if (state == "payed") {
        payed = {
            state: state,
            payDate: parameterContainer.getParameter("payDate", "number"),
            inApp: parameterContainer.getParameter("inApp", "boolean"),
        };
    }
    else if (state == "settled" || state == "unpayed") {
        payed = { state: state };
    }
    else {
        throw new functions.https.HttpsError("invalid-argument", "Argument state is invalid \"" + state + "\"");
    }
    // Set payed state
    let errorOccured = false;
    await ref.set(payed, (error) => {
        errorOccured = error != null;
    });
    if (errorOccured) {
        throw new functions.https.HttpsError("internal", "Couldn't update payed state.");
    }
});
//# sourceMappingURL=changeFinePayedCall.js.map