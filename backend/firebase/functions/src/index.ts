import * as cf from "./callableFunctions";
import * as tf from "./testableFunctions";

import {getClubIdCall} from "./regularFunctions/getClubIdCall";
import {existsClubWithIdentifierCall} from "./regularFunctions/existsClubWithIdentifierCall";
import {newClubCall} from "./regularFunctions/newClubCall";
import {changeLatePaymentInterestCall} from "./regularFunctions/changeLatePaymentInterestCall";
import {registerPersonCall} from "./regularFunctions/registerPersonCall";
import {forceSignOutCall} from "./regularFunctions/forceSignOutCall";
import {changeListCall} from "./regularFunctions/changeListCall";
import {changeFinePayedCall} from "./regularFunctions/changeFinePayedCall";
import {getPersonPropertiesCall} from "./regularFunctions/getPersonPropertiesCall";
import {existsPersonWithUserIdCall} from "./regularFunctions/existsPersonWithUserIdCall";

import * as ri from "./resizeImage";

import * as admin from "firebase-admin";

admin.initializeApp();

export const newTransaction = cf.newTransaction;
export const checkTransactions = cf.checkTransactions;
export const saveCreditCard = cf.saveCreditCard;

export const getClubId = getClubIdCall;
export const existsClubWithIdentifier = existsClubWithIdentifierCall;
export const newClub = newClubCall;
export const changeLatePaymentInterest = changeLatePaymentInterestCall;
export const registerPerson = registerPersonCall;
export const forceSignOut = forceSignOutCall;
export const changeList = changeListCall;
export const changeFinePayed = changeFinePayedCall;
export const getPersonProperties = getPersonPropertiesCall;
export const existsPersonWithUserId = existsPersonWithUserIdCall;

export const generateThumbsNew = ri.generateThumbs;

export const newTestClub = tf.newTestClub;
export const deleteTestClub = tf.deleteTestClub;
export const newTestClubProperty = tf.newTestClubProperty;
export const deleteTestClubProperty = tf.deleteTestClubProperty;
