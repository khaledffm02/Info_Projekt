import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Cloud function to change group details
export const groupChange = onRequest(
    {cors: true},
    async (request, response) => {
      await getUserID(request); // Get the user ID from the request
      const groupID = request.query.groupID as string; // Get the group ID from query parameters
      if (!groupID) { // If group ID is missing
        response.send({success: false, message: "Missing groupID"});
        return;
      }
      const groupName = request.query.groupName as string | undefined; // Get the optional group name
      const groupCurrency = request.query.groupCurrency as string | undefined; // Get the optional group currency
      const group = await groupManager.getGroup(groupID); // Get the group corresponding to the group ID
      if (!group) { // If the group does not exist
        response.send({success: false, message: "Group not found"});
        return;
      }
      await groupManager.changeGroup(groupID, { // Change the group details
        name: groupName,
        currency: groupCurrency,
      });
      response.send({success: true}); // Send a success response
    }
  );
  