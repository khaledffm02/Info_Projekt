
test('handles undefined group name correctly', () => {
  const group = new Group('group1', {
    creatorID: 'user1',
    creationTimestamp: Date.now(),
    name: undefined,
    groupCode: 'XYZ456',
    memberIDs: { user1: true },
    currency: 'EUR',
    transactions: {},
  });

  expect(group.data.name).toBeUndefined();
});
