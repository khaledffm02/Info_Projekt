import { Firestore } from "firebase-admin/firestore";

// Method to add a member to a group
export async function addMember(db: Firestore, groupID: string, memberID: string): Promise<void> {
  const groupRef = db.collection("groups").doc(groupID);
  await groupRef.update({
    [`memberIDs.${memberID}`]: true, //Update the memberIDs map to mark the member as a part of the group
  });
}

// Method to remove a member from a group
export async function removeMember(db: Firestore, groupID: string, memberID: string): Promise<void> {
  const groupRef = db.collection("groups").doc(groupID); // Reference to the specific group document
  await groupRef.update({
    [`memberIDs.${memberID}`]: false,
  });
}
