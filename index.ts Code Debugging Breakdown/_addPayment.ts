import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const addPayment = onRequest(
    {cors: true, secrets: [emailAccount, emailPassword]},
    async (request, response) => {
      const groupID = (request.query.groupID || request.query.groupId) as string;
      const fromID = (request.query.fromID || request.query.fromId) as string;
      const toID = (request.query.toID || request.query.toId) as string;
      const amount = request.query.amount as string;
      const {userID} = await getUserID(request);
      if (!groupID || !userID || !fromID || !toID || !amount) {
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {groupID, fromID, toID, userID, amount},
        });
        return;
      }
  
      const fromUser = await loadUser(fromID);
      const toUser = await loadUser(toID);
      if (!fromUser || !toUser) {
        response.send({
          success: false,
          message: "Users not found",
          detailedMessage: {fromUser, toUser},
        });
        return;
      }
  
      const value = Number(amount);
  
      const id = await groupManager.createTransaction(
        groupID,
        {title: "_payment", category: "payment"},
        {id: fromID, value},
        [{id: toID, value, isConfirmed: true}]
      );
  
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
  
      response.send({success: true, transactionID: id});
      return;
    }
  );