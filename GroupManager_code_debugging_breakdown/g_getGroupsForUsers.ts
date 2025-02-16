import { Firestore } from "firebase-admin/firestore";
import { Group, GroupJSON } from "../models/Group";

// Method to get all groups a user is part of
export async function getGroupsForUser(db: Firestore, userID: string): Promise<Group[]> {
  const groupDocs = await db
    .collection("groups")
    .where(`memberIDs.${userID}`, "==", true) // Query groups where user is a part of
    .get();
  
  return groupDocs.docs.map(
    (doc) => new Group(doc.id, doc.data() as GroupJSON)
  );
}
