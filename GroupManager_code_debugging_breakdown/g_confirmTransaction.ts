// Method to confirm a transaction

export async function confirmTransaction(
    db: Firestore,
    groupID: string,
    transactionID: string,
    userID: string
  ) {
    // Reference the group document in Firestore
    const groupRef = db.collection("groups").doc(groupID);
    // Get the group document
    const groupDoc = await groupRef.get();
  
    // Check if the group document exists
    if (!groupDoc.exists) {
      throw new Error(`Group with ID ${groupID} not found`);
    }
  
    const transaction = transactionFromJson(groupDoc.data()?.transactions[transactionID]);
  
    // Check if the user is the one who initiated the transaction
    if (transaction.user.userID === userID) {
      throw new Error("User cannot confirm their own transaction");
    }
  
    // Check if the user is part of the transaction
    const friend = transaction.friends[userID];
    if (!friend) {
      throw new Error("User is not part of this transaction");
    }
  // Check if the user has already confirmed the transaction
    if (friend.isConfirmed) {
      throw new Error("User has already confirmed this transaction");
    }
  
   // Update the transaction to be marked as confirmed 
    await groupRef.update({
      [`transactions.${transactionID}.friends.${userID}.isConfirmed`]: true,
    });
  }
  