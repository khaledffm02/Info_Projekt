import {loadUser} from "../auth";
import {Group, GroupJSON} from "../models/Group";
import {randomString} from "../utils/random-string";
import {
  transactionToJson,
  Transaction,
  transactionFromJson,
} from "../models/Transaction";
import {FieldValue} from "firebase-admin/firestore";

export class GroupManager {
  constructor(readonly db: FirebaseFirestore.Firestore) {}

  async createGroup(creatorID: string, currency: string): Promise<string> {
    const creationTimestamp = Date.now();
    const groupCode = randomString(6).toUpperCase();
    const memberIDs = {[creatorID]: true};
    const groupJSON = {
      creatorID,
      creationTimestamp,
      groupCode,
      memberIDs,
      currency,
    };
    const groupRef = await this.db.collection("groups").add(groupJSON);
    return groupRef.id;
  }

  async getGroup(id: string): Promise<Group> {
    const groupDoc = await this.db.collection("groups").doc(id).get();
    if (!groupDoc.exists) {
      throw new Error(`Group with ID ${id} not found`);
    }
    return new Group(groupDoc.id, groupDoc.data() as GroupJSON);
  }

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

  async addMember(groupID: string, memberID: string): Promise<void> {
    const groupRef = this.db.collection("groups").doc(groupID);
    await groupRef.update({
      [`memberIDs.${memberID}`]: true,
    });
  }

  async removeMember(groupID: string, memberID: string): Promise<void> {
    const groupRef = this.db.collection("groups").doc(groupID);
    await groupRef.update({
      [`memberIDs.${memberID}`]: false,
    });
  }

  async deleteGroup(id: string): Promise<void> {
    await this.db.collection("groups").doc(id).delete();
  }

  async getGroupsForUser(userID: string): Promise<Group[]> {
    const groupDocs = await this.db
      .collection("groups")
      .where(`memberIDs.${userID}`, "==", true)
      .get();
    return groupDocs.docs.map(
      (doc) => new Group(doc.id, doc.data() as GroupJSON)
    );
  }

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

  async createTransaction(
    groupID: string,
    meta: { title: string; category?: string },
    user: { id: string; value: number },
    friends: { id: string; value: number }[]
  ) {
    const groupRef = this.db.collection("groups").doc(groupID);
    const transactionID = randomString(16);
    await groupRef.update({
      [`transactions.${transactionID}`]: transactionToJson(
        new Transaction(
          {
            category: meta.category ?? "",
            title: meta.title,
            storageURL: "",
            timestamp: Date.now(),
          },
          {userID: user.id, value: user.value},
          Object.fromEntries(
            friends.map((f) => [
              f.id,
              {value: f.value, isConfirmed: f.id === user.id},
            ])
          )
        )
      ),
    });
    return transactionID;
  }

  async deleteTransaction(groupID: string, transactionID: string) {
    const groupRef = this.db.collection("groups").doc(groupID);
    await groupRef.update({
      [`transactions.${transactionID}`]: FieldValue.delete(),
    });
    return;
  }

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

  async deleteUser(userID: string) {
    const userDoc = this.db.collection("users").doc(userID);
    await userDoc.delete();
  }
}
