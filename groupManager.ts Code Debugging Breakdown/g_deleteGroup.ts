import { Firestore } from "firebase-admin/firestore";

export async function deleteGroup(db: Firestore, id: string): Promise<void> {
  await db.collection("groups").doc(id).delete();
}
