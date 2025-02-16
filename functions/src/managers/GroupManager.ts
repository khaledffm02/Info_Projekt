/* eslint-disable camelcase */
import {loadUser} from "../auth";
import {Group, GroupJSON} from "../models/Group";
import {randomString} from "../utils/random-string";
import {
  transactionToJson,
  Transaction,
  transactionFromJson,
} from "../models/Transaction";
import {FieldValue} from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";

// Define the GroupManager class
//Constructor to initialize the class with a Firestore database
export class GroupManager {
  constructor(readonly db: FirebaseFirestore.Firestore) {}

  // Create Group
  async createGroup(creatorID: string, currency: string, name?: string): Promise<string> {
    const creationTimestamp = Date.now();
    const groupCode = randomString(6).toUpperCase();
    const memberIDs = {[creatorID]: true};
    const groupJSON = {
      creatorID,
      creationTimestamp,
      groupCode,
      memberIDs,
      currency,
      name: name || `Group ${groupCode}`,
    };
    const groupRef = await this.db.collection("groups").add(groupJSON);
    return groupRef.id;
  }

  // Get Group
  async getGroup(id: string): Promise<Group> {
    const groupDoc = await this.db.collection("groups").doc(id).get();
    if (!groupDoc.exists) {
      throw new Error(`Group with ID ${id} not found`);
    }
    return new Group(groupDoc.id, groupDoc.data() as GroupJSON);
  }

  // Get Group By Code
  async getGroupByCode(groupCode: string): Promise<Group | undefined> {
    const group = await this.db
      .collection("groups")
      .where("groupCode", "==", groupCode)
      .get();
    if (group.docs.length === 0) {
      return;
    }
    const doc = group.docs[0];
    return new Group(doc.id, doc.data() as GroupJSON);
  }

  // Add Member (to group)
  async addMember(groupID: string, memberID: string): Promise<void> {
    const groupRef = this.db.collection("groups").doc(groupID);
    await groupRef.update({
      [`memberIDs.${memberID}`]: true,
    });
  }

  // Remove member
  async removeMember(groupID: string, memberID: string): Promise<void> {
    const groupRef = this.db.collection("groups").doc(groupID);
    await groupRef.update({
      [`memberIDs.${memberID}`]: false,
    });
  }

  // Delete Group
  async deleteGroup(id: string): Promise<void> {
    await this.db.collection("groups").doc(id).delete();
  }

  // Get Groups For User
  async getGroupsForUser(userID: string): Promise<Group[]> {
    const groupDocs = await this.db
      .collection("groups")
      .where(`memberIDs.${userID}`, "==", true)
      .get();
    return groupDocs.docs.map(
      (doc) => new Group(doc.id, doc.data() as GroupJSON)
    );
  }

  // Change/Edit Group
  async changeGroup(
    groupID: string,
    changes: { name?: string; currency?: string }
  ): Promise<void> {
    if (changes.name === undefined && changes.currency === undefined) {
      return;
    }
    const groupRef = this.db.collection("groups").doc(groupID);
    await groupRef.update({
      ...(changes.name ? {name: changes.name} : {}),
      ...(changes.currency ? {currency: changes.currency} : {}),
    });
  }

  // User Login
  async userLogin(
    userID: string,
    options?: { preferredCurrency: string }
  ): Promise<void> {
    const userDoc = this.db.collection("users").doc(userID);
    const [userRaw, authUser] = await Promise.all([
      userDoc.get(),
      loadUser(userID),
    ]);
    if (!authUser) {
      throw new Error(`User with ID ${userID} not found`);
      return;
    }
    if (!userRaw.exists) {
      await userDoc.set({
        ...(options?.preferredCurrency ?
          {currency: options?.preferredCurrency} :
          {}),
        name: authUser.name,
        email: authUser.email,
      });
    } else if (options?.preferredCurrency !== userRaw.data()?.currency) {
      await userDoc.update({
        currency: options?.preferredCurrency,
      });
    }
  }

  // User Registration
  async userRegistration(
    userID: string,
    options: { firstName: string; lastName: string; currency: string }
  ): Promise<void> {
    const userDoc = this.db.collection("users").doc(userID);
    const [userRaw, authUser] = await Promise.all([
      userDoc.get(),
      loadUser(userID),
    ]);
    if (!authUser) {
      throw new Error(`User with ID ${userID} not found`);
    }
    if (!userRaw.exists) {
      await userDoc.set({
        firstName: options.firstName,
        lastName: options.lastName,
        currency: options.currency,
        email: authUser.email,
      });
    } else {
      await userDoc.update({
        firstName: options.firstName,
        lastName: options.lastName,
        currency: options.currency,
        email: authUser.email,
      });
    }
  }

  // Get Member
  async getMember(
    userID: string
  ): Promise<undefined | { name: string; currency: string }> {
    const userDoc = await this.db.collection("users").doc(userID).get();
    if (!userDoc.exists) {
      return;
    }
    const {name, currency} = userDoc.data() ?? {};
    return {name, currency};
  }

  // Create Transaction
  async createTransaction(
    groupID: string,
    meta: { title: string; category?: string; storageURL?: string },
    user: { id: string; value: number },
    friends: { id: string; value: number; isConfirmed?: boolean }[]
  ) {
    const groupRef = this.db.collection("groups").doc(groupID);
    const transactionID = randomString(16);
    await groupRef.update({
      [`transactions.${transactionID}`]: transactionToJson(
        new Transaction(
          {
            category: meta.category ?? "",
            title: meta.title,
            storageURL: meta.storageURL || "",
            timestamp: Date.now(),
          },
          {userID: user.id, value: user.value},
          Object.fromEntries(
            friends.map((f) => [
              f.id,
              {
                value: f.value,
                isConfirmed:
                  f.id === user.id || !!f.isConfirmed,
              },
            ])
          )
        )
      ),
    });
    return transactionID;
  }

  // Delete Transaction
  async deleteTransaction(groupID: string, transactionID: string) {
    const groupRef = this.db.collection("groups").doc(groupID);
    await groupRef.update({
      [`transactions.${transactionID}`]: FieldValue.delete(),
    });
    return;
  }

  // Add File to Transaction
  async addFileToTransaction(
    groupID: string,
    transactionID: string,
    fileName: string
  ) {
    const groupRef = this.db.collection("groups").doc(groupID);
    await groupRef.update({
      [`transactions.${transactionID}.meta.storageURL`]:
        fileName || FieldValue.delete(),
    });
    return;
  }

  // Confirm Transaction
  async confirmTransaction(
    groupID: string,
    transactionID: string,
    userID: string
  ) {
    const groupRef = this.db.collection("groups").doc(groupID);
    const groupDoc = await groupRef.get();
    if (!groupDoc.exists) {
      throw new Error(`Group with ID ${groupID} not found`);
    }
    const transaction = transactionFromJson(
      groupDoc.data()?.transactions[transactionID]
    );
    if (transaction.user.userID === userID) {
      throw new Error("User cannot confirm their own transaction");
    }
    const friend = transaction.friends[userID];
    if (!friend) {
      throw new Error("User is not part of this transaction");
    }
    if (friend.isConfirmed) {
      throw new Error("User has already confirmed this transaction");
    }
    await groupRef.update({
      [`transactions.${transactionID}.friends.${userID}.isConfirmed`]: true,
    });
    return;
  }
 // Delete User
  async deleteUser(userID: string) {
    const userDoc = this.db.collection("users").doc(userID);
    await userDoc.delete();
  }

  // / https://freecurrencyapi.com/docs/latest#request-parameters
  async updateCurrencyRates(apikey: string) {
    const currencyRef = this.db.collection("settings").doc("currencies");
    const currencyDoc = await currencyRef.get();
    if (
      !currencyDoc.exists ||
      !currencyDoc.data()?.timestamp ||
      Date.now() - currencyDoc.data()?.timestamp > 1 * 60 * 1000
    ) {
      const base_currency = "EUR";
      const currencies = "USD,GBP,JPY,CNY,EUR,CHF";
      const url = `https://api.freecurrencyapi.com/v1/latest?${new URLSearchParams(
        {apikey, base_currency, currencies}
      ).toString()}`;
      const result = await fetch(url);
      const {data: newRates} = await result.json();
      await currencyRef.set({...newRates, timestamp: Date.now()});
      return newRates;
    } else {
      const rates = currencyDoc.data();
      return rates;
    }
  }

  // Set Group Reminders
  async setGroupReminder(groupID: string) {
    const futureThreeDays = 3 * 24 * 60 * 60 * 1000;
    const remindersRef = this.db.collection("reminders").doc(groupID);
    await remindersRef.set({
      reminder: Date.now() + futureThreeDays,
    });
  }

  // Get Group Reminders for Set Date
  async getGroupRemindersForDate(timestamp = Date.now()): Promise<string[]> {
    const remindersRef = this.db.collection("reminders");
    const reminders = await remindersRef
      .where("reminder", "<=", timestamp)
      .get();
    const groupsToRemind = reminders.docs.map((doc) => doc.id);
    await Promise.all(
      groupsToRemind.map((groupID) => remindersRef.doc(groupID).delete())
    );
    return groupsToRemind;
  }

// Get Login Attempts
async getLoginAttempts(email: string): Promise<number> {
  const user = await getAuth().getUserByEmail(email);
  const userDoc = await this.db.collection("users").doc(user.uid).get();
  if (userDoc.exists) {
    const {loginAttempts} = userDoc.data() as any;
    return Number(loginAttempts ?? 0);
  }
  return 0;
}

// Increase Login Attempts
async increaseLoginAttempts(email: string): Promise<boolean> {
  const user = await getAuth().getUserByEmail(email);
  const userDoc = this.db.collection("users").doc(user.uid);
  if ((await userDoc.get()).exists) {
    userDoc.update({
      loginAttempts: FieldValue.increment(1),
    });
    return true;
  }
  return false;
}

// Reset Login Attempts
async resetLoginAttempts(email: string): Promise<boolean> {
  const user = await getAuth().getUserByEmail(email);
  const userDoc = this.db.collection("users").doc(user.uid);
  if ((await userDoc.get()).exists) {
    userDoc.update({
      loginAttempts: 0,
    });
    return true;
  }
  return false;
}
}

// -r.