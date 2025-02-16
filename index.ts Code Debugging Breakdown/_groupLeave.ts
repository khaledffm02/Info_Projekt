import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Function which exports handler for group leave function
export const groupLeave = onRequest(
    {cors: true},
    async (request, response) => {
      // Get the groupID from the request query parameters
      const groupID = request.query.groupID as string;
      if (!groupID) {
        // Send a failure response if groupID is not provided
        response.send({success: false});
        return;
      }
      // Get the userID from the request
      const {userID} = await getUserID(request);
      // Get the group details using the groupID
      const group = await groupManager.getGroup(groupID);
  
      // Check if the user's balance in the group is not zero
      if (group.getBalanceForUser(userID) !== 0) {
        // Send a failure response if balance is not zero
        response.send({success: false});
      } else {
        // Remove the user from the group
        await groupManager.removeMember(group.id, userID);
        // Send a success response
        response.send({success: true});
      }
    }
  );
  