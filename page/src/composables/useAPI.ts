import { createGlobalState } from "@vueuse/core";
import { user } from "../firebase/auth";

export const useAPI = createGlobalState(() => {
  const createGroup = async () => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const res = await fetch(createURL('groupcreate',{idToken,currencyID:'EUR'}));
    return res.json();
  };
  const deleteGroup = async (groupID: string) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const res = await fetch(createURL('groupdelete',{idToken,groupID}));
    return res.json();
  };
  const joinGroup = async (groupCode: string) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const res = await fetch(createURL('groupjoin',{idToken,groupCode}));
    return res.json();
  };
  const leaveGroup = async (groupID: string) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const res = await fetch(createURL('groupleave',{idToken,groupID}));
    return res.json();
  };
  const userLogin = async () => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const res = await fetch(createURL('userlogin',{idToken}));
    return res.json();
  };
  const userRegistration = async (firstName: string, lastName: string) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const res = await fetch(createURL('userregistration',{idToken,firstName,lastName}));
    return res.json();
  };
  const sendPassword = async (email: string) => {
    const res = await fetch(createURL('sendnewpassword',{email}));
    return res.json();
  };
  const createTransaction = async (
    groupID: string,
    title: string,
    category: string,
    userParam: { id: string; value: number },
    friends: { id: string; value: number }[],
    storageURL?: string
  ) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const request = encodeURIComponent(JSON.stringify({ groupID, title, category, user: userParam, friends, storageURL }));
    const res = await fetch(createURL('createtransaction',{idToken,request}));
    return res.json();
  };
  const confirmTransaction = async (
    groupID: string,
    transactionID: string,
  ) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const res = await fetch(createURL('confirmtransaction',{idToken,groupID,transactionID}));
    return res.json();
  };
  const deleteTransaction = async (
    groupID: string,
    transactionID: string,
  ) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const res = await fetch(createURL('deletetransaction',{groupID,transactionID,idToken}));
    return res.json();
  };
  const addPayment = async (
    groupID: string,
    fromID: string,
    toID: string,
    amount: number,
  ) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const res = await fetch(createURL('addpayment',{groupID,idToken,fromID,toID,amount:String(amount)}));
    return res.json();
  };
  const addFileToTransaction = async (
    groupID: string,
    transactionID: string,
    fileName: string,
  ) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const res = await fetch(createURL('addfiletotransaction',{groupID,transactionID,fileName,idToken}));
    return res.json();
  };
  const extractInformation = async (
    fileName: string,
  ): Promise<undefined | {category: string, title: string, amount: number}> => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const res = await fetch(createURL('extractinformation',{fileName,idToken}));
    const result = await res.json() as any;
    return result.success ? result : undefined;
  };
  const updateRates = async (): Promise<undefined | {category: string, title: string, amount: number}> => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    await fetch(createURL('updaterates',{idToken}));
  };
  const getBalances = async (groupID: string): Promise<any> => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    await fetch(createURL('getgroupbalance',{idToken,groupID}));
  }
  return {
    createGroup,
    deleteGroup,
    joinGroup,
    leaveGroup,
    userLogin,
    sendPassword,
    userRegistration,
    createTransaction,
    confirmTransaction,
    deleteTransaction,
    addPayment,
    addFileToTransaction,
    extractInformation,
    updateRates,
    getBalances,
  };
});

const getLoginAttempts = async (email: string) => {
  const idToken = await user.value?.getIdToken(true);
  if (!idToken) return;
  const res = await fetch(createURL('getloginattempts', { idToken, email }));
  return res.json();
};


function createURL(endpoint: string, params: Record<string, string>): string {
  const p = new URLSearchParams(params).toString()
  return `https://${endpoint}-icvq5uaeva-uc.a.run.app?${p}`;
}