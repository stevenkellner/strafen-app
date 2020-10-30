const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

let transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 465,
    auth: {
        user: 'strafen.no.reply@gmail.com',
        pass: 'rircy1-fybrEg-fawcaq'
    }
});

// Create a new club
exports.newClub = functions.region('europe-west1').https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'failed-precondition', 
            'The function must be called while authenticated.'
        );
      }

    // Check if all arguments are set
    let requiredArguements = ['clubId', 'clubName', 'personId', 'personFirstName', 'personLastName', 'clubIdentifier', 'userId', 'signInDate'];
    checkAllArguments(requiredArguements, data);

    // Add club to allClubs
    let clubPath = 'clubs/' + data.clubId.toString().toUpperCase();
    let clubRef = admin.database().ref(clubPath);

    // Check if identifier already exists
    let clubExists = false;
    await admin.database().ref('clubs').once('value', snapshot => {
        snapshot.forEach(child => {
            let identifier = child.child('identifier').val();
            if (identifier == data.clubIdentifier) {
                clubExists = true;
            }
        });
    });
    if (clubExists) {
        throw new functions.https.HttpsError(
            'already-exists', 
            "Club identifier already exists"
        );
    } 

    if (!await existsData(clubRef)) {
        let isError = false;
        await clubRef.child('identifier').set(data.clubIdentifier, error => {
            isError = isError || error != null;
        });
        await clubRef.child('name').set(data.clubName, error => {
            isError = isError || error != null;
        });
        await clubRef.child('persons').child(data.personId.toString().toUpperCase()).set({
            name: {
                first: data.personFirstName,
                last: data.personLastName
            },
            cashier: true,
            userId: data.userId,
            signInDate: data.signInDate
        }, error => {
            isError = isError || error != null;
        });
        if (isError) {
            await clubRef.remove();
            throw new functions.https.HttpsError(
                'internal', 
                "Couldn't add new club to database" 
             );
        }
    }
});

// Change late payment interest
exports.changeLatePaymentInterest = functions.region('europe-west1').https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'failed-precondition', 
            'The function must be called while authenticated.'
        );
      }
      
    // Check if clubId is set
    checkAllArguments(['clubId'], data);

    // Late payment interest reference
    let path = 'clubs/' + data.clubId.toString().toUpperCase() + '/latePaymentInterest';
    let interestRef = admin.database().ref(path);

    try {

        // Check if late payment interest is set
        let requiredArguements = ['interestFreeValue', 'interestFreeUnit', 'interestRate', 'interestValue', 'interestUnit', 'compoundInterest'];
        checkAllArguments(requiredArguements, data);

        // Late payment interest object
        let latePaymentInterest = {
            interestFreePeriod: {
                value: data.interestFreeValue,
                unit: data.interestFreeUnit
            },
            interestPeriod: {
                value: data.interestValue,
                unit: data.interestUnit
            },
            interestRate: data.interestRate,
            compoundInterest: data.compoundInterest
        };

        // Update / set late payment interest
        if (await existsData(interestRef)) {
            await interestRef.update(latePaymentInterest);
        } else {
            await interestRef.set(latePaymentInterest);
        }

    } catch (error) {

        // Remove late payment interest
        if (await existsData(interestRef)) {
            await interestRef.remove();
        }

    }

});

// Register new person
exports.registerPerson = functions.region('europe-west1').https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'failed-precondition', 
            'The function must be called while authenticated.'
        );
      }
      
    // Check if all arguments are set
    let requiredArguements = ['clubId', 'id', 'firstName', 'lastName', 'userId', 'signInDate'];
    checkAllArguments(requiredArguements, data);

    // Get person reference
    let path = 'clubs/' + data.clubId.toString().toUpperCase() + '/persons/' + data.id.toString().toUpperCase();
    let personRef = admin.database().ref(path);
    
    let isError = false;
    let person = {
        name: {
            first: data.firstName,
            last: data.lastName
        },
        cashier: false,
        userId: data.userId,
        signInDate: data.signInDate
    };
    if (!await existsData(personRef)) {
        await personRef.set(person, error => {
            isError = error != null;
        });
    } else {
        await personRef.update(person, error => {
            isError = error != null;
        })
    }
    if (isError) {
        throw new functions.https.HttpsError(
            'internal', 
            "Couldn't add new person to database" 
         );
    }
});

// Force sign out a person
exports.forceSignOut = functions.region('europe-west1').https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'failed-precondition', 
            'The function must be called while authenticated.'
        );
      }
      
    // Check if all arguments are set
    let requiredArguements = ['clubId', 'personId'];
    checkAllArguments(requiredArguements, data);

    // Get cashier reference
    let path = 'clubs/' + data.clubId.toString().toUpperCase() + '/persons/' + data.personId.toString().toUpperCase() + '/cashier';
    let cashierRef = admin.database().ref(path);

    if (await existsData(cashierRef)) {
        let isError = false;
        await cashierRef.remove(error => {
            isError = error != null;
        });
        if (isError) {
            throw new functions.https.HttpsError(
                'internal', 
                "Couldn't force sign out at database" 
             );
        }
    }

});

// Change list item
exports.changeList = functions.region('europe-west1').https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'failed-precondition', 
            'The function must be called while authenticated.'
        );
      }
      
    // Check if all arguments are set
    let requiredArguements = ['clubId', 'changeType', 'listType', 'itemId'];
    checkAllArguments(requiredArguements, data);

    // Get item reference
    let path = null;
    if (data.listType == 'person' || data.listType == 'fine' || data.listType == 'reason') {
        path = 'clubs/' + data.clubId.toString().toUpperCase() + '/' + data.listType + 's/' + data.itemId.toString().toUpperCase();
    } else {
        throw new functions.https.HttpsError(
            'invalid-argument', 
            "List type isn't valid: " + data.listType
         );
    }
    let itemRef = admin.database().ref(path);

    // Get item
    let item = null;
    if (data.changeType != 'delete') {
        if (data.listType == 'person') {
            let otherArguments = ['firstName', 'lastName'];
            checkAllArguments(otherArguments, data);
            item = {
                name: {
                    first: data.firstName,
                    last: data.lastName
                }
            }
        } else if (data.listType == 'fine') {
            let otherArguments = ['personId', 'payed', 'number', 'date'];
            checkAllArguments(otherArguments, data);
            let reason = null 
            if (data.templateId != null) {
                reason = {
                    templateId: data.templateId
                }
            } else if (data.reason != null && data.amount != null && data.importance != null) {
                reason = {
                    reason: data.reason,
                    amount: data.amount,
                    importance: data.importance
                }
            } else {
                throw new functions.https.HttpsError(
                    'invalid-argument', 
                    'Fine has no valid reason'
                 );
            }
            item = {
                personId: data.personId,
                payed: data.payed,
                number: data.number,
                date: data.date,
                reason: reason
            }
        } else if (data.listType == 'reason') {
            let otherArguments = ['reason', 'amount', 'importance'];
            checkAllArguments(otherArguments, data);
            item = {
                reason: data.reason,
                amount: data.amount,
                importance: data.importance
            }
        }
    }

    // Set item
    let isError = null;
    if (data.changeType == 'add') {
        if (!await existsData(itemRef)) {
            await itemRef.set(item, error => {
                isError = isError || error != null;
            });
        }
    } else if (data.changeType == 'update') {
        if (await existsData(itemRef)) {
            await itemRef.update(item, error => {
                isError = isError || error != null;
            });
        } else {
            await itemRef.set(item, error => {
                isError = isError || error != null;
            });
        }
    } else if (data.changeType == 'delete') {
        if (await existsData(itemRef)) {
            await itemRef.remove(error => {
                isError = isError || error != null;
            })
        }
    } else {
        throw new functions.https.HttpsError(
            'invalid-argument', 
            "Change type isn't valid: " + data.changeType
         );
    }
    if (isError) {
        throw new functions.https.HttpsError(
            'internal', 
            "Couldn't change item"
         );
    }
});

// Send mail
exports.sendMail = functions.region('europe-west1').https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'failed-precondition', 
            'The function must be called while authenticated.'
        );
      }
      
    // Check if all arguments are set
    checkAllArguments(['email'], data);

    let mailOptions = {
        from: "Test Account Name",
        to: data.email,
        subject: "Test Subject",
        html:  `<p style="font-size: 16px;">Pickle Riiiiiiiiiiiiiiiick!!</p>
                <br />
                <img src="https://images.prod.meredith.com/product/fc8754735c8a9b4aebb786278e7265a5/1538025388228/l/rick-and-morty-pickle-rick-sticker" />`
    
    };

    let isError = false;
    await transporter.sendMail(mailOptions, (error, info) => {
        console.info(error);
        console.info(info);
        console.info(mailOptions);
        if (error) {
            isError = true;
        } 
    });
    if (isError) {
        throw new functions.https.HttpsError(
            'internal', 
            "Couldn't send email" 
         );
    }
});

// Get club uuid of club identifier
exports.getClubId = functions.region('europe-west1').https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'failed-precondition', 
            'The function must be called while authenticated.'
        );
    }
      
    // Check if all arguments are set
    checkAllArguments(['identifier'], data);

    let clubsRef = admin.database().ref('clubs');
    var clubId = null;
    await clubsRef.once('value', snapshot => {
        snapshot.forEach(child => {
            let identifier = child.child('identifier').val();
            if (identifier == data.identifier) {
                clubId = child.key;
            }
        });
    });
    if (clubId == null) {
        throw new functions.https.HttpsError(
            'not-found', 
            "Club doesn't exist"
         );
    } else {
        return clubId;
    }
});

// Get club and person uuid of user id
exports.getClubPersonId = functions.region('europe-west1').https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'failed-precondition', 
            'The function must be called while authenticated.'
        );
    }

    // Check if all arguments are set
    checkAllArguments(['userId'], data);

    let clubsRef = admin.database().ref('clubs');
    var clubPersonId = null;
    await clubsRef.once('value', clubsSnapshot => {
        clubsSnapshot.forEach(club => {
            club.child('persons').forEach(person => {
                let userId = person.child('userId').val()
                if (userId == data.userId) {
                    clubPersonId = {
                        clubId: club.key,
                        personId: person.key                        
                    }
                }
            });
        });
    });
    if (clubPersonId == null) {
        throw new functions.https.HttpsError(
            'not-found', 
            "Person doesn't exist"
         );
    } else {
        return clubPersonId;
    }
});

// Check if club with given identifier already exists
exports.existsClubWithIdentifier = functions.region('europe-west1').https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'failed-precondition', 
            'The function must be called while authenticated.'
        );
      }
      
    // Check if all arguments are set
    checkAllArguments(['identifier'], data);

    let clubsRef = admin.database().ref('clubs');
    var clubExists = false;
    await clubsRef.once('value', snapshot => {
        snapshot.forEach(child => {
            let identifier = child.child('identifier').val();
            if (identifier == data.identifier) {
                clubExists = true;
            }
        });
    });
    return clubExists;
});

// Check if data exists at path
async function existsData(reference) {
    let exists = false;
    await reference.once('value', snapshot => {
        exists = snapshot.val() != null;
    });
    return exists;
}

// Check if all arguments are set
function checkAllArguments(arguments, data) {
    for (argument of arguments) {
        checkArgument(argument, data);
    }
}

// Check if an argument is set
function checkArgument(argument, data) {
    if (data[argument] == null) {
        throw new functions.https.HttpsError(
            'invalid-argument', 
            'Argument "' + argument + '" not found' 
         );
    }
}