    export async function confirmTransaction(
    db: Firestore,
    groupID: string,
    transactionID: string,
    userID: string
  ) {
    const groupRef = db.collection("groups").doc(groupID);
    const groupDoc = await groupRef.get();
  
    if (!groupDoc.exists) {
      throw new Error(`Group with ID ${groupID} not found`);
    }
  
    const transaction = transactionFromJson(groupDoc.data()?.transactions[transactionID]);
  
    if (transaction.user.userID === userID) {
      throw new Error("User cannot confirm their own transaction");
    }
  
    const friend = transaction.friends[userID];
    if (!friend) {
      throw new Error("User is not part of this transaction");
    }
  
    if (friend.isConfirmed) {
      throw new Error("User has already confirmed this transaction");
    }
  
    await groupRef.update({
      [`transactions.${transactionID}.friends.${userID}.isConfirmed`]: true,
    });
  }
  