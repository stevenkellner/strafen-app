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
exports.deleteTestClubProperty = exports.newTestClubProperty = exports.deleteTestClub = exports.newTestClub = exports.existsPersonWithUserId = exports.getPersonProperties = exports.changeFinePayed = exports.changeList = exports.forceSignOut = exports.registerPerson = exports.changeLatePaymentInterest = exports.newClub = exports.existsClubWithIdentifier = exports.getClubId = exports.saveCreditCard = exports.checkTransactions = exports.newTransaction = void 0;
const cf = __importStar(require("./callableFunctions"));
const tf = __importStar(require("./testableFunctions"));
const getClubIdCall_1 = require("./regularFunctions/getClubIdCall");
const existsClubWithIdentifierCall_1 = require("./regularFunctions/existsClubWithIdentifierCall");
const newClubCall_1 = require("./regularFunctions/newClubCall");
const changeLatePaymentInterestCall_1 = require("./regularFunctions/changeLatePaymentInterestCall");
const registerPersonCall_1 = require("./regularFunctions/registerPersonCall");
const forceSignOutCall_1 = require("./regularFunctions/forceSignOutCall");
const changeListCall_1 = require("./regularFunctions/changeListCall");
const changeFinePayedCall_1 = require("./regularFunctions/changeFinePayedCall");
const getPersonPropertiesCall_1 = require("./regularFunctions/getPersonPropertiesCall");
const existsPersonWithUserIdCall_1 = require("./regularFunctions/existsPersonWithUserIdCall");
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
exports.newTransaction = cf.newTransaction;
exports.checkTransactions = cf.checkTransactions;
exports.saveCreditCard = cf.saveCreditCard;
exports.getClubId = getClubIdCall_1.getClubIdCall;
exports.existsClubWithIdentifier = existsClubWithIdentifierCall_1.existsClubWithIdentifierCall;
exports.newClub = newClubCall_1.newClubCall;
exports.changeLatePaymentInterest = changeLatePaymentInterestCall_1.changeLatePaymentInterestCall;
exports.registerPerson = registerPersonCall_1.registerPersonCall;
exports.forceSignOut = forceSignOutCall_1.forceSignOutCall;
exports.changeList = changeListCall_1.changeListCall;
exports.changeFinePayed = changeFinePayedCall_1.changeFinePayedCall;
exports.getPersonProperties = getPersonPropertiesCall_1.getPersonPropertiesCall;
exports.existsPersonWithUserId = existsPersonWithUserIdCall_1.existsPersonWithUserIdCall;
exports.newTestClub = tf.newTestClub;
exports.deleteTestClub = tf.deleteTestClub;
exports.newTestClubProperty = tf.newTestClubProperty;
exports.deleteTestClubProperty = tf.deleteTestClubProperty;
//# sourceMappingURL=index.js.map