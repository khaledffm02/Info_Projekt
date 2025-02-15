import { Firestore } from "firebase-admin/firestore";
import { Group, GroupJSON } from "../models/Group";

export async function getGroupsForUser(db: Firestore, userID: string): Promise<Group[]> {
  const groupDocs = await db
    .collection("groups")
    .where(`memberIDs.${userID}`, "==", true)
    .get();
  
  return groupDocs.docs.map(
    (doc) => new Group(doc.id, doc.data() as GroupJSON)
  );
}
