import { Firestore } from "firebase-admin/firestore";

export async function changeGroup(
  db: Firestore,
  groupID: string,
  changes: { name?: string; currency?: string }
): Promise<void> {
  if (!changes.name && !changes.currency) return;
  
  const groupRef = db.collection("groups").doc(groupID);
  await groupRef.update({
    ...(changes.name ? { name: changes.name } : {}),
    ...(changes.currency ? { currency: changes.currency } : {}),
  });
}
