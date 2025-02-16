import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"


test('calculates balances correctly for multiple transactions', () => {
  const transaction1 = new Transaction(
    { title: 'Dinner', timestamp: Date.now(), category: 'Food', storageURL: undefined },
    { userID: 'user1', value: 100 },
    { user2: { value: 50, isConfirmed: true } }
  );

  const transaction2 = new Transaction(
    { title: 'Taxi', timestamp: Date.now(), category: 'Transport', storageURL: undefined },
    { userID: 'user2', value: 60 },
    { user1: { value: 30, isConfirmed: true } }
  );

  const group = new Group('group1', {
    creatorID: 'user1',
    creationTimestamp: Date.now(),
    name: 'Test Group',
    groupCode: 'ABC123',
    memberIDs: { user1: true, user2: true },
    currency: 'USD',
    transactions: { txn1: transaction1, txn2: transaction2 }
  });

  const balances = group.getBalances();

  expect(balances['user1']).toBe(-70); // (-100 from dinner + 30 from taxi)
  expect(balances['user2']).toBe(20); // (50 from dinner - 60 from taxi)
});
