import { Firestore } from "firebase-admin/firestore";

export async function setGroupReminder(db: Firestore, groupID: string) {
  const futureThreeDays = 3 * 24 * 60 * 60 * 1000;
  await db.collection("reminders").doc(groupID).set({
    reminder: Date.now() + futureThreeDays,
  });
}

export async function getGroupRemindersForDate(db: Firestore, timestamp = Date.now()): Promise<string[]> {
  const remindersRef = db.collection("reminders");
  const reminders = await remindersRef.where("reminder", "<=", timestamp).get();
  
  const groupsToRemind = reminders.docs.map((doc) => doc.id);
  await Promise.all(groupsToRemind.map((groupID) => remindersRef.doc(groupID).delete()));
  
  return groupsToRemind;
}
