import { Firestore } from "firebase-admin/firestore";

// Method to delete a group

export async function deleteGroup(db: Firestore, id: string): Promise<void> {
  await db.collection("groups").doc(id).delete(); // Delete the specified group document
}
