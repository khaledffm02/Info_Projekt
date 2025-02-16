import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Function to delete a group
export const groupDelete = onRequest(
    {cors: true}, // enable CORS
    async (request, response) => {
      const groupID = request.query.groupID as string; // Get the group ID from query parameters
      await groupManager.deleteGroup(groupID); // Delete the group
      response.send({success: true}); // Send a success response
    }
  );
  