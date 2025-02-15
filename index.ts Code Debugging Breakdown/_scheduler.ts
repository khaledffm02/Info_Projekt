import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

exports.scheduledFunctionCrontab = onSchedule("*/5 * * * *", async () => {
    const groups = await groupManager.getGroupRemindersForDate();
    const getEndpoint = (groupID: string) =>
      `https://sendreminders-icvq5uaeva-uc.a.run.app?groupID=${encodeURIComponent(groupID)}`;
    await Promise.allSettled(
      groups.map((groupID) => fetch(getEndpoint(groupID)))
    );
  });
  