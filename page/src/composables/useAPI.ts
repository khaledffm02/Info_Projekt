import { createGlobalState } from "@vueuse/core";
import { user } from "../firebase/auth";

export const useAPI = createGlobalState(() => {
    const createGroup = async () => {
        const idToken = await user.value?.getIdToken(true)
        if (!idToken) return
        const url = `https://groupcreate-fblxd33obq-uc.a.run.app?idToken=${idToken}&currencyID=EUR`
        const res = await fetch(url)
        return res.json()
    }
    const deleteGroup = async (groupID: string) => {
        const idToken = await user.value?.getIdToken(true)
        if (!idToken) return
        const url = `https://groupdelete-fblxd33obq-uc.a.run.app?idToken=${idToken}&groupID=${groupID}`
        const res = await fetch(url)
        return res.json()
    }
    const joinGroup = async (groupCode: string) => {
        const idToken = await user.value?.getIdToken(true)
        if (!idToken) return
        const url = `https://groupjoin-fblxd33obq-uc.a.run.app?idToken=${idToken}&groupCode=${groupCode}`
        const res = await fetch(url)
        return res.json()
    }
    const leaveGroup = async (groupID: string) => {
        const idToken = await user.value?.getIdToken(true)
        if (!idToken) return
        const url = `https://groupleave-fblxd33obq-uc.a.run.app?idToken=${idToken}&groupID=${groupID}`
        const res = await fetch(url)
        return res.json()
    }
    const userLogin = async () => {
        const idToken = await user.value?.getIdToken(true)
        if (!idToken) return
        const url = `https://userlogin-fblxd33obq-uc.a.run.app?idToken=${idToken}`
        const res = await fetch(url)
        return res.json()
    }
    const sendPassword = async (email: string) => {
        const encodedEmail = encodeURIComponent(email)
        const url = `https://sendnewpassword-fblxd33obq-uc.a.run.app?email=${encodedEmail}`
        const res = await fetch(url)
        return res.json()
    }
    return {createGroup,deleteGroup,joinGroup,leaveGroup,userLogin,sendPassword}
})