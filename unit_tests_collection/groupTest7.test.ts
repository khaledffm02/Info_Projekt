import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"


test('handles transactions with zero values correctly', () => {
  const transaction = new Transaction(
    { title: 'Zero Transaction', timestamp: Date.now(), category: 'Misc', storageURL: undefined },
    { userID: 'user1', value: 0 },
    { user2: { value: 0, isConfirmed: true } }
  );

  const group = new Group('group1', {
    creatorID: 'user1',
    creationTimestamp: Date.now(),
    name: 'Zero Group',
    groupCode: 'ZERO123',
    memberIDs: { user1: true, user2: true },
    currency: 'USD',
    transactions: { txn1: transaction }
  });

  const balances = group.getBalances();

  expect(balances['user1']).toBe(0);
  expect(balances['user2']).toBe(0);
});
