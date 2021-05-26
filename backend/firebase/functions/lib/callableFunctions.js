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
exports.saveCreditCard = exports.checkTransactions = exports.newTransaction = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const privateKeys_1 = require("./privateKeys");
const axios = __importStar(require("axios"));
// Create a new transaction
exports.newTransaction = functions.region("europe-west1").https
    .onCall(async (data, context) => {
    // Check prerequirements
    const requiredArguements = ["clubId", "personId", "transactionId",
        "payedFinesIds", "payDate"];
    await checkPrerequirements(requiredArguements, data, context);
    const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";
    const transactionPath = clubsPathComponent + "/" +
        data.clubId.toString().toUpperCase() +
        "/transactions/" + data.transactionId.toString().toUpperCase();
    const transactionRef = admin.database().ref(transactionPath);
    let isError = false;
    let firstName = null;
    let lastName = null;
    if (data.firstName != null) {
        firstName = data.firstName;
    }
    if (data.lastName != null) {
        lastName = data.lastName;
    }
    await transactionRef.set({
        personId: data.personId,
        fineIds: data.payedFinesIds,
        approved: false,
        payDate: data.payDate,
        name: {
            first: firstName,
            last: lastName,
        },
    }, (error) => {
        isError = isError || error != null;
    });
    data.payedFinesIds.forEach((fineId) => {
        const finePayedPath = clubsPathComponent + "/" +
            data.clubId.toString().toUpperCase() +
            "/fines/" + fineId.toString().toUpperCase() + "/payed";
        const finePayedRef = admin.database().ref(finePayedPath);
        finePayedRef.update({
            state: "settled",
        }, (error) => {
            isError = isError || error != null;
        });
    });
    if (isError) {
        throw new functions.https.HttpsError("internal", "Couldn't add transaction");
    }
});
// Check all transactions
exports.checkTransactions = functions.region("europe-west1").https
    .onCall(async (data, context) => {
    // Check prerequirements
    await checkPrerequirements(["clubId"], data, context);
    const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";
    const transactionsPath = clubsPathComponent + "/" +
        data.clubId.toString().toUpperCase() + "/transactions";
    const transactionsRef = admin.database().ref(transactionsPath);
    await transactionsRef.once("value", (transactions) => {
        transactions.forEach((transaction) => {
            const isApproved = transaction.child("approved").val();
            if (!isApproved) {
                axios.default.post("https://strafen-app.ew.r.appspot.com/check_transaction", {
                    privateKey: privateKeys_1.privatePaymentKey,
                    transactionId: transaction.key,
                    debug: data["debug"] ? "debug" : null,
                }).then((response) => {
                    if (response.data.result == "settled") {
                        transaction.child("fineIds").val()
                            .forEach(async (fineId) => {
                            const finePayedPath = clubsPathComponent + "/" +
                                data.clubId.toString().toUpperCase() +
                                "/fines/" + fineId.toString().toUpperCase() + "/payed";
                            const finePayedRef = admin.database().ref(finePayedPath);
                            if (await existsData(finePayedRef)) {
                                finePayedRef.update({
                                    state: "payed",
                                    payDate: transaction.child("payDate").val(),
                                    inApp: true,
                                });
                            }
                            const approvedRef = admin.database()
                                .ref(transactionsPath + "/" +
                                transaction.key + "/approved");
                            await approvedRef.set(true);
                        });
                    }
                });
            }
        });
    });
});
exports.saveCreditCard = functions.region("europe-west1").https
    .onCall(async (data, context) => {
    await checkPrerequirements(["clubId", "personId", "information"], data, context);
    const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";
    const path = clubsPathComponent + "/" +
        data.clubId.toString().toUpperCase() + "/persons/" +
        data.personId.toString().toUpperCase() + "/creditCard";
    const ref = admin.database().ref(path);
    await ref.set(data.information);
});
/** Check if user is authorized to call a function and all arguments
 *  are hand over to this function
 *
 * @param {string[]} args - Reguiered argument for thsi function
 * @param {any} data - Data provided by function
 * @param {functions.https.CallableContext} context - Context provided by
 * @param {boolean} hasClubId -
 * function
*/
async function checkPrerequirements(args, data, context, hasClubId = true) {
    // Check if user is authorized to call a function
    if (context.auth == null) {
        throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
    }
    if (hasClubId) {
        const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";
        const path = clubsPathComponent + "/" +
            data.clubId.toString().toUpperCase() + "/personUserIds/" +
            context.auth.uid;
        const ref = admin.database().ref(path);
        if (!await existsData(ref)) {
            throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
        }
    }
    // Check if key is valid
    if (data.privateKey != privateKeys_1.privateKey) {
        throw new functions.https.HttpsError("permission-denied", "Private key is invalid.");
    }
    // Check if all arguments are hand over to this function
    for (const argument of args) {
        if (data[argument] == null) {
            throw new functions.https.HttpsError("invalid-argument", "Argument \"" + argument + "\" not found");
        }
    }
}
/** Check if data exists at path
 *
 * @param {admin.database.Reference} reference - Reference to check existence
 */
async function existsData(reference) {
    let exists = false;
    await reference.once("value", (snapshot) => {
        exists = snapshot.val() != null;
    });
    return exists;
}
//# sourceMappingURL=callableFunctions.js.map