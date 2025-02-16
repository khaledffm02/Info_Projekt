
test('handles zero and negative values correctly', () => {
  const transaction = new Transaction(
    { title: 'Test Transaction', timestamp: Date.now(), category: 'Test', storageURL: undefined },
    { userID: 'user1', value: 100 },
    { friend1: { value: 0, isConfirmed: true }, friend2: { value: -50, isConfirmed: false } }
  );

  const balances = transaction.getUserBalances();

  expect(balances['user1']).toBe(-150); // User's value + negative unconfirmed friend's value
  expect(balances['friend1']).toBe(0);  // Zero value for confirmed friend
});
