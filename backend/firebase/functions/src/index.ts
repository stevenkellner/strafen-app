import * as cf from "./callableFunctions";
import * as tf from "./testableFunctions";

import {getClubIdCall} from "./regularFunctions/getClubIdCall";
import {existsClubWithIdentifierCall} from "./regularFunctions/existsClubWithIdentifierCall";
import {newClubCall} from "./regularFunctions/newClubCall";

import * as admin from "firebase-admin";

admin.initializeApp();

export const deleteClub = cf.deleteClub;
export const changeLatePaymentInterest = cf.changeLatePaymentInterest;
export const registerPerson = cf.registerPerson;
export const forceSignOut = cf.forceSignOut;
export const changeList = cf.changeList;
export const changeFinePayed = cf.changeFinePayed;
export const getPersonProperties = cf.getPersonProperties;
export const existsPersonWithUserId = cf.existsPersonWithUserId;
export const newTransaction = cf.newTransaction;
export const checkTransactions = cf.checkTransactions;
export const saveCreditCard = cf.saveCreditCard;

export const getClubId = getClubIdCall;
export const existsClubWithIdentifier = existsClubWithIdentifierCall;
export const newClub = newClubCall;

export const newTestClub = tf.newTestClub;
export const deleteTestClub = tf.deleteTestClub;
export const newTestClubProperty = tf.newTestClubProperty;
export const deleteTestClubProperty = tf.deleteTestClubProperty;
