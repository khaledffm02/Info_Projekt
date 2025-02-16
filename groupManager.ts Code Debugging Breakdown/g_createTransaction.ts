import { Firestore, FieldValue } from "firebase-admin/firestore";
import { Transaction, transactionToJson, transactionFromJson } from "../models/Transaction";
import { randomString } from "../utils/random-string";

// Method to create transaction within a specified group


export async function createTransaction(
  db: Firestore,
  groupID: string, // ID of the group in which transaction is created
  meta: { title: string; category?: string; storageURL?: string }, // metadata for the transaction
  user: { id: string; value: number }, // User initiating the transaction
  friends: { id: string; value: number; isConfirmed?: boolean }[] // List of friends involved in the transaction
): Promise<string> {
  const groupRef = db.collection("groups").doc(groupID);
  const transactionID = randomString(16); // Generate a unique transaction ID

  await groupRef.update({
    // Update the group document with the new transaction data
    [`transactions.${transactionID}`]: transactionToJson(
      new Transaction(
        {
          category: meta.category ?? "",
          title: meta.title,
          storageURL: meta.storageURL || "",
          timestamp: Date.now(),
        },
        // User details
        { userID: user.id, value: user.value },
        //Converting friends array to an object
        Object.fromEntries(
          friends.map((f) => [
            f.id,
            {
              // Friend details
              value: f.value,
              isConfirmed: f.id === user.id || !!f.isConfirmed,
            },
          ])
        )
      )
    ),
  });

  return transactionID; // Return the unique transaction ID
}

