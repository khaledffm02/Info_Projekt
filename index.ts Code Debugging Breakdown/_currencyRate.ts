import { onRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/logger";
import { getUserID } from "./auth";
import { db, discordApiKey } from "./config";

export const currencyRate = onRequest(
  { cors: true, secrets: [discordApiKey] },
  async (request, response) => {
    logger.info("Currency Rate API Hit", { structuredData: true });
    const { userID } = await getUserID(request);
    const currencyID = request.query.currencyID;
    const currencyDoc = db.doc(`currencies/${currencyID}`);
    const currency = await currencyDoc.get();
    const oldRate = currency.data()?.rate ?? 1;
    await currencyDoc.update({ rate: oldRate + 1 });
    response.send(`Currency rate updated. User: ${userID}`);
  }
);
