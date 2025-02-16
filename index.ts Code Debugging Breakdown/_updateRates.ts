import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Endpoint which updates the currency rates
export const updateRates = onRequest(
    {cors: true, secrets: [currencyKey]},
    // Request function to update currency rates
    async (request, response) => {
      const {userID} = await getUserID(request);// Extract userID using helper function
      if (!userID) {//Check for missing parameters
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {userID},
        });
        return;
      }
  
      await groupManager.updateCurrencyRates(currencyKey.value()); // Update currency rates
      response.send({success: true}); // Respond with success
  
      return;
    }
  );