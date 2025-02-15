import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const resetLoginAttempts = onRequest(
    {cors: true},
    async (request, response) => {
      const email = request.query.email as string;
      try {
        const success = await groupManager.resetLoginAttempts(email);
        response.send({success});
      } catch {
        response.send({message: "User not found"}).status(404);
        return;
      }
    }
  );