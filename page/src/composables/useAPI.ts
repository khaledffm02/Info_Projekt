import { createGlobalState } from "@vueuse/core";
import { user } from "../firebase/auth";

export const useAPI = createGlobalState(() => {
  const createGroup = async () => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const url = `https://groupcreate-fblxd33obq-uc.a.run.app?idToken=${encodeURIComponent(idToken)}&currencyID=EUR`;
    const res = await fetch(url);
    return res.json();
  };
  const deleteGroup = async (groupID: string) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const url = `https://groupdelete-fblxd33obq-uc.a.run.app?idToken=${idToken}&groupID=${groupID}`;
    const res = await fetch(url);
    return res.json();
  };
  const joinGroup = async (groupCode: string) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const url = `https://groupjoin-fblxd33obq-uc.a.run.app?idToken=${idToken}&groupCode=${groupCode}`;
    const res = await fetch(url);
    return res.json();
  };
  const leaveGroup = async (groupID: string) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const url = `https://groupleave-fblxd33obq-uc.a.run.app?idToken=${idToken}&groupID=${groupID}`;
    const res = await fetch(url);
    return res.json();
  };
  const userLogin = async () => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const url = `https://userlogin-fblxd33obq-uc.a.run.app?idToken=${encodeURIComponent(idToken)}`;
    const res = await fetch(url);
    return res.json();
  };
  const userRegistration = async (firstName: string, lastName: string) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const url = `https://userregistration-fblxd33obq-uc.a.run.app?idToken=${encodeURIComponent(idToken)}&firstName=${encodeURIComponent(firstName)}&lastName=${encodeURIComponent(lastName)}`;
    const res = await fetch(url);
    return res.json();
  };
  const sendPassword = async (email: string) => {
    const encodedEmail = encodeURIComponent(email);
    const url = `https://sendnewpassword-fblxd33obq-uc.a.run.app?email=${encodedEmail}`;
    const res = await fetch(url);
    return res.json();
  };
  const createTransaction = async (
    groupID: string,
    title: string,
    category: string,
    userParam: { id: string; value: number },
    friends: { id: string; value: number }[]
  ) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const request = encodeURIComponent(JSON.stringify({ groupID, title, category, user: userParam, friends }));
    const url = `https://createtransaction-fblxd33obq-uc.a.run.app?idToken=${encodeURIComponent(idToken)}&request=${request}`;
    const res = await fetch(url);
    return res.json();
  };
  const confirmTransaction = async (
    groupID: string,
    transactionID: string,
  ) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const url = `https://confirmtransaction-fblxd33obq-uc.a.run.app?idToken=${encodeURIComponent(idToken)}&groupID=${groupID}&transactionID=${transactionID}`;
    const res = await fetch(url);
    return res.json();
  };
  const deleteTransaction = async (
    groupID: string,
    transactionID: string,
  ) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const url = `https://deletetransaction-fblxd33obq-uc.a.run.app?idToken=${encodeURIComponent(idToken)}&groupID=${groupID}&transactionID=${transactionID}`;
    const res = await fetch(url);
    return res.json();
  };
  const addPayment = async (
    groupID: string,
    gromID: string,
    toID: string,
    amount: number,
  ) => {
    const idToken = await user.value?.getIdToken(true);
    if (!idToken) return;
    const url = `https://addpayment-fblxd33obq-uc.a.run.app?idToken=${encodeURIComponent(idToken)}&groupID=${encodeURIComponent(groupID)}&fromID=${encodeURIComponent(gromID)}&toID=${encodeURIComponent(toID)}&value=${amount}`;
    const res = await fetch(url);
    return res.json();
  };
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
  };
});
