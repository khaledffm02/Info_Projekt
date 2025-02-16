// Method to delete a user

import { Firestore } from "firebase-admin/firestore";

export async function deleteUser(db: Firestore, userID: string) {
  await db.collection("users").doc(userID).delete(); // Delete the user document
}
