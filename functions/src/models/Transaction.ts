type MetaData = {
  title: string;
  timestamp: number;
  category: string;
  storageURL: string | undefined;
};
type Spending = {
  userID: string;
  value: number;
};

export class Transaction {
  constructor(
    readonly meta: MetaData,
    readonly user: Spending,
    readonly friends: Record<string, { value: number; isConfirmed: boolean }>
  ) {}

  getUserBalances(): Record<string, number> {
    const balances: Record<string, number> = {};
    balances[this.user.userID] = -this.user.value;
    // eslint-disable-next-line guard-for-in
    for (const friendID in this.friends) {
      const {isConfirmed, value} = this.friends[friendID];
      if (isConfirmed) {
        balances[friendID] =
          (balances[friendID] ?? 0) + this.friends[friendID].value;
      } else {
        balances[this.user.userID] += value;
      }
    }
    return balances;
  }
}

export type TransactionJSON = {
  meta: MetaData;
  user: Spending;
  friends: Record<string, { value: number; isConfirmed: boolean }>;
};

export function transactionToJson(transaction: Transaction): TransactionJSON {
  return {
    meta: transaction.meta,
    user: transaction.user,
    friends: transaction.friends,
  };
}

export function transactionFromJson(json: any): Transaction {
  return new Transaction(json.meta, json.user, json.friends);
}
