import { Firestore } from "firebase-admin/firestore";
import { Group, GroupJSON } from "../models/Group";

export async function getGroup(db: Firestore, id: string): Promise<Group> {
  const groupDoc = await db.collection("groups").doc(id).get();
  if (!groupDoc.exists) {
    throw new Error(`Group with ID ${id} not found`);
  }
  return new Group(groupDoc.id, groupDoc.data() as GroupJSON);
}

export async function getGroupByCode(db: Firestore, groupCode: string): Promise<Group | undefined> {
  const group = await db
    .collection("groups")
    .where("groupCode", "==", groupCode)
    .get();
  if (group.docs.length === 0) {
    return;
  }
  const doc = group.docs[0];
  return new Group(doc.id, doc.data() as GroupJSON);
}
