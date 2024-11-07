/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { getFirestore } from "firebase-admin/firestore";
import { initializeApp } from "firebase-admin/app";

initializeApp();

const db = getFirestore();

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

export const currencyRate = onRequest(async (request, response) => {
  logger.info("Hello logs! Small Engine 20", { structuredData: true });
  const currencyID = request.query.currencyID;
  const currencyDoc = db.doc(`currencies/${currencyID}`);
  const currency = await currencyDoc.get();
  const oldRate = currency.data()?.rate ?? 1;
  await currencyDoc.update({ rate: oldRate + 1 });
  response.send("Hello from Firebase!");
});
