import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Exports handler function to reset login attempts for a user
export const resetLoginAttempts = onRequest(
    {cors: true}, // Enable CORS for the request
    async (request, response) => {
      const email = request.query.email as string; // Get the email from the request query
      try {
        const success = await groupManager.resetLoginAttempts(email); // Reset login attempts using the email
        response.send({success});
      } catch {
        response.send({message: "User not found"}).status(404); // If user not found, send 404 response
        return;
      }
    }
  );