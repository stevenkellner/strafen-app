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
exports.changeLatePaymentInterestCall = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const utils_1 = require("../utils");
/**
 * Changes the late payment interest of club with given club id
 * @params
 *  - privateKey (string): private key to check whether the caller is authenticated to use this function
 *  - clubLevel (string): level of the club (`regular`, `debug`, `testing`)
 *  - clubId (string): id of the club to change the late payment interest
 *  - changeType (string): type of the change (`update`, `remove`)
 *  - interestFreeValue (number | null): value of interest free timeinterval (has to be provided if changeType is `update`)
 *  - interestFreeUnit (string | null): unit of interest free timeinterval (`day`, `month`, `year`) (has to be provided if changeType is `update`)
 *  - interestRate (number | null): rate of late payment interest (has to be provided if changeType is `update`)
 *  - interestValue: (number | null): value of interest timeinterval (has to be provided if changeType is `update`)
 *  - interestUnit: (string | null): unit of interest timeinterval (`day`, `month`, `year`) (has to be provided if changeType is `update`)
 *  - compoundInterest: (boolean | null): indicates whether compound interest is active (has to be provided if changeType is `update`)
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *                        or if a parameter hasn't the right type
 *                        or if clubLevel isn't `regular`, `debug` or `testing`
 *                        or if changeType isn't `update` or `remove`
 *                        or if interest(Free)Unit isn't `day`, `month` or `year`
 *    - failed-precondition: if function is called while no person is sign in or the person doesn't belong to the club
 */
exports.changeLatePaymentInterestCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to interest
    const parameterContainer = new utils_1.ParameterContainer(data);
    await utils_1.checkPrerequirements(parameterContainer, context.auth);
    const path = utils_1.getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter("clubId", "string").toUpperCase() + "/latePaymentInterest";
    const ref = admin.database().ref(path);
    const changeType = parameterContainer.getParameter("changeType", "string");
    switch (changeType) {
        // Remove late payment interest if change type is `remove`
        case "remove":
            if (await utils_1.existsData(ref)) {
                await ref.remove();
            }
            break;
        // Update late payment interest if change type is `update`
        case "update":
            checkInterestUnit(parameterContainer.getParameter("interestFreeUnit", "string"));
            checkInterestUnit(parameterContainer.getParameter("interestUnit", "string"));
            const latePaymentInterest = {
                interestFreePeriod: {
                    value: parameterContainer.getParameter("interestFreeValue", "number"),
                    unit: parameterContainer.getParameter("interestFreeUnit", "string"),
                },
                interestPeriod: {
                    value: parameterContainer.getParameter("interestValue", "number"),
                    unit: parameterContainer.getParameter("interestUnit", "string"),
                },
                interestRate: parameterContainer.getParameter("interestRate", "number"),
                compoundInterest: parameterContainer.getParameter("compoundInterest", "boolean"),
            };
            await ref.set(latePaymentInterest);
            break;
        // Throw error if change type is invalid
        default:
            throw new functions.https.HttpsError("invalid-argument", "Argument changeType is invalid \"" + changeType + "\"");
    }
});
function checkInterestUnit(interestUnit) {
    if (interestUnit != "day" && interestUnit != "month" && interestUnit != "year") {
        throw new functions.https.HttpsError("invalid-argument", "Argument interest(Free)Unit is invalid \"" + interestUnit + "\"");
    }
}
//# sourceMappingURL=changeLatePaymentInterestCall.js.map