"use strict";
/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.currencyRate = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const firestore_1 = require("firebase-admin/firestore");
const app_1 = require("firebase-admin/app");
(0, app_1.initializeApp)();
const db = (0, firestore_1.getFirestore)();
// Start writing functions
// https://firebase.google.com/docs/functions/typescript
exports.currencyRate = (0, https_1.onRequest)(async (request, response) => {
    var _a, _b;
    logger.info("Hello logs! Small Engine 20", { structuredData: true });
    const currencyID = request.query.currencyID;
    const currencyDoc = db.doc(`currencies/${currencyID}`);
    const currency = await currencyDoc.get();
    const oldRate = (_b = (_a = currency.data()) === null || _a === void 0 ? void 0 : _a.rate) !== null && _b !== void 0 ? _b : 1;
    await currencyDoc.update({ rate: oldRate + 1 });
    response.send("Hello from Firebase!");
});
//# sourceMappingURL=index.js.map