
test('calculates balances correctly when there are no transactions', () => {
  const group = new Group('group1', {
    creatorID: 'user1',
    creationTimestamp: Date.now(),
    name: 'Test Group',
    groupCode: 'ABC123',
    memberIDs: { user1: true, user2: true },
    currency: 'USD',
    transactions: {},
  });

  expect(group.getBalances()).toEqual({});
});
