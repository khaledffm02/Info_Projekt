import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const sendInvitation = onRequest(
    {cors: true, secrets: [emailAccount, emailPassword]},
    async (request, response) => {
      const groupID = request.query.groupID as string;
      const email = request.query.email as string;
      const {userID} = await getUserID(request);
      if (!groupID || !userID || !email) {
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {groupID, userID, email},
        });
        return;
      }
      const group = await groupManager.getGroup(groupID);
      if (!group) {
        response.send({
          success: false,
          message: "Group not found",
          detailedMessage: {groupID},
        });
        return;
      }
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
  
      response.send({success: true});
    }
  );