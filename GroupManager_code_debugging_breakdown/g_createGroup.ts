import { Firestore } from "firebase-admin/firestore";
import { randomString } from "../utils/random-string";

//Method to create a new group

export async function createGroup(
  db: Firestore,
  creatorID: string,
  currency: string,
  name?: string
): Promise<string> {
  //Get the current timestamp
  const creationTimestamp = Date.now();
  //Generate random group code
  const groupCode = randomString(6).toUpperCase();
  // Initialize member IDs with the creator ID
  const memberIDs = { [creatorID]: true };
  const groupJSON = {
    creatorID,
    creationTimestamp,
    groupCode,
    memberIDs,
    currency,
    name: name || `Group ${groupCode}`,
  };
  const groupRef = await db.collection("groups").add(groupJSON);
  return groupRef.id;
}
