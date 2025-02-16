import {test,expect} from "bun:test"
import {Group} from "../functions/src/models/Group"

// Test to handle undefined group names correctly

// Create a group without specifying a name
test('handles undefined group name correctly', () => {
  const group = new Group('group1', {
    creatorID: 'user1',
    creationTimestamp: Date.now(),
    name: undefined, // Group name left undefined
    groupCode: 'XYZ456',
    memberIDs: { user1: true },
    currency: 'EUR',
    transactions: {},
  });

  expect(group.data.name).toBeUndefined(); // Check to make sure group name remains undefined
});
