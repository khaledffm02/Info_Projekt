export async function deleteTransaction(db: Firestore, groupID: string, transactionID: string) {
    const groupRef = db.collection("groups").doc(groupID);
    await groupRef.update({
      [`transactions.${transactionID}`]: FieldValue.delete(),
    });
  }
  
  