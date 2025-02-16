import {test,expect} from "bun:test"
import {Group} from "../functions/src/models/Group"

// Initialize a new group with two members
test('calculates balances correctly when there are no transactions', () => {
  const group = new Group('group1', {
    creatorID: 'user1',
    creationTimestamp: Date.now(),
    name: 'Test Group',
    groupCode: 'ABC123',
    memberIDs: { user1: true, user2: true }, // Two members
    currency: 'USD',
    transactions: {}, // No transactions exist
  });

  // Since no transactions exist, the balances should be an empty object set
  expect(group.getBalances()).toEqual({});
});
