import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Function/method to send invitation email to a user
export const sendInvitation = onRequest(
    {cors: true, secrets: [emailAccount, emailPassword]}, // Enable CORS and use secrets for email account and password
    async (request, response) => {
      const groupID = request.query.groupID as string; // Get the group ID from the request query
      const email = request.query.email as string; // Get the email from the request query
      const {userID} = await getUserID(request);// Get the user ID from the request

      // Check if required parameters are present
      if (!groupID || !userID || !email) {
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {groupID, userID, email},
        });
        return;
      }
      const group = await groupManager.getGroup(groupID); // Get the group data using the group ID
      if (!group) {
        response.send({
          success: false,
          message: "Group not found",
          detailedMessage: {groupID},
        });
        return;
      }
      // Send an email with the invitation details
      await sendMail({
        account: emailAccount.value(),
        password: emailPassword.value(),
        from: "Fairshare@project.com",
        text: `Please enter the invitation code ${group.data.groupCode}`,
        to: email,
        subject: "Invitation to join a group",
        html: `<b>Hello, 
              you have been invited to join the group "${group.data.name}".
              Please enter the invitation code ${group.data.groupCode} 
              in the app to join.</b>`,
      });
  
      response.send({success: true}); // Send success status in response
    }
  );