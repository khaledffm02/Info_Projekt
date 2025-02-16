import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Method for user delete
export const userDelete = onRequest(
    {cors: true},
    async (request, response) => {
      // Get the userID from the request
      const {userID} = await getUserID(request);
      // Get the groups associated with the userID
      const groups = await groupManager.getGroupsForUser(userID);
      // Check if all groups have zero balance for the user
      const hasZeroBalance = groups.every(
        (group) => group.getBalanceForUser(userID) === 0
      );
      if (!hasZeroBalance) {
        // Send a failure response if any group has a non-zero balance
        response.send({success: false});
        return;
      }
      // Delete the user
      await groupManager.deleteUser(userID);
      response.send({success: userID}); //Send a success response
    }
  );
  