import { Firestore } from "firebase-admin/firestore";
import { loadUser } from "../auth";

// Method for user login and updating their preferences

export async function userLogin(
  db: Firestore,
  userID: string,
  options?: { preferredCurrency: string }
): Promise<void> {
  const userDoc = db.collection("users").doc(userID);
  const [userRaw, authUser] = await Promise.all([
    userDoc.get(),
    loadUser(userID), // Load the user from the authentication service
  ]);

  if (!authUser) {
    throw new Error(`User with ID ${userID} not found`); // Throw error if user is not found
  }

  if (!userRaw.exists) { // Create the user document if it does not exist
    await userDoc.set({
      ...(options?.preferredCurrency ? { currency: options.preferredCurrency } : {}),
      name: authUser.name, //Set the user's name from the authentication service
      email: authUser.email, // Set the user's email from the authentication service
    });
  } else if (options?.preferredCurrency !== userRaw.data()?.currency) { // Update the currency if it has changed
    await userDoc.update({
      currency: options?.preferredCurrency,
    });
  }
}
