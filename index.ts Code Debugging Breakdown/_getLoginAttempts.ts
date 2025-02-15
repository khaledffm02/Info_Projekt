import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const getLoginAttempts = onRequest(
    {cors: true},
    async (request, response) => {
      const email = request.query.email as string;
      try {
        const value = await groupManager.getLoginAttempts(email);
        response.send({loginAttempts: value});
      } catch {
        response.send({message: "User not found"}).status(404);
        return;
      }
    }
  );