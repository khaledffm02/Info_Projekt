import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const sendNewPassword = onRequest(
    {cors: true, secrets: [emailAccount, emailPassword]},
    async (request, response) => {
      const email = request.query.email as string;
      const newPassword = "C7-" + randomString(8) + "L";
      await sendMail({
        account: emailAccount.value(),
        password: emailPassword.value(),
        from: "Fairshare@project.com",
        text: `Your new password is ${newPassword}`,
        to: email,
        subject: "Your Fairshare app password was reset",
        html: `<b>Your new password is ${newPassword}</b>`,
      });
  
      await changeUserPassword(email, newPassword);
      response.send({success: true});
    }
  );
  