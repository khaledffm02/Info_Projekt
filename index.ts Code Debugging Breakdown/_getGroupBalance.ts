import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Function/Endpoint which provides group member overall balances
export const getGroupBalance = onRequest(
    {cors: true},
    // Main request function to get group balance
    async (request, response) => {
      const groupID = request.query.groupID as string; // Extract groupID from query
      const {userID} = await getUserID(request); // Extract userID using helper function
      if (!groupID || !userID) { // Check if parameters are missing
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {groupID, userID},
        });
        return;
      }
  
      const group = await groupManager.getGroup(groupID) // Fetch group from manager
      if (!group) { // Check if group exists
        response.send({success: false});
        return
      }
  
      response.send({balances: group.getBalances() ?? {}}); // Send group balances in response
    }
  );
  