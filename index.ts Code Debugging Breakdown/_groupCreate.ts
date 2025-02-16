import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Cloud function to create a new group

export const groupCreate = onRequest(
  { cors: true },
  async (request, response) => {
    const { userID } = await getUserID(request); // Get the user ID from the request
    const member = await groupManager.getMember(userID); // Get the member corresponding to the user ID
    if (!member) { // If the member does not exist
      response.send({ success: false });
      return;
    }
    const groupName = request.query.groupName as string; // Get the group name from query parameters
    await groupManager.createGroup(userID, member.currency, groupName); // Create the new group
    response.send({ success: true }); // Send a success response
  }
);
