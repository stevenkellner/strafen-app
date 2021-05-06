import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {privateKey} from "./privateKeys";

export async function checkPrerequirements(data: any, context: functions.https.CallableContext, parameters: string[], checkPersonIsInClub = true) {
    // Check if key is valid
    if (data.privateKey != privateKey) {
        throw new functions.https.HttpsError("permission-denied", "Private key is invalid.");
    }

    // Check if all parameters are hand over to this function
    parameters.push("clubLevel");
    for (const parameter of parameters) {
        if (data[parameter] == null) {
            throw new functions.https.HttpsError("invalid-argument", "Argument \"" + parameter + "\" not found");
        }
    }

    // Check if user is authorized to call a function
    if (context.auth == null) {
        throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
    }

    // Check if person is sign in to club
    if (checkPersonIsInClub) {
        if (data.clubId == null) {
            throw new functions.https.HttpsError("invalid-argument", "Argument \"clubId\" not found");
        }
        const path = getClubComponent(data) + "/" + data.clubId.toString().toUpperCase() + "/personUserIds/" + context.auth.uid;
        const ref = admin.database().ref(path);
        if (!await existsData(ref)) {
            throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
        }
    }
}

export async function existsData(reference: admin.database.Reference): Promise<boolean> {
    let exists = false;
    await reference.once("value", (snapshot) => {
        exists = snapshot.val() != null;
    });
    return exists;
}

export function getClubComponent(data: any): string {
    switch (data.clubLevel) {
    case "regular":
        return "clubs";
    case "debug":
        return "debugClubs";
    case "testing":
        return "testableClubs";
    default:
        throw new functions.https.HttpsError("invalid-argument", "Argument clubLevel is invalid " + data.clubLevel.toString());
    }
}
