import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Exports handler function to get attempts for a user
export const getLoginAttempts = onRequest(
    {cors: true}, // Enable CORS for request
    async (request, response) => {
      const email = request.query.email as string; // Get the email from the request query
      try {
        const value = await groupManager.getLoginAttempts(email); // Get login attempts using the email
        response.send({loginAttempts: value}); // Send the login attempts count in the response
      } catch {
        response.send({message: "User not found"}).status(404); // If user not found, send 404 response
        return;
      }
    }
  );