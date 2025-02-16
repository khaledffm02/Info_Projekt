import { Firestore } from "firebase-admin/firestore";

// Methods to set group reminders 

// Calculates the timestamp for three days in the future
export async function setGroupReminder(db: Firestore, groupID: string) {
  const futureThreeDays = 3 * 24 * 60 * 60 * 1000;
  // Reference the reminders document in Firestore
  // Set the reminder
  await db.collection("reminders").doc(groupID).set({
    reminder: Date.now() + futureThreeDays,
  });
}


export async function getGroupRemindersForDate(db: Firestore, timestamp = Date.now()): Promise<string[]> {
  const remindersRef = db.collection("reminders"); // Get all reminders that are due via the timestamp
  const reminders = await remindersRef.where("reminder", "<=", timestamp).get();
  
  // Map reminders to group IDs and delete those reminders
  const groupsToRemind = reminders.docs.map((doc) => doc.id);
  await Promise.all(groupsToRemind.map((groupID) => remindersRef.doc(groupID).delete()));
  
  return groupsToRemind;
}
