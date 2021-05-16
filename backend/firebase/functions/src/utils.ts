import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {privateKey} from "./privateKeys";


export class ParameterContainer {
  data: any;

  constructor(data: any) {
      this.data = data;
  }

  getParameter<T>(parameterName: string, expectedType: "string" | "number" | "bigint" | "boolean" | "symbol" | "undefined" | "object" | "function"): T {
      const parameter = this.data[parameterName];
      if (parameter === null || parameter === undefined) {
          throw new functions.https.HttpsError("invalid-argument", "Argument \"" + parameterName + "\" not found");
      }
      if (typeof(parameter) !== expectedType) {
          throw new functions.https.HttpsError("invalid-argument", "Argument \"" + parameterName + "\" couldn't be converted to expected type \"" + expectedType + "\"");
      }
      return <T>parameter;
  }

  getOptionalParameter<T>(parameterName: string, expectedType: "string" | "number" | "bigint" | "boolean" | "symbol" | "undefined" | "object" | "function"): T | null {
      const parameter = this.data[parameterName];
      if (parameter === null || parameter === undefined) {
          return null;
      }
      if (typeof(parameter) !== expectedType) {
          throw new functions.https.HttpsError("invalid-argument", "Argument \"" + parameterName + "\" couldn't be converted to expected type \"" + expectedType + "\"");
      }
      return <T>parameter;
  }
}

export async function checkPrerequirements(parameterContainer: ParameterContainer, auth: { uid: string } | undefined, checkPersonIsInClub = true) {
    // Check if key is valid
    if (parameterContainer.getParameter<string>("privateKey", "string") != privateKey) {
        throw new functions.https.HttpsError("permission-denied", "Private key is invalid.");
    }

    // Check if user is authorized to call a function
    if (auth == null) {
        throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
    }

    // Check if person is sign in to club
    if (checkPersonIsInClub) {
        const clubId = parameterContainer.getParameter<string>("clubId", "string");
        if (clubId == null) {
            throw new functions.https.HttpsError("invalid-argument", "Argument \"clubId\" not found");
        }
        const path = getClubComponent(parameterContainer) + "/" + clubId.toUpperCase() + "/personUserIds/" + auth.uid;
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

export function getClubComponent(parameterContainer: ParameterContainer): string {
    const clubLevel = parameterContainer.getParameter<string>("clubLevel", "string");
    switch (clubLevel) {
    case "regular":
        return "clubs";
    case "debug":
        return "debugClubs";
    case "testing":
        return "testableClubs";
    default:
        throw new functions.https.HttpsError("invalid-argument", "Argument clubLevel is invalid " + clubLevel);
    }
}
