import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {privateKey, privatePaymentKey} from "./privateKeys";
import * as axios from "axios";

admin.initializeApp();

// Create a new club
export const newClub = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      const requiredArguements = ["clubId", "clubName", "personId",
        "personFirstName", "clubIdentifier", "userId", "signInDate",
        "regionCode", "inAppPaymentActive"];
      checkPrerequirements(requiredArguements, data, context);
      const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";

      // Check if identifier already exists
      let clubExists = false;
      await admin.database().ref(clubsPathComponent)
          .once("value", (snapshot) => {
            snapshot.forEach((club) => {
              const identifier = club.child("identifier").val();
              if (identifier == data.clubIdentifier) {
                clubExists = true;
              }
            });
          });
      if (clubExists) {
        throw new functions.https.HttpsError(
            "already-exists",
            "Club identifier already exists"
        );
      }

      // Reference to new club
      const clubPath = clubsPathComponent + "/" +
        data.clubId.toString().toUpperCase();
      const clubRef = admin.database().ref(clubPath);

      // Check if club already exists with given id
      if (await existsData(clubRef)) {
        return;
      }

      // Properties of new club
      let lastName = null;
      if (data.personLastName != null) {
        lastName = data.personLastName;
      }
      const personList: any[] = [];
      personList[data.personId.toString().toUpperCase()] = {
        name: {
          first: data.personFirstName,
          last: lastName,
        },
        signInData: {
          cashier: true,
          userId: data.userId,
          signInDate: data.signInDate,
        },
      };
      const clubProperties = {
        identifier: data.clubIdentifier,
        name: data.clubName,
        regionCode: data.regionCode,
        inAppPaymentActive: data.inAppPaymentActive,
        persons: personList,
      };

      // Set club properties
      let functionError = false;
      await clubRef.set(clubProperties, async (error) => {
        if (error != null) {
          if (await existsData(clubRef)) {
            clubRef.remove();
          }
          functionError = true;
        }
      });
      if (functionError) {
        throw new functions.https.HttpsError(
            "internal",
            "Couldn't add new club to database"
        );
      }
    });

// Delete a club
export const deleteClub = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      const requiredArguements = ["clubId"];
      checkPrerequirements(requiredArguements, data, context);
      const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";

      // Reference to new club
      const clubPath = clubsPathComponent + "/" +
        data.clubId.toString().toUpperCase();
      const clubRef = admin.database().ref(clubPath);

      // Delete club
      if (await existsData(clubRef)) {
        clubRef.remove();
      }
    });

// Change late payment interest
export const changeLatePaymentInterest = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      const requiredArguements = ["clubId"];
      checkPrerequirements(requiredArguements, data, context);
      const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";

      // Late payment interest reference
      const path = clubsPathComponent + "/" +
        data.clubId.toString().toUpperCase() + "/latePaymentInterest";
      const interestRef = admin.database().ref(path);

      try {
        // Check if late payment interest is set
        const requiredArguements = ["interestFreeValue", "interestFreeUnit",
          "interestRate", "interestValue", "interestUnit", "compoundInterest"];
        checkPrerequirements(requiredArguements, data, context);
      } catch (error) {
        // Remove late payment interest
        if (await existsData(interestRef)) {
          await interestRef.remove();
        }
        return;
      }

      // Late payment interest object
      const latePaymentInterest = {
        interestFreePeriod: {
          value: data.interestFreeValue,
          unit: data.interestFreeUnit,
        },
        interestPeriod: {
          value: data.interestValue,
          unit: data.interestUnit,
        },
        interestRate: data.interestRate,
        compoundInterest: data.compoundInterest,
      };

      // Update / set late payment interest
      if (await existsData(interestRef)) {
        await interestRef.update(latePaymentInterest);
      } else {
        await interestRef.set(latePaymentInterest);
      }
    });

// Register new person
export const registerPerson = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      const requiredArguements = ["clubId", "id", "firstName", "userId",
        "signInDate"];
      checkPrerequirements(requiredArguements, data, context);
      const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";

      // Club and person reference
      const clubPath = clubsPathComponent + "/" +
        data.clubId.toString().toUpperCase();
      const personPath = clubPath + "/persons/" + data.id.toString()
          .toUpperCase();
      const clubRef = admin.database().ref(clubPath);
      const personRef = admin.database().ref(personPath);

      // Person properties
      let lastName = null;
      if (data.lastName != null) {
        lastName = data.lastName;
      }
      const person = {
        name: {
          first: data.firstName,
          last: lastName,
        },
        signInData: {
          cashier: false,
          userId: data.userId,
          signInDate: data.signInDate,
        },
      };

      // Register Person
      let isError = false;
      if (!await existsData(personRef)) {
        await personRef.set(person, (error) => {
          isError = error != null;
        });
      } else {
        await personRef.update(person, (error) => {
          isError = error != null;
        });
      }
      if (isError) {
        throw new functions.https.HttpsError(
            "internal",
            "Couldn't add new person to database"
        );
      }

      // Return club properties
      let clubIdentifier: string | null = null;
      let clubName: string | null = null;
      let regionCode: string | null = null;
      let inAppPaymentActive: boolean = false;
      await clubRef.child("identifier").once("value", (snapshot) => {
        clubIdentifier = snapshot.val();
      });
      await clubRef.child("name").once("value", (snapshot) => {
        clubName = snapshot.val();
      });
      await clubRef.child("regionCode").once("value", (snapshot) => {
        regionCode = snapshot.val();
      });
      await clubRef.child("inAppPaymentActive").once("value", (snapshot) => {
        inAppPaymentActive = snapshot.val();
      });
      if (clubIdentifier == null || clubName == null || regionCode == null) {
        return;
      }
      return {
        clubIdentifier: clubIdentifier,
        clubName: clubName,
        regionCode: regionCode,
        inAppPaymentActive: inAppPaymentActive,
      };
    });

// Force sign out a person
export const forceSignOut = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      const requiredArguements = ["clubId", "personId"];
      checkPrerequirements(requiredArguements, data, context);
      const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";

      // Sign in data reference
      const path = clubsPathComponent + "/" +
        data.clubId.toString().toUpperCase() + "/persons/" +
        data.personId.toString().toUpperCase() + "/signInData";
      const signInDataRef = admin.database().ref(path);

      // Force sign out
      if (await existsData(signInDataRef)) {
        let isError = false;
        await signInDataRef.remove((error) => {
          isError = error != null;
        });
        if (isError) {
          throw new functions.https.HttpsError(
              "internal",
              "Couldn't force sign out at database"
          );
        }
      }
    });

// Change list item
export const changeList = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      const requiredArguements = ["clubId", "changeType", "listType",
        "itemId"];
      checkPrerequirements(requiredArguements, data, context);
      const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";

      // Get item reference
      let path = null;
      if (data.listType == "person" || data.listType == "fine" ||
        data.listType == "reason") {
        path = clubsPathComponent + "/" + data.clubId.toString().toUpperCase()+
            "/" + data.listType + "s/" + data.itemId.toString().toUpperCase();
      } else {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "List type isn't valid: " + data.listType
        );
      }
      const itemRef = admin.database().ref(path);

      // Get item
      let item = null;
      if (data.changeType != "delete") {
        if (data.listType == "person") {
          const otherArguments = ["firstName"];
          checkPrerequirements(otherArguments, data, context);
          let lastName = null;
          if (data.lastName != null) {
            lastName = data.lastName;
          }
          item = {
            name: {
              first: data.firstName,
              last: lastName,
            },
          };
        } else if (data.listType == "fine") {
          const otherArguments = ["personId", "payed", "number", "date"];
          checkPrerequirements(otherArguments, data, context);
          let reason = null;
          if (data.templateId != null) {
            reason = {
              templateId: data.templateId,
            };
          } else if (data.reason != null && data.amount != null &&
             data.importance != null) {
            reason = {
              reason: data.reason,
              amount: data.amount,
              importance: data.importance,
            };
          } else {
            throw new functions.https.HttpsError(
                "invalid-argument",
                "Fine has no valid reason"
            );
          }
          item = {
            personId: data.personId,
            payed: data.payed,
            number: data.number,
            date: data.date,
            reason: reason,
          };
        } else if (data.listType == "reason") {
          const otherArguments = ["reason", "amount", "importance"];
          checkPrerequirements(otherArguments, data, context);
          item = {
            reason: data.reason,
            amount: data.amount,
            importance: data.importance,
          };
        }
      } else if (data.changeType == "delete" && data.listType == "person") {
        if (await existsData(itemRef.child("signInData"))) {
          throw new functions.https.HttpsError(
              "unavailable",
              "Person is already signed in!"
          );
        }
      }

      // Set item
      let isError = false;
      if (item == null && data.changeType != "delete") {
        isError = true;
      } else if (data.changeType == "add") {
        if (!await existsData(itemRef)) {
          await itemRef.set(item, (error) => {
            isError = isError || error != null;
          });
        }
      } else if (data.changeType == "update") {
        if (await existsData(itemRef)) {
          await itemRef.update(item!, (error) => {
            isError = isError || error != null;
          });
        } else {
          await itemRef.set(item, (error) => {
            isError = isError || error != null;
          });
        }
      } else if (data.changeType == "delete") {
        if (await existsData(itemRef)) {
          await itemRef.remove((error) => {
            isError = isError || error != null;
          });
        }
      } else {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Change type isn't valid: " + data.changeType
        );
      }
      if (isError) {
        throw new functions.https.HttpsError(
            "internal",
            "Couldn't change item"
        );
      }
    });

// Change fine payed
export const changeFinePayed = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      const requiredArguements = ["clubId", "fineId", "payed"];
      checkPrerequirements(requiredArguements, data, context);
      const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";

      // Reference to payed
      const path = clubsPathComponent + "/" +
        data.clubId.toString().toUpperCase() + "/fines/" +
        data.fineId.toString().toUpperCase() + "/payed";
      const payedRef = admin.database().ref(path);

      // Change fine payed
      if (await existsData(payedRef)) {
        await payedRef.update(data.payed, (_) => {
          throw new functions.https.HttpsError(
              "internal",
              "Couldn't change item"
          );
        });
      }
    });

// Get club and person uuid of user id
export const getPersonProperties = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      const requiredArguements = ["userId"];
      checkPrerequirements(requiredArguements, data, context);
      const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";

      // Ref to clubs
      const clubsRef = admin.database().ref(clubsPathComponent);

      let personProperties = null;
      await clubsRef.once("value", (clubsSnapshot) => {
        clubsSnapshot.forEach((club) => {
          club.child("persons").forEach((person) => {
            const userId = person.child("signInData").child("userId").val();
            if (userId == data.userId) {
              const isCashier = person.child("signInData").child("cashier")
                  .val();
              const signInDate = person.child("signInData")
                  .child("signInDate").val();
              const firstName = person.child("name").child("first").val();
              const lastName = person.child("name").child("last").val();
              const clubName = club.child("name").val();
              const clubIdentifier = club.child("identifier").val();
              const regionCode = club.child("regionCode").val();
              personProperties = {
                clubProperties: {
                  id: club.key,
                  name: clubName,
                  identifier: clubIdentifier,
                  regionCode: regionCode,
                },
                id: person.key,
                signInDate: signInDate,
                isCashier: isCashier,
                name: {
                  firstName: firstName,
                  lastName: lastName,
                },
              };
            }
          });
        });
      });

      // Return properties
      if (personProperties == null) {
        throw new functions.https.HttpsError(
            "not-found",
            "Person doesn't exist"
        );
      } else {
        return personProperties;
      }
    });

// Get club uuid of club identifier
export const getClubId = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      const requiredArguements = ["identifier"];
      checkPrerequirements(requiredArguements, data, context);
      const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";

      // Ref to club
      const clubsRef = admin.database().ref(clubsPathComponent);

      // Get club id
      let clubId = null;
      await clubsRef.once("value", (snapshot) => {
        snapshot.forEach((child) => {
          const identifier = child.child("identifier").val();
          if (identifier == data.identifier) {
            clubId = child.key;
          }
        });
      });

      // Return club id
      if (clubId == null) {
        throw new functions.https.HttpsError(
            "not-found",
            "Club doesn't exist"
        );
      } else {
        return clubId;
      }
    });

// Check if club with given identifier already exists
export const existsClubWithIdentifier = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      const requiredArguements = ["identifier"];
      checkPrerequirements(requiredArguements, data, context);
      const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";

      // Ref to clubs
      const clubsRef = admin.database().ref(clubsPathComponent);

      // Check if exists
      let clubExists = false;
      await clubsRef.once("value", (snapshot) => {
        snapshot.forEach((child) => {
          const identifier = child.child("identifier").val();
          if (identifier == data.identifier) {
            clubExists = true;
          }
        });
      });
      return clubExists;
    });

// Check if person with user id already exists
export const existsPersonWithUserId = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      const requiredArguements = ["userId"];
      checkPrerequirements(requiredArguements, data, context);
      const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";

      // Ref to clubs
      const clubsRef = admin.database().ref(clubsPathComponent);

      // Check if exists
      let personExists = false; await clubsRef.once("value", (snapshot) => {
        snapshot.forEach((club) => {
          club.child("persons").forEach((person) => {
            const userId = person.child("signInData").child("userId").val();
            if (userId == data.userId) {
              personExists = true;
            }
          });
        });
      });
      return personExists;
    });

// Create a new transaction
export const newTransaction = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      const requiredArguements = ["clubId", "personId", "transactionId",
        "payedFinesIds", "payDate"];
      checkPrerequirements(requiredArguements, data, context);
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
      data.payedFinesIds.forEach((fineId: any) => {
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
        throw new functions.https.HttpsError(
            "internal",
            "Couldn't add transaction"
        );
      }
    });

// Check all transactions
export const checkTransactions = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      // Check prerequirements
      checkPrerequirements(["clubId"], data, context);

      const clubsPathComponent = data["debug"] ? "debugClubs" : "clubs";
      const transactionsPath = clubsPathComponent + "/" +
        data.clubId.toString().toUpperCase() + "/transactions";
      const transactionsRef = admin.database().ref(transactionsPath);

      await transactionsRef.once("value", (transactions) => {
        transactions.forEach((transaction) => {
          const isApproved = transaction.child("approved").val();
          if (!isApproved) {
            axios.default.post("https://strafen-app.ew.r.appspot.com/check_transaction", {
              privateKey: privatePaymentKey,
              transactionId: transaction.key,
              debug: data["debug"] ? "debug" : null,
            }).then((response) => {
              if (response.data.result == "settled") {
                transaction.child("fineIds").val()
                    .forEach(async (fineId: any) => {
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

export const saveCreditCard = functions.region("europe-west1").https
    .onCall(async (data, context) => {
      checkPrerequirements(["clubId", "personId", "information"],
          data, context);
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

/** Check if data exists at path
 *
 * @param {admin.database.Reference} reference - Reference to check existence
 */
async function existsData(reference: admin.database.Reference) {
  let exists = false;
  await reference.once("value", (snapshot) => {
    exists = snapshot.val() != null;
  });
  return exists;
}
