import { Firestore } from "firebase-admin/firestore";
import { loadUser } from "../auth";

export async function userLogin(
  db: Firestore,
  userID: string,
  options?: { preferredCurrency: string }
): Promise<void> {
  const userDoc = db.collection("users").doc(userID);
  const [userRaw, authUser] = await Promise.all([
    userDoc.get(),
    loadUser(userID),
  ]);

  if (!authUser) {
    throw new Error(`User with ID ${userID} not found`);
  }

  if (!userRaw.exists) {
    await userDoc.set({
      ...(options?.preferredCurrency ? { currency: options.preferredCurrency } : {}),
      name: authUser.name,
      email: authUser.email,
    });
  } else if (options?.preferredCurrency !== userRaw.data()?.currency) {
    await userDoc.update({
      currency: options?.preferredCurrency,
    });
  }
}
