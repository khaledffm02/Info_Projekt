import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Function which allows the joining of a group
export const groupJoin = onRequest(
    {cors: true},// Enable CORS
    async (request, response) => {
      const groupCode = request.query.groupCode as string; // Get the group code from query parameters
      if (!groupCode) { // If the group code is missing
        response.send({success: false});
        return;
      }
      const {userID} = await getUserID(request); // Get the user ID from the request
      const group = await groupManager.getGroupByCode(groupCode); // Get the group be the group code
      if (!group) { // if the group does not exist
        response.send({success: false});
      } else if (group.memberCount >= 10) { // If the group has reached maximum members
        response.send({success: false, message: "Too many members"});
      } else {
        await groupManager.addMember(group.id, userID); // Add the member to the group
        response.send({success: true}); // Send a success response
      }
    }
  );
  