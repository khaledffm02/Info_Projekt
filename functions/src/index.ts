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
import {onSchedule} from "firebase-functions/v2/scheduler";
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

// Currency Rate
// Updates the exchange rate of a specified currency

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

// Group Create
// Creates a new user group with the given name
export const groupCreate = onRequest(
  {cors: true},
  async (request, response) => {
    const {userID} = await getUserID(request);
    const member = await groupManager.getMember(userID);
    if (!member) {
      response.send({success: false});
      return;
    }
    const groupName = request.query.groupName as string;
    await groupManager.createGroup(userID, member.currency, groupName);
    response.send({success: true});
  }
);

// Group Change
// Updates the name or currency of an existing group
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

// Group Delete
// Deletes a specified group
export const groupDelete = onRequest(
  {cors: true},
  async (request, response) => {
    const groupID = request.query.groupID as string;
    await groupManager.deleteGroup(groupID);
    response.send({success: true});
  }
);

// Group Join
// Allows a user to join a group using an invitation code
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
    } else if (group.memberCount >= 10) {
      response.send({success: false, message: "Too many members"});
    } else {
      await groupManager.addMember(group.id, userID);
      response.send({success: true});
    }
  }
);

// Group Leave
// Allows a user to leave a group if their balance is zero
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

// User Login
// Handles user login and sets a preferred currency
export const userLogin = onRequest(
  {cors: true},
  async (request, response) => {
    const {userID} = await getUserID(request);
    await groupManager.userLogin(userID, {preferredCurrency: "EUR"});
    response.send({success: true});
  }
);

// User Registration
// Registers a new user with first and last name, assigning a default currency
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

// User Delete
// Deletes a user if they have no outstanding balances in any group
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

// Send New Password
// Sends a new password via email and updates the user's credentials
export const sendNewPassword = onRequest(
  {cors: true, secrets: [emailAccount, emailPassword]},
  async (request, response) => {
    const email = request.query.email as string;
    const newPassword = "C7-" + randomString(8) + "L";
    await sendMail({
      account: emailAccount.value(),
      password: emailPassword.value(),
      from: "Fairshare@project.com",
      text: `Your new password is ${newPassword}`,
      to: email,
      subject: "Your Fairshare app password was reset",
      html: `<b>Your new password is ${newPassword}</b>`,
    });

    await changeUserPassword(email, newPassword);
    response.send({success: true});
  }
);

// Create Transaction
// Creates a new financial transaction within a group, ensuring balances match
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
    await groupManager.setGroupReminder(groupID);
    response.send({success: true, transactionID: id});
    return;
  }
);

// Confirm Transaction
// Confirms a pending transaction within a group
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

// Delete Transaction
// Deletes a specified transaction from a group
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

// Add Payment
// Records a payment between two users and sends a notification email
export const addPayment = onRequest(
  {cors: true, secrets: [emailAccount, emailPassword]},
  async (request, response) => {
    const groupID = (request.query.groupID || request.query.groupId) as string;
    const fromID = (request.query.fromID || request.query.fromId) as string;
    const toID = (request.query.toID || request.query.toId) as string;
    const amount = request.query.amount as string;
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
      [{id: toID, value, isConfirmed: true}]
    );

    await sendMail({
      account: emailAccount.value(),
      password: emailPassword.value(),
      from: "Fairshare@project.com",
      text: `You have received a payment from ${fromUser.name} of ${value} EUR`,
      to: toUser.email,
      subject: "Faireshare: Payment Received",
      html: `
<b>You have received a payment from ${fromUser.name} of ${value} EUR.</b>`,
    });

    response.send({success: true, transactionID: id});
    return;
  }
);

// Add File to Transaction
// Attaches a file to a specific transaction in a group
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

// Get Group Balance
// Retrieves the balance details of a group
export const getGroupBalance = onRequest(
  {cors: true},
  async (request, response) => {
    const groupID = request.query.groupID as string;
    const {userID} = await getUserID(request);
    if (!groupID || !userID) {
      response.send({
        success: false,
        message: "Missing parameters",
        detailedMessage: {groupID, userID},
      });
      return;
    }

    const group = await groupManager.getGroup(groupID)
    if (!group) {
      response.send({success: false});
      return
    }

    response.send({balances: group.getBalances() ?? {}});
  }
);

// Update Rates
// Updates currency exchange rates using an external API
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

// Extract Information
// Extracts expense details from an uploaded receipt image using AI
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

// Send Reminders
// Sends reminder emails to users with outstanding balances in a group
export const sendReminders = onRequest(
  {cors: true, secrets: [emailAccount, emailPassword]},
  async (request, response) => {
    const groupID = request.query.groupID as string;
    if (!groupID) {
      response.send({
        success: false,
        message: "Missing parameters",
        detailedMessage: {groupID},
      });
      return;
    }
    const group = await groupManager.getGroup(groupID);
    const balances = group.getBalances();
    for (const entries of Object.entries(balances)) {
      const userID = entries[0];
      const balance = Number(entries[1]);
      if (balance > 0) {
        const user = await loadUser(userID);
        if (!user) {
          continue;
        }
        const email = user.email;
        await sendMail({
          account: emailAccount.value(),
          password: emailPassword.value(),
          from: "Fairshare@project.com",
          text: `Reminder open balance of ${balance} EUR`,
          to: email,
          subject: "Reminder of open balance",
          html: `<b>Hi ${user.name}, 
            you have open payments to take action on 
            in your group "${group.data.name}". 
            Open: ${balance} ${group.data.currency}</b>`,
        });
      }
    }

    response.send({success: true});
  }
);

// Get Login Attempts
// Retrieves the number of failed login attempts for a given email
export const getLoginAttempts = onRequest(
  {cors: true},
  async (request, response) => {
    const email = request.query.email as string;
    try {
      const value = await groupManager.getLoginAttempts(email);
      response.send({loginAttempts: value});
    } catch {
      response.send({message: "User not found"}).status(404);
      return;
    }
  }
);

// Increase Login Attempts
// Increments the failed login attempt count for a given email
export const increaseLoginAttempts = onRequest(
  {cors: true},
  async (request, response) => {
    const email = request.query.email as string;
    try {
      const success = await groupManager.increaseLoginAttempts(email);
      response.send({success});
    } catch {
      response.send({message: "User not found"}).status(404);
      return;
    }
  }
);

// Reset Login Attempts
// Resets the failed login attempt count for a given email
export const resetLoginAttempts = onRequest(
  {cors: true},
  async (request, response) => {
    const email = request.query.email as string;
    try {
      const success = await groupManager.resetLoginAttempts(email);
      response.send({success});
    } catch {
      response.send({message: "User not found"}).status(404);
      return;
    }
  }
);

// Send Invitations
// Sends an email invitation to a user to join a specific group using the group's invitation code
export const sendInvitation = onRequest(
  {cors: true, secrets: [emailAccount, emailPassword]},
  async (request, response) => {
    const groupID = request.query.groupID as string;
    const email = request.query.email as string;
    const {userID} = await getUserID(request);
    if (!groupID || !userID || !email) {
      response.send({
        success: false,
        message: "Missing parameters",
        detailedMessage: {groupID, userID, email},
      });
      return;
    }
    const group = await groupManager.getGroup(groupID);
    if (!group) {
      response.send({
        success: false,
        message: "Group not found",
        detailedMessage: {groupID},
      });
      return;
    }
    await sendMail({
      account: emailAccount.value(),
      password: emailPassword.value(),
      from: "Fairshare@project.com",
      text: `Please enter the invitation code ${group.data.groupCode}`,
      to: email,
      subject: "Invitation to join a group",
      html: `<b>Hello, 
            you have been invited to join the group "${group.data.name}".
            Please enter the invitation code ${group.data.groupCode} 
            in the app to join.</b>`,
    });

    response.send({success: true});
  }
);

// Scheduler
// A scheduled function that runs every 5 minutes to send reminders to group mmbers with outstanding balances
exports.scheduledFunctionCrontab = onSchedule("*/5 * * * *", async () => {
  const groups = await groupManager.getGroupRemindersForDate();
  const getEndpoint = (groupID: string) =>
    `https://sendreminders-icvq5uaeva-uc.a.run.app?groupID=${encodeURIComponent(groupID)}`;
  await Promise.allSettled(
    groups.map((groupID) => fetch(getEndpoint(groupID)))
  );
});

// -r. 