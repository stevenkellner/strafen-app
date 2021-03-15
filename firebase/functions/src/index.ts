import * as cf from "./callableFunctions";
import * as ri from "./resizeImage";
// import * as gtc from "./generateTestClub";

export const newClub = cf.newClub;
export const deleteClub = cf.deleteClub;
export const changeLatePaymentInterest = cf.changeLatePaymentInterest;
export const registerPerson = cf.registerPerson;
export const forceSignOut = cf.forceSignOut;
export const changeList = cf.changeList;
export const changeFinePayed = cf.changeFinePayed;
export const getPersonProperties = cf.getPersonProperties;
export const getClubId = cf.getClubId;
export const existsClubWithIdentifier = cf.existsClubWithIdentifier;
export const existsPersonWithUserId = cf.existsPersonWithUserId;
export const newTransaction = cf.newTransaction;
export const checkTransactions = cf.checkTransactions;

export const generateThumbs = ri.generateThumbs;

// export const generateTestClub = gtc.generateTestClub;
