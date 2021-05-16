import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParameterContainer, checkPrerequirements, existsData, getClubComponent} from "./utils";
import fetcherTestClubJson from "./testClubs/fetcherTestClub.json";

export const newTestClub = functions.region("europe-west1").https.onCall(async (data, context) => {
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth, false);
    if (parameterContainer.getParameter<string>("clubLevel", "string") != "testing") {
        throw new functions.https.HttpsError("failed-precondition", "Function can only be called for testing.");
    }
    const path = getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter<string>("clubId", "string").toUpperCase();
    const ref = admin.database().ref(path);
    await ref.set(getTestClub(parameterContainer), (error) => {
        throw error;
    });
});

export const deleteTestClub = functions.region("europe-west1").https.onCall(async (data, context) => {
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth, false);
    if (parameterContainer.getParameter<string>("clubLevel", "string") != "testing") {
        throw new functions.https.HttpsError("failed-precondition", "Function can only be called for testing.");
    }
    const path = getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter<string>("clubId", "string").toUpperCase();
    const ref = admin.database().ref(path);
    if (await existsData(ref)) {
        ref.remove();
    }
});

export const newTestClubProperty = functions.region("europe-west1").https.onCall(async (data, context) => {
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth, false);
    if (parameterContainer.getParameter<string>("clubLevel", "string") != "testing") {
        throw new functions.https.HttpsError("failed-precondition", "Function can only be called for testing.");
    }
    const path = getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter<string>("clubId", "string").toUpperCase() + "/" + parameterContainer.getParameter<string>("propertyPath", "string");
    const ref = admin.database().ref(path);
    ref.set(data.data);
});

export const deleteTestClubProperty = functions.region("europe-west1").https.onCall(async (data, context) => {
    const parameterContainer = new ParameterContainer(data);
    await checkPrerequirements(parameterContainer, context.auth, false);
    if (parameterContainer.getParameter<string>("clubLevel", "string") != "testing") {
        throw new functions.https.HttpsError("failed-precondition", "Function can only be called for testing.");
    }
    const path = getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter<string>("clubId", "string").toUpperCase() + "/" + parameterContainer.getParameter<string>("propertyPath", "string");
    const ref = admin.database().ref(path);
    if (await existsData(ref)) {
        ref.remove();
    }
});

function getTestClub(parameterContainer: ParameterContainer): any {
    const testClubType = parameterContainer.getParameter<string>("testClubType", "string");
    switch (testClubType) {
    case "fetcherTestClub":
        return fetcherTestClubJson;
    default:
        throw new functions.https.HttpsError("invalid-argument", "Argument testClubType is invalid " + testClubType);
    }
}
