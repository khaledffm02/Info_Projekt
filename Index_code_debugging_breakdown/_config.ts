import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { defineSecret } from "firebase-functions/params";
import { GroupManager } from "./managers/GroupManager";

initializeApp();
export const db = getFirestore();
export const groupManager = new GroupManager(db);

export const discordApiKey = defineSecret("beispiel");
export const emailAccount = defineSecret("account");
export const emailPassword = defineSecret("password");
export const openaiToken = defineSecret("openaiToken");
export const currencyKey = defineSecret("currencyKey");
