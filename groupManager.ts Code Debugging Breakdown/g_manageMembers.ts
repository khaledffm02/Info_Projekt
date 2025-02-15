import { Firestore } from "firebase-admin/firestore";

export async function addMember(db: Firestore, groupID: string, memberID: string): Promise<void> {
  const groupRef = db.collection("groups").doc(groupID);
  await groupRef.update({
    [`memberIDs.${memberID}`]: true,
  });
}

export async function removeMember(db: Firestore, groupID: string, memberID: string): Promise<void> {
  const groupRef = db.collection("groups").doc(groupID);
  await groupRef.update({
    [`memberIDs.${memberID}`]: false,
  });
}
