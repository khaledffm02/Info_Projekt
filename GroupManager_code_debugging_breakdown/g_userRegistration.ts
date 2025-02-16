import { Firestore } from "firebase-admin/firestore";
import { loadUser } from "../auth";

export async function userRegistration(
  db: Firestore,
  userID: string,
  options: { firstName: string; lastName: string; currency: string }
): Promise<void> {
  const userDoc = db.collection("users").doc(userID);
  const [userRaw, authUser] = await Promise.all([
    userDoc.get(),
    loadUser(userID),
  ]);

  if (!authUser) {
    throw new Error(`User with ID ${userID} not found`);
  }

  const userData = {
    firstName: options.firstName,
    lastName: options.lastName,
    currency: options.currency,
    email: authUser.email,
  };

  if (!userRaw.exists) {
    await userDoc.set(userData);
  } else {
    await userDoc.update(userData);
  }
}
