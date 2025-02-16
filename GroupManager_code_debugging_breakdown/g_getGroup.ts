import { Firestore } from "firebase-admin/firestore";
import { Group, GroupJSON } from "../models/Group";

// Method to get a group by its ID

export async function getGroup(db: Firestore, id: string): Promise<Group> {
  // Retrieeve the group document from the database
  const groupDoc = await db.collection("groups").doc(id).get();
  if (!groupDoc.exists) {
    // Throw an error if the group does not exist
    throw new Error(`Group with ID ${id} not found`);
  }
  // Return the Grouo object
  return new Group(groupDoc.id, groupDoc.data() as GroupJSON);
}

