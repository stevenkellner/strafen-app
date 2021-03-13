import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {privateKey} from "./privateKeys";
import {Guid} from "guid-typescript";

export const generateTestClub = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      checkPrerequirements([], data, context);
      const possibleImportancies = ["low", "medium", "high"];
      const possiblePayed = ["payed", "unpayed", "settled"];

      const reasons = [...Array(Math.floor(50 + Math.random() * 50)).keys()]
          .reduce((dict, index) => {
            return {...dict, [Guid.create().toString()]: {
              importance: possibleImportancies[Math.floor(Math.random() *
            possibleImportancies.length)],
              amount: Math.floor(Math.random() * 10000) * 0.01,
              reason: `Reason template ${index}`,
            }};
          }, {});

      let hasCashier = false;
      const persons = [...Array(Math.floor(50 + Math.random() * 50)).keys()]
          .reduce((dict, index) => {
            const name = Math.random() > 0.5 ? {
              first: `Person ${index}`,
            } : {
              first: "Test",
              last: `Person ${index}`,
            };
            const signInData = Math.random() > 0.5 ? null : {
              cashier: !hasCashier,
              signInDate: Math.random() * 600000000,
              userId: hasCashier ? `user_id_${index}` :
                "Yyqkz1SOYEbsqyPeJpxVVKCgzS33",
            };
            hasCashier = true;
            return {...dict, "9499ac8b-7dc2-41a1-addb-6ee5ab0ed966": {
              name: name,
              signInData: signInData,
            }};
          }, {});

      const fines = [...Array(Math.floor(100 + Math.random() * 100)).keys()]
          .reduce((dict, index) => {
            const payedState = possiblePayed[Math.floor(Math.random() *
            possiblePayed.length)];
            const payed = {
              state: payedState,
              payDate: payedState == "payed" ? Math.random() * 600000000 : null,
            };
            const personId = Object.keys(persons)[Math.floor(Math.random() *
            Object.keys(persons).length)];
            const reason = Math.random() > 0.5 ? {
              templateId: Object.keys(reasons)[Math.floor(Math.random() *
            Object.keys(reasons).length)],
            } : {
              importance: possibleImportancies[Math.floor(Math.random() *
            possibleImportancies.length)],
              amount: Math.floor(Math.random() * 10000) * 0.01,
              reason: `Fine ${index}`,
            };
            return {...dict, [Guid.create().toString()]: {
              date: Math.random() * 600000000,
              number: Math.floor(1 + Math.random() * 9),
              payed: payed,
              personId: personId,
              reason: reason,
            }};
          }, {});

      const club = {
        identifier: Guid.create().toString(),
        inAppPaymentActive: true,
        name: "Test club",
        regionCode: "DE",
        fines: fines,
        persons: persons,
        reasons: reasons,
      };

      const clubRef = admin.database().ref(`clubs/${Guid.create()
          .toString()}`);
      await clubRef.set(club);
    });

/** Check if user is authorized to call a function and all arguments
 *  are hand over to this function
 *
 * @param {string[]} args - Reguiered argument for thsi function
 * @param {any} data - Data provided by function
 * @param {functions.https.CallableContext} context - Context provided by
 * function
*/
function checkPrerequirements(args: string[], data: any,
    context: functions.https.CallableContext) {
  // Check if user is authorized to call a function
  if (context.auth == null) {
    throw new functions.https.HttpsError(
        "failed-precondition",
        "The function must be called while authenticated."
    );
  }

  // Check if key is valid
  if (data.privateKey != privateKey) {
    throw new functions.https.HttpsError(
        "permission-denied",
        "Private key is invalid."
    );
  }

  // Check if all arguments are hand over to this function
  for (const argument of args) {
    if (data[argument] == null) {
      throw new functions.https.HttpsError(
          "invalid-argument",
          "Argument \"" + argument + "\" not found"
      );
    }
  }
}
