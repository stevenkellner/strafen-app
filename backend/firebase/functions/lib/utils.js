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
exports.getClubComponent = exports.existsData = exports.checkPrerequirements = exports.ParameterContainer = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const privateKeys_1 = require("./privateKeys");
class ParameterContainer {
    constructor(data) {
        this.data = data;
    }
    getParameter(parameterName, expectedType) {
        const parameter = this.data[parameterName];
        if (parameter === null || parameter === undefined) {
            throw new functions.https.HttpsError("invalid-argument", "Argument \"" + parameterName + "\" not found");
        }
        if (typeof (parameter) !== expectedType) {
            throw new functions.https.HttpsError("invalid-argument", "Argument \"" + parameterName + "\" couldn't be converted to expected type \"" + expectedType + "\"");
        }
        return parameter;
    }
    getOptionalParameter(parameterName, expectedType) {
        const parameter = this.data[parameterName];
        if (parameter === null || parameter === undefined) {
            return null;
        }
        if (typeof (parameter) !== expectedType) {
            throw new functions.https.HttpsError("invalid-argument", "Argument \"" + parameterName + "\" couldn't be converted to expected type \"" + expectedType + "\"");
        }
        return parameter;
    }
}
exports.ParameterContainer = ParameterContainer;
async function checkPrerequirements(parameterContainer, auth, checkPersonIsInClub = true) {
    // Check if key is valid
    if (parameterContainer.getParameter("privateKey", "string") != privateKeys_1.privateKey) {
        throw new functions.https.HttpsError("permission-denied", "Private key is invalid.");
    }
    // Check if user is authorized to call a function
    if (auth == null) {
        throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
    }
    // Check if person is sign in to club
    if (checkPersonIsInClub) {
        const clubId = parameterContainer.getParameter("clubId", "string");
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
exports.checkPrerequirements = checkPrerequirements;
async function existsData(reference) {
    let exists = false;
    await reference.once("value", (snapshot) => {
        exists = snapshot.val() != null;
    });
    return exists;
}
exports.existsData = existsData;
function getClubComponent(parameterContainer) {
    const clubLevel = parameterContainer.getParameter("clubLevel", "string");
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
exports.getClubComponent = getClubComponent;
//# sourceMappingURL=utils.js.map