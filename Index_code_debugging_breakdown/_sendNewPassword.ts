import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Method for sending new password

export const sendNewPassword = onRequest(
    {cors: true, secrets: [emailAccount, emailPassword]},
    async (request, response) => {
      // Get the email from the request query parameters
      const email = request.query.email as string;
      // Generate a new random password
      const newPassword = "C7-" + randomString(8) + "L";
      // Send the new password via email
      await sendMail({
        account: emailAccount.value(),
        password: emailPassword.value(),
        from: "Fairshare@project.com",
        text: `Your new password is ${newPassword}`,
        to: email,
        subject: "Your Fairshare app password was reset",
        html: `<b>Your new password is ${newPassword}</b>`,
      });
  
      // Change the user's password to the new password
      await changeUserPassword(email, newPassword);
      // Send success response
      response.send({success: true});
    }
  );
  