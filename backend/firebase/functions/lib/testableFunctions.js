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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteTestClubProperty = exports.newTestClubProperty = exports.deleteTestClub = exports.newTestClub = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const utils_1 = require("./utils");
const fetcherTestClub_json_1 = __importDefault(require("./testClubs/fetcherTestClub.json"));
exports.newTestClub = functions.region("europe-west1").https.onCall(async (data, context) => {
    const parameterContainer = new utils_1.ParameterContainer(data);
    await utils_1.checkPrerequirements(parameterContainer, context.auth, false);
    if (parameterContainer.getParameter("clubLevel", "string") != "testing") {
        throw new functions.https.HttpsError("failed-precondition", "Function can only be called for testing.");
    }
    const path = utils_1.getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter("clubId", "string").toUpperCase();
    const ref = admin.database().ref(path);
    await ref.set(getTestClub(parameterContainer), (error) => {
        throw error;
    });
});
exports.deleteTestClub = functions.region("europe-west1").https.onCall(async (data, context) => {
    const parameterContainer = new utils_1.ParameterContainer(data);
    await utils_1.checkPrerequirements(parameterContainer, context.auth, false);
    if (parameterContainer.getParameter("clubLevel", "string") != "testing") {
        throw new functions.https.HttpsError("failed-precondition", "Function can only be called for testing.");
    }
    const path = utils_1.getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter("clubId", "string").toUpperCase();
    const ref = admin.database().ref(path);
    if (await utils_1.existsData(ref)) {
        ref.remove();
    }
});
exports.newTestClubProperty = functions.region("europe-west1").https.onCall(async (data, context) => {
    const parameterContainer = new utils_1.ParameterContainer(data);
    await utils_1.checkPrerequirements(parameterContainer, context.auth, false);
    if (parameterContainer.getParameter("clubLevel", "string") != "testing") {
        throw new functions.https.HttpsError("failed-precondition", "Function can only be called for testing.");
    }
    const path = utils_1.getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter("clubId", "string").toUpperCase() + "/" + parameterContainer.getParameter("propertyPath", "string");
    const ref = admin.database().ref(path);
    ref.set(data.data);
});
exports.deleteTestClubProperty = functions.region("europe-west1").https.onCall(async (data, context) => {
    const parameterContainer = new utils_1.ParameterContainer(data);
    await utils_1.checkPrerequirements(parameterContainer, context.auth, false);
    if (parameterContainer.getParameter("clubLevel", "string") != "testing") {
        throw new functions.https.HttpsError("failed-precondition", "Function can only be called for testing.");
    }
    const path = utils_1.getClubComponent(parameterContainer) + "/" + parameterContainer.getParameter("clubId", "string").toUpperCase() + "/" + parameterContainer.getParameter("propertyPath", "string");
    const ref = admin.database().ref(path);
    if (await utils_1.existsData(ref)) {
        ref.remove();
    }
});
function getTestClub(parameterContainer) {
    const testClubType = parameterContainer.getParameter("testClubType", "string");
    switch (testClubType) {
        case "fetcherTestClub":
            return fetcherTestClub_json_1.default;
        default:
            throw new functions.https.HttpsError("invalid-argument", "Argument testClubType is invalid " + testClubType);
    }
}
//# sourceMappingURL=testableFunctions.js.map