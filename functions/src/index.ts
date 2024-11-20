/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { defineSecret } from "firebase-functions/params";
import { GroupManager } from "./managers/GroupManager";

const discordApiKey = defineSecret("beispiel");

initializeApp();

const db = getFirestore();
const groupManager = new GroupManager(db);

export const currencyRate = onRequest(
  { cors: true, secrets: [discordApiKey] },
  async (request, response) => {
    logger.info("Hello logs! Small Engine 20", { structuredData: true });
    const { userID } = await getUserID(request);
    const currencyID = request.query.currencyID;
    const currencyDoc = db.doc(`currencies/${currencyID}`);
    const currency = await currencyDoc.get();
    const oldRate = currency.data()?.rate ?? 1;
    await currencyDoc.update({ rate: oldRate + 1 });
    response.send("Hello from Firebase!" + discordApiKey.value() + userID);
  }
);

export const groupCreate = onRequest(
  { cors: true },
  async (request, response) => {
    const { userID } = await getUserID(request);
    const member = await groupManager.getMember(userID);
    if (!member) {
      response.send({ success: false });
      return
    }
    await groupManager.createGroup(userID, member.currency);
    response.send({ success: true });
  }
);

export const groupDelete = onRequest(
  { cors: true },
  async (request, response) => {
    const groupID = request.query.groupID as string;
    await groupManager.deleteGroup(groupID);
    response.send({ success: true });
  }
);

export const groupJoin = onRequest(
  { cors: true },
  async (request, response) => {
    const groupCode = request.query.groupCode as string;
    if (!groupCode) {
      response.send({ success: false });
      return;
    }
    const { userID } = await getUserID(request);
    const group = await groupManager.getGroupByCode(groupCode);
    if (!group) {
      response.send({ success: false });
    } else {
      await groupManager.addMember(group.id, userID);
      response.send({ success: true });
    }
  }
);

export const groupLeave = onRequest(
  { cors: true },
  async (request, response) => {
    const groupID = request.query.groupID as string;
    if (!groupID) {
      response.send({ success: false });
      return;
    }
    const { userID } = await getUserID(request);
    const group = await groupManager.getGroup(groupID);

    if (group.getBalanceForUser(userID) !== 0) {
      response.send({ success: false });
    } else {
      await groupManager.removeMember(group.id, userID);
      response.send({ success: true });
    }
  }
);

export const userLogin = onRequest(
  { cors: true },
  async (request, response) => {
    const { userID } = await getUserID(request);
    await groupManager.userLogin(userID, {preferredCurrency: 'EUR'});
    response.send({ success: true });
  }
);
