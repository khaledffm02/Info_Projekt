import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Endpoints for sending reminder function
export const sendReminders = onRequest(
    {cors: true, secrets: [emailAccount, emailPassword]},
    // Request function to send reminders for open balances
    async (request, response) => {
      const groupID = request.query.groupID as string; // Extract groupID from query
      if (!groupID) { //Check for missing parameters
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {groupID},
        });
        return;
      }
      const group = await groupManager.getGroup(groupID); // Fetch group from manager
      const balances = group.getBalances();//Get group balances
      // eslint-disable-next-line guard-for-in
      for (const entries in Object.entries(balances)) { // Loop through balances
        const userID = entries[0];
        const balance = Number(entries[1]);
        if (balance > 0) {
          const user = await loadUser(userID); // Load user details using userID
          if (!user) {
            continue;
          }
          const email = user.email;
          await sendMail({
            account: emailAccount.value(),
            password: emailPassword.value(),
            from: "Fairshare@project.com",
            text: `Reminder open balance of ${balance} EUR`,
            to: email,
            subject: "Reminder of open balance",
            html: `<b>Hi ${user.name}, 
              you have open payments to take action on 
              in your group "${group.data.name}". 
              Open: ${balance} ${group.data.currency} EUR</b>`,
          }); // Send reminder email to the user
        }
      }
  
      response.send({success: true}); // Send success response
    }
  );