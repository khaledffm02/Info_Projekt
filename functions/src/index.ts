/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {onRequest} from "firebase-functions/v2/https";
import {changeUserPassword, getUserID, loadUser} from "./auth";
import {defineSecret} from "firebase-functions/params";
import {GroupManager} from "./managers/GroupManager";
import {sendMail} from "./mail";
import {randomString} from "./utils/random-string";
import {gpt} from "./gpt";

const discordApiKey = defineSecret("beispiel");
const emailAccount = defineSecret("account");
const emailPassword = defineSecret("password");
const openaiToken = defineSecret("openaiToken");
const currencyKey = defineSecret("currencyKey");

initializeApp();

const db = getFirestore();
const groupManager = new GroupManager(db);

export const currencyRate = onRequest(
  {cors: true, secrets: [discordApiKey]},
  async (request, response) => {
    logger.info("Hello logs! Small Engine 20", {structuredData: true});
    const {userID} = await getUserID(request);
    const currencyID = request.query.currencyID;
    const currencyDoc = db.doc(`currencies/${currencyID}`);
    const currency = await currencyDoc.get();
    const oldRate = currency.data()?.rate ?? 1;
    await currencyDoc.update({rate: oldRate + 1});
    response.send("Hello from Firebase!" + discordApiKey.value() + userID);
  }
);

export const groupCreate = onRequest(
  {cors: true},
  async (request, response) => {
    const {userID} = await getUserID(request);
    const member = await groupManager.getMember(userID);
    if (!member) {
      response.send({success: false});
      return;
    }
    await groupManager.createGroup(userID, member.currency);
    response.send({success: true});
  }
);

export const groupChange = onRequest(
  {cors: true},
  async (request, response) => {
    await getUserID(request);
    const groupID = request.query.groupID as string;
    if (!groupID) {
      response.send({success: false, message: "Missing groupID"});
      return;
    }
    const groupName = request.query.groupName as string | undefined;
    const groupCurrency = request.query.groupCurrency as string | undefined;
    const group = await groupManager.getGroup(groupID);
    if (!group) {
      response.send({success: false, message: "Group not found"});
      return;
    }
    await groupManager.changeGroup(groupID, {
      name: groupName,
      currency: groupCurrency,
    });
    response.send({success: true});
  }
);

export const groupDelete = onRequest(
  {cors: true},
  async (request, response) => {
    const groupID = request.query.groupID as string;
    await groupManager.deleteGroup(groupID);
    response.send({success: true});
  }
);

export const groupJoin = onRequest(
  {cors: true},
  async (request, response) => {
    const groupCode = request.query.groupCode as string;
    if (!groupCode) {
      response.send({success: false});
      return;
    }
    const {userID} = await getUserID(request);
    const group = await groupManager.getGroupByCode(groupCode);
    if (!group) {
      response.send({success: false});
    } else {
      await groupManager.addMember(group.id, userID);
      response.send({success: true});
    }
  }
);

export const groupLeave = onRequest(
  {cors: true},
  async (request, response) => {
    const groupID = request.query.groupID as string;
    if (!groupID) {
      response.send({success: false});
      return;
    }
    const {userID} = await getUserID(request);
    const group = await groupManager.getGroup(groupID);

    if (group.getBalanceForUser(userID) !== 0) {
      response.send({success: false});
    } else {
      await groupManager.removeMember(group.id, userID);
      response.send({success: true});
    }
  }
);

export const userLogin = onRequest(
  {cors: true},
  async (request, response) => {
    const {userID} = await getUserID(request);
    await groupManager.userLogin(userID, {preferredCurrency: "EUR"});
    response.send({success: true});
  }
);

export const userRegistration = onRequest(
  {cors: true},
  async (request, response) => {
    const {userID} = await getUserID(request);
    const firstName = request.query.firstName as string;
    const lastName = request.query.lastName as string;
    await groupManager.userRegistration(userID, {
      firstName,
      lastName,
      currency: "EUR",
    });
    response.send({success: true});
  }
);

export const userDelete = onRequest(
  {cors: true},
  async (request, response) => {
    const {userID} = await getUserID(request);
    const groups = await groupManager.getGroupsForUser(userID);
    const hasZeroBalance = groups.every(
      (group) => group.getBalanceForUser(userID) === 0
    );
    if (!hasZeroBalance) {
      response.send({success: false});
      return;
    }
    await groupManager.deleteUser(userID);
    response.send({success: userID});
  }
);

export const sendNewPassword = onRequest(
  {cors: true, secrets: [emailAccount, emailPassword]},
  async (request, response) => {
    const email = request.query.email as string;
    const newPassword = "C7-" + randomString(8) + "L";
    await sendMail({
      account: emailAccount.value(),
      password: emailPassword.value(),
      from: "splidapp@project.com",
      text: `Your new password is ${newPassword}`,
      to: email,
      subject: "Your splid-like app password was reset",
      html: `<b>Your new password is ${newPassword}</b>`,
    });

    await changeUserPassword(email, newPassword);
    response.send({success: true});
  }
);

export const createTransaction = onRequest(
  {cors: true},
  async (request, response) => {
    const parameters = decodeURIComponent(request.query.request as string);
    const {userID} = await getUserID(request);
    if (!parameters || !userID) {
      response.send({success: false});
      return;
    }
    const {groupID, title, category, user, friends, storageURL} = JSON.parse(
      parameters
    ) as {
      groupID: string;
      title: string;
      category: string;
      storageURL?: string;
      user: { id: string; value: number };
      friends: { id: string; value: number }[];
    };
    if (!groupID || !title || !user || !friends) {
      response.send({
        success: false,
        message: "Missing parameters",
        detailedMessage: {groupID, title, category, user, friends},
      });
      return;
    }
    const payed = user.value;
    const spend = friends.reduce((acc, f) => acc + f.value, 0);
    if (payed !== spend) {
      response.send({
        success: false,
        message: "Sum of friends' values must be equal to user's value",
        detailedMessage: {payed, spend},
      });
      return;
    }
    const id = await groupManager.createTransaction(
      groupID,
      {title, category, storageURL},
      user,
      friends
    );
    response.send({success: true, transactionID: id});
    return;
  }
);

export const confirmTransaction = onRequest(
  {cors: true},
  async (request, response) => {
    const groupID = request.query.groupID as string;
    const transactionID = request.query.transactionID as string;
    const {userID} = await getUserID(request);
    if (!groupID || !transactionID || !userID) {
      response.send({
        success: false,
        message: "Missing parameters",
        detailedMessage: {groupID, transactionID, userID},
      });
      return;
    }
    await groupManager.confirmTransaction(groupID, transactionID, userID);
    response.send({success: true});
    return;
  }
);

export const deleteTransaction = onRequest(
  {cors: true},
  async (request, response) => {
    const groupID = request.query.groupID as string;
    const transactionID = request.query.transactionID as string;
    if (!groupID || !transactionID) {
      response.send({
        success: false,
        message: "Missing parameters",
        detailedMessage: {groupID, transactionID},
      });
      return;
    }
    await groupManager.deleteTransaction(groupID, transactionID);
    response.send({success: true});
    return;
  }
);

export const addPayment = onRequest(
  {cors: true, secrets: [emailAccount, emailPassword]},
  async (request, response) => {
    const groupID = request.query.groupID as string;
    const fromID = request.query.fromID as string;
    const toID = request.query.toID as string;
    const amount = request.query.value as string;
    const {userID} = await getUserID(request);
    if (!groupID || !userID || !fromID || !toID || !amount) {
      response.send({
        success: false,
        message: "Missing parameters",
        detailedMessage: {groupID, fromID, toID, userID, amount},
      });
      return;
    }

    const fromUser = await loadUser(fromID);
    const toUser = await loadUser(toID);
    if (!fromUser || !toUser) {
      response.send({
        success: false,
        message: "Users not found",
        detailedMessage: {fromUser, toUser},
      });
      return;
    }

    const value = Number(amount);

    const id = await groupManager.createTransaction(
      groupID,
      {title: "_payment", category: "payment"},
      {id: fromID, value},
      [{id: toID, value}]
    );

    await sendMail({
      account: emailAccount.value(),
      password: emailPassword.value(),
      from: "splidapp@project.com",
      text: `You have received a payment from ${fromUser.name} of ${value}`,
      to: toUser.email,
      subject: "You have received a payment",
      html: `
<b>You have received a payment from ${fromUser.name} of ${value}</b>`,
    });

    response.send({success: true, transactionID: id});
    return;
  }
);

export const addFileToTransaction = onRequest(
  {cors: true},
  async (request, response) => {
    const groupID = request.query.groupID as string;
    const transactionID = request.query.transactionID as string;
    const fileName = request.query.fileName as string;
    const {userID} = await getUserID(request);
    if (!groupID || !userID || !transactionID) {
      response.send({
        success: false,
        message: "Missing parameters",
        detailedMessage: {groupID, userID, transactionID, fileName},
      });
      return;
    }

    await groupManager.addFileToTransaction(groupID, transactionID, fileName);

    response.send({success: true});
    return;
  }
);

export const updateRates = onRequest(
  {cors: true, secrets: [currencyKey]},
  async (request, response) => {
    const {userID} = await getUserID(request);
    if (!userID) {
      response.send({
        success: false,
        message: "Missing parameters",
        detailedMessage: {userID},
      });
      return;
    }

    await groupManager.updateCurrencyRates(currencyKey.value());
    response.send({success: true});

    return;
  }
);

export const extractInformation = onRequest(
  {cors: true, secrets: [openaiToken]},
  async (request, response) => {
    const fileName = request.query.fileName as string;
    const {userID} = await getUserID(request);
    if (!fileName || !userID) {
      response.send({
        success: false,
        message: "Missing parameters",
        detailedMessage: {fileName, userID},
      });
      return;
    }

    const url = `https://storage.googleapis.com/projekt-24-a9104.firebasestorage.app/images/${fileName}`;
    const text = `Could you please extract the overall amount paid 
    from this picture of a recipe. And please put it in one of these
    categories: "Food", "Vacation", "Transportation", "Other".
    The title should be a descriptive title for this expense.
    Could you please provide me with a JSON in the form of
     {title: string; category: string; amount: number}`;

    const result = await gpt(
      [
        {
          role: "user",
          content: [
            {type: "text", text},
            {type: "image_url", image_url: {url}},
          ],
        },
      ],
      500,
      true,
      "gpt-4o",
      openaiToken.value()
    );

    if (!result) {
      response.send({success: false});
      return;
    }
    const {title, category, amount} = JSON.parse(result);
    response.send({success: true, title, category, amount});

    return;
  }
);
