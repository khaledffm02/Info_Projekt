import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Endpoint to add payment within a group
export const addPayment = onRequest(
    {cors: true, secrets: [emailAccount, emailPassword]}, // Enable CORS and use email secrets
    async (request, response) => {
      const groupID = (request.query.groupID || request.query.groupId) as string;
      const fromID = (request.query.fromID || request.query.fromId) as string;
      const toID = (request.query.toID || request.query.toId) as string;
      const amount = request.query.amount as string;
      const {userID} = await getUserID(request);// Fetch user ID from the request
      // Check if any parameters are missing
      if (!groupID || !userID || !fromID || !toID || !amount) {
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {groupID, fromID, toID, userID, amount},
        });
        return;
      }
  
      const fromUser = await loadUser(fromID); // Load the user sending the payment
      const toUser = await loadUser(toID); // Load the user receiving the payment
      // Check if either user is not found
      if (!fromUser || !toUser) {
        response.send({
          success: false,
          message: "Users not found",
          detailedMessage: {fromUser, toUser},
        });
        return;
      }
  
      const value = Number(amount); // Convert amount to number
  
      // Create the transaction and return the transaction ID
      const id = await groupManager.createTransaction(
        groupID,
        {title: "_payment", category: "payment"},
        {id: fromID, value},
        [{id: toID, value, isConfirmed: true}]
      );
  
      // Send email notification to the receipient
      await sendMail({
        account: emailAccount.value(),
        password: emailPassword.value(),
        from: "Fairshare@project.com",
        text: `You have received a payment from ${fromUser.name} of ${value} EUR`,
        to: toUser.email,
        subject: "Faireshare: Payment Received",
        html: `
  <b>You have received a payment from ${fromUser.name} of ${value} EUR.</b>`,
      });
  
      response.send({success: true, transactionID: id}); // Respond with success and the transaction ID
      return;
    }
  );