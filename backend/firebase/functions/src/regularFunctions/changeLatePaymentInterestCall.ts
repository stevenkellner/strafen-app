import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParameterContainer, checkPrerequirements, getClubComponent, existsData} from "../utils";

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
export const changeLatePaymentInterestCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to interest
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth);
    const path = getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter<string>("clubId", "string").toUpperCase() + "/latePaymentInterest";
    const ref = admin.database().ref(path);

    const changeType = parameterContainer.getParameter<string>("changeType", "string");
    switch (changeType) {
    // Remove late payment interest if change type is `remove`
    case "remove":
        if (await existsData(ref)) {
            await ref.remove();
        }
        break;

    // Update late payment interest if change type is `update`
    case "update":
        checkInterestUnit(parameterContainer.getParameter<string>("interestFreeUnit", "string"));
        checkInterestUnit(parameterContainer.getParameter<string>("interestUnit", "string"));
        const latePaymentInterest = {
            interestFreePeriod: {
                value: parameterContainer.getParameter<number>("interestFreeValue", "number"),
                unit: parameterContainer.getParameter<string>("interestFreeUnit", "string"),
            },
            interestPeriod: {
                value: parameterContainer.getParameter<number>("interestValue", "number"),
                unit: parameterContainer.getParameter<string>("interestUnit", "string"),
            },
            interestRate: parameterContainer.getParameter<number>("interestRate", "number"),
            compoundInterest: parameterContainer.getParameter<boolean>("compoundInterest", "boolean"),
        };
        await ref.set(latePaymentInterest);
        break;

    // Throw error if change type is invalid
    default:
        throw new functions.https.HttpsError("invalid-argument", "Argument changeType is invalid \"" + changeType + "\"");
    }
});

function checkInterestUnit(interestUnit: string) {
    if (interestUnit != "day" && interestUnit != "month" && interestUnit != "year") {
        throw new functions.https.HttpsError("invalid-argument", "Argument interest(Free)Unit is invalid \"" + interestUnit + "\"");
    }
}
