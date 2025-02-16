import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"
import {Group} from "../functions/src/models/Group"

test('calculates balances correctly for a single transaction', () => {
  const transaction = new Transaction(
    { title: 'Dinner', timestamp: Date.now(), category: 'Food', storageURL: undefined },
    { userID: 'user1', value: 100 },
    { user2: { value: 50, isConfirmed: true } }
  );

  const group = new Group('group1', {
    creatorID: 'user1',
    creationTimestamp: Date.now(),
    name: 'Test Group',
    groupCode: 'ABC123',
    memberIDs: { user1: true, user2: true },
    currency: 'USD',
    transactions: { txn1: transaction }
  });

  const balances = group.getBalances();

  expect(balances['user1']).toBe(-100);
  expect(balances['user2']).toBe(50);
});
