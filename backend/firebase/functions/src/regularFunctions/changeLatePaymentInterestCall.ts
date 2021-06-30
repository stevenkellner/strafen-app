import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParameterContainer, checkPrerequirements, getClubComponent, existsData, saveStatistic} from "../utils";
import {LatePaymentInterest} from "../typeDefinitions";

/**
 * @summary
 * Changes the late payment interest of club with given club id.
 *
 * Saved statistik:
 *  - name: changeLatePaymentInterest
 *  - properties:
 *      - previousInterest ({@link LatePaymentInterest} | null): Previous late payment interest
 *      - changedInterest ({@link LatePaymentInterest} | null): Changed late payment interest or null if change type is `remove`
 *
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
 *
 * @throws
 *  - functions.https.HttpsError:
 *    - permission-denied: if private key isn't valid
 *    - invalid-argument: if a required parameter isn't give over
 *      or if a parameter hasn't the right type
 *      or if clubLevel isn't `regular`, `debug` or `testing`
 *      or if changeType isn't `update` or `remove`
 *      or if interest(Free)Unit isn't `day`, `month` or `year`
 *    - failed-precondition: if function is called while no person is sign in or the person doesn't belong to the club
 */
export const changeLatePaymentInterestCall = functions.region("europe-west1").https.onCall(async (data, context) => {
    // Check prerequirements and get a reference to interest
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth);
    const clubPath = `${getClubComponent(parameterContainer)}/${parameterContainer.getParameter<string>("clubId", "string").toUpperCase()}`;
    const interestRef = admin.database().ref(`${clubPath}/latePaymentInterest`);

    // Get previous interest
    let previousInterest: LatePaymentInterest | null = null;
    const interestSnapshot = await interestRef.once("value");
    if (interestSnapshot.exists()) {
        previousInterest = interestSnapshot.val();
    }

    const changeType = parameterContainer.getParameter<string>("changeType", "string");
    let latePaymentInterest: LatePaymentInterest | null = null;
    switch (changeType) {
    // Remove late payment interest if change type is `remove`
    case "remove":
        if (await existsData(interestRef)) {
            await interestRef.remove();
        }
        break;

    // Update late payment interest if change type is `update`
    case "update":
        const interestFreeUnit = parameterContainer.getParameter<string>("interestFreeUnit", "string");
        const interestUnit = parameterContainer.getParameter<string>("interestUnit", "string");
        if (interestFreeUnit != "day" && interestFreeUnit != "month" && interestFreeUnit != "year") {
            throw new functions.https.HttpsError("invalid-argument", `Argument interestFreeUnit is invalid "${interestFreeUnit}"`);
        } else if (interestUnit != "day" && interestUnit != "month" && interestUnit != "year") {
            throw new functions.https.HttpsError("invalid-argument", `Argument interestUnit is invalid "${interestUnit}"`);
        }
        latePaymentInterest = {
            interestFreePeriod: {
                value: parameterContainer.getParameter<number>("interestFreeValue", "number"),
                unit: interestFreeUnit,
            },
            interestPeriod: {
                value: parameterContainer.getParameter<number>("interestValue", "number"),
                unit: interestUnit,
            },
            interestRate: parameterContainer.getParameter<number>("interestRate", "number"),
            compoundInterest: parameterContainer.getParameter<boolean>("compoundInterest", "boolean"),
        };
        await interestRef.set(latePaymentInterest);
        break;

    // Throw error if change type is invalid
    default:
        throw new functions.https.HttpsError("invalid-argument", `Argument changeType is invalid "${changeType}"`);
    }

    // Save statistic
    await saveStatistic(clubPath, {
        name: "changeLatePaymentInterest",
        properties: {
            previousInterest: previousInterest,
            changedInterest: latePaymentInterest,
        },
    });
});
