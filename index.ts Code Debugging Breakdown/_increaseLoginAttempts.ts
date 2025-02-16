import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Exports handler function to increase login attempts for a user
export const increaseLoginAttempts = onRequest(
    {cors: true}, // Enable CORS
    async (request, response) => {
      const email = request.query.email as string; // Get the email from the request query
      try {
        const success = await groupManager.increaseLoginAttempts(email); // Increase login attempts using the email
        response.send({success}); // Send success status in the response
      } catch {
        response.send({message: "User not found"}).status(404); // If user not found, send 404 response
        return;
      }
    }
  );