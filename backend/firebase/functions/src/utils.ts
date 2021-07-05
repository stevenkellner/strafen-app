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
          throw new functions.https.HttpsError("invalid-argument", `Argument "${parameterName}" couldn't be converted to expected type "${expectedType}"`);
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
        const path = `${getClubComponent(parameterContainer)}/${clubId.toUpperCase()}/personUserIds/${auth.uid}`;
        const ref = admin.database().ref(path);
        if (!await existsData(ref)) {
            throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
        }
    }
}

export async function existsData(reference: admin.database.Reference): Promise<boolean> {
    return (await reference.once("value")).exists();
}

export function getClubComponent(parameterContainer: ParameterContainer): string {
    const clubLevel = parameterContainer.getParameter<string>("clubLevel", "string");
    switch (clubLevel) {
    case "regular": return "clubs";
    case "debug": return "debugClubs";
    case "testing": return "testableClubs";
    default:
        throw new functions.https.HttpsError("invalid-argument", `Argument clubLevel is invalid ${clubLevel}`);
    }
}

// / Used to generate a new guid
class Guid {
    /**
     * Generates a new guid
     * @return {string} generated guid
     */
    static newGuid(): string {
        return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c) {
            const r = Math.random() * 16 | 0;
            const v = c == "x" ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        }).toUpperCase();
    }
}

// / Contains name and propoerties of a statistic
interface StatisticProperties {

    // / Name of the statistic
    name: string;

    // / Properties of the statistic
    properties: { [key: string]: any; };
}

/**
 * Saves specifed statistic properties to specified club path
 * @param {string} clubPath Path of club to save statistic to
 * @param {StatisticProperties} properties Properties of statistic to save
 */
export async function saveStatistic(clubPath: string, properties: StatisticProperties) {
    const path = `${clubPath}/statistics/${Guid.newGuid()}`;
    const reference = admin.database().ref(path);
    await reference.set({
        ...properties,
        timestamp: Date.now(),
    });
}

export class SuccessResult<T> {
    value: T;

    constructor(val: T) {
        this.value = val;
    }

    get(): T {
        return this.value;
    }

    getValue(): T {
        return this.value;
    }

    map<T2>(mapper: (val: T) => T2): Result<T2, never> {
        return new SuccessResult(mapper(this.value));
    }

    mapError<E2>(mapper: (val: never) => E2): Result<T, E2> {
        return this;
    }
}

export class FailureResult<E> {
    error: E;

    constructor(err: E) {
        this.error = err;
    }

    get(): never {
        throw this.error;
    }

    getValue(): null {
        return null;
    }

    map<T2>(mapper: (val: never) => T2): Result<T2, E> {
        return this;
    }

    mapError<E2>(mapper: (val: E) => E2): Result<never, E2> {
        return new FailureResult(mapper(this.error));
    }
}

export type Result<T, E> = SuccessResult<T> | FailureResult<E>;
