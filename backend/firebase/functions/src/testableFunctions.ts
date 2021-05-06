import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {checkPrerequirements, existsData, getClubComponent} from "./utils";
import fetcherTestClubJson from "./testClubs/fetcherTestClub.json";

export const newTestClub = functions.region("europe-west1").https.onCall(async (data, context) => {
    await checkPrerequirements(data, context, ["clubId", "testClubType"], false);
    if (data.clubLevel != "testing") {
        throw new functions.https.HttpsError("failed-precondition", "Function can only be called for testing.");
    }
    const path = getClubComponent(data) + "/" + data.clubId.toString().toUpperCase();
    const ref = admin.database().ref(path);
    await ref.set(getTestClub(data), (error) => {
        throw error;
    });
});

export const deleteTestClub = functions.region("europe-west1").https.onCall(async (data, context) => {
    await checkPrerequirements(data, context, ["clubId"], false);
    if (data.clubLevel != "testing") {
        throw new functions.https.HttpsError("failed-precondition", "Function can only be called for testing.");
    }
    const path = getClubComponent(data) + "/" + data.clubId.toString().toUpperCase();
    const ref = admin.database().ref(path);
    if (await existsData(ref)) {
        ref.remove();
    }
});

export const newTestClubProperty = functions.region("europe-west1").https.onCall(async (data, context) => {
    await checkPrerequirements(data, context, ["clubId", "propertyPath", "data"], false);
    if (data.clubLevel != "testing") {
        throw new functions.https.HttpsError("failed-precondition", "Function can only be called for testing.");
    }
    const path = getClubComponent(data) + "/" + data.clubId.toString().toUpperCase() + "/" + data.propertyPath;
    const ref = admin.database().ref(path);
    if (await existsData(ref)) {
        ref.update(data.data);
    } else {
        ref.set(data.data);
    }
});

export const deleteTestClubProperty = functions.region("europe-west1").https.onCall(async (data, context) => {
    await checkPrerequirements(data, context, ["clubId", "propertyPath"], false);
    if (data.clubLevel != "testing") {
        throw new functions.https.HttpsError("failed-precondition", "Function can only be called for testing.");
    }
    const path = getClubComponent(data) + "/" + data.clubId.toString().toUpperCase() + "/" + data.propertyPath;
    const ref = admin.database().ref(path);
    if (await existsData(ref)) {
        ref.remove();
    }
});

function getTestClub(data: any): any {
    switch (data.testClubType) {
    case "fetcherTestClub":
        return fetcherTestClubJson;
    default:
        throw new functions.https.HttpsError("invalid-argument", "Argument testClubType is invalid " + data.testClubType.toString());
    }
}
