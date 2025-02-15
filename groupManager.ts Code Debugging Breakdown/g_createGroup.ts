import { Firestore } from "firebase-admin/firestore";
import { randomString } from "../utils/random-string";

export async function createGroup(
  db: Firestore,
  creatorID: string,
  currency: string,
  name?: string
): Promise<string> {
  const creationTimestamp = Date.now();
  const groupCode = randomString(6).toUpperCase();
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
