import {
  transactionFromJson,
  type TransactionJSON,
} from "./Transaction";

export type GroupJSON = {
  creatorID: string;
  creationTimestamp: number;
  name: string | undefined;
  groupCode: string;
  memberIDs: Record<string, boolean>;
  currency: string;
  transactions: Record<string, TransactionJSON>;
};

export class Group {
  constructor(readonly id: string, readonly data: GroupJSON) {}

  get memberCount() {
    return Object.keys(this.data.memberIDs).length;
  }

  getBalances(): Record<string, number> {
    const balances: Record<string, number> = {};
    // eslint-disable-next-line guard-for-in
    for (const transactionID in this.data.transactions) {
      const transaction = transactionFromJson(
        this.data.transactions[transactionID]
      );
      const transactionBalances = transaction.getUserBalances();
      // eslint-disable-next-line guard-for-in
      for (const userID in transactionBalances) {
        balances[userID] =
          (balances[userID] ?? 0) + transactionBalances[userID];
      }
    }
    return balances;
  }

  getBalanceForUser(userID: string): number {
    const balance = this.getBalances()[userID] ?? 0;
    console.log(balance, userID);
    return balance;
  }
}
