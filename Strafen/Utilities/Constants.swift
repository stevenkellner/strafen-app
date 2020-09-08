//
//  Constants.swift
//  Strafen
//
//  Created by Steven on 27.06.20.
//

import Foundation

/// Json of the app urls that contains urls of the lists / changers and settings.
let appUrls = """
        {
            "baseUrl": "http://svkleinsendelbach.de/strafen_v2",
            "imagesDirectory": "images",
            "lists": {
                "person": "lists/person.json",
                "fine": "lists/fine.json",
                "reason": "lists/reason.json",
                "allClubs": "allClubs.json"
            },
            "changer": {
                "newClub": "changer/newClub.php",
                "clubImage": "changer/clubImageChanger.php",
                "registerPerson": "changer/registerPerson.php",
                "mailCode": "changer/codeMail.php",
                "personImage": "changer/personImageChanger.php",
                "personList": "changer/personChanger.php",
                "reasonList": "changer/reasonChanger.php",
                "fineList": "changer/fineChanger.php",
                "latePaymentInterest": "changer/latePaymentInterestChanger.php",
                "forceSignOut": "changer/forceSignOutChanger.php"
            },
            "authorization": "c3RldmVuOmZ5d3dlYi1yeWhrdU0tcXlneGU2",
            "key": "UM5fZEML22vzCQvMwyVN",
            "cipherKey": "3457758372438058",
            "settings": "settings.json",
            "notes": "notes.json"
        }
    """
