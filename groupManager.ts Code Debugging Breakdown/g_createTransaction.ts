import { Firestore, FieldValue } from "firebase-admin/firestore";
import { Transaction, transactionToJson, transactionFromJson } from "../models/Transaction";
import { randomString } from "../utils/random-string";

export async function createTransaction(
  db: Firestore,
  groupID: string,
  meta: { title: string; category?: string; storageURL?: string },
  user: { id: string; value: number },
  friends: { id: string; value: number; isConfirmed?: boolean }[]
): Promise<string> {
  const groupRef = db.collection("groups").doc(groupID);
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
        { userID: user.id, value: user.value },
        Object.fromEntries(
          friends.map((f) => [
            f.id,
            {
              value: f.value,
              isConfirmed: f.id === user.id || !!f.isConfirmed,
            },
          ])
        )
      )
    ),
  });

  return transactionID;
}

