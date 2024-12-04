import {getAuth} from "firebase-admin/auth";
import {Request as ExpressRequest} from "firebase-functions/v2/https";
import {User} from "./models/User";

export async function loadUser(userID: string): Promise<User | undefined> {
  const {uid, displayName, email} = await getAuth().getUser(userID);
  if (!uid || !email) {
    return;
  }
  return new User(uid, displayName ?? email, email);
}

/**
 * Authenticate the user with the provided ID token.
 * @param {ExpressRequest} request - The request object containing the ID token.
 * @return {Promise<string>} The user ID.
 */
export async function getUserID(
  request: ExpressRequest
): Promise<{ userID: string }> {
  const idToken = request.query.idToken as string;
  if (!idToken) {
    throw new Error("No ID token provided.");
  }
  const decodedToken = await getAuth().verifyIdToken(idToken);

  return {userID: decodedToken.uid};
}

export async function changeUserPassword(email: string, newPassword: string) {
  const user = await getAuth().getUserByEmail(email);
  await getAuth().updateUser(user.uid, {password: newPassword});
}
