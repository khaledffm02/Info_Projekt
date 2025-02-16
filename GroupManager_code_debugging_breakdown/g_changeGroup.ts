import { Firestore } from "firebase-admin/firestore";

// Method to update group details

export async function changeGroup(
  db: Firestore,
  groupID: string,
  changes: { name?: string; currency?: string }
): Promise<void> {
  if (!changes.name && !changes.currency) return; //Exit if there are no changes to make
  
  const groupRef = db.collection("groups").doc(groupID);
  await groupRef.update({
    ...(changes.name ? { name: changes.name } : {}),
    ...(changes.currency ? { currency: changes.currency } : {}),
  });
}
