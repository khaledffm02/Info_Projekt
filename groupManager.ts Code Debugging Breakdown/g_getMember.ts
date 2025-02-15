import { Firestore } from "firebase-admin/firestore";

export async function getMember(
  db: Firestore,
  userID: string
): Promise<undefined | { name: string; currency: string }> {
  const userDoc = await db.collection("users").doc(userID).get();
  if (!userDoc.exists) return;

  const { name, currency } = userDoc.data() ?? {};
  return { name, currency };
}
