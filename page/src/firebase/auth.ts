import { useAuth } from "@vueuse/firebase/useAuth";
import { GoogleAuthProvider, getAuth, signInWithPopup, signInWithEmailAndPassword, createUserWithEmailAndPassword, sendEmailVerification, sendPasswordResetEmail, updatePassword, reauthenticateWithCredential } from "firebase/auth";
import { computed } from "vue";
import { app } from "./firebase";

const auth = getAuth(app);

const { isAuthenticated: isAuth, user: rawUser } = useAuth(auth);
export const isAuthenticated = computed(() => isAuth.value && rawUser.value?.emailVerified);

export const user = computed(() => rawUser.value);

export const signIn = () => signInWithPopup(auth, new GoogleAuthProvider());

export const signOut = () => auth.signOut();

export const signInWithPasswordAndEmail = async (email: string, password: string) => {
    await signInWithEmailAndPassword(auth, email, password);
}

export const registerWithPasswordAndEmail = async (email: string, password: string) => {
    const credentials = await createUserWithEmailAndPassword(auth, email, password);
    console.log(credentials)
    const response = await sendEmailVerification(credentials.user);
    console.log(response)

}

export const deleteUser = async () => {
    const user = auth.currentUser;
    await user?.delete();
}

export const sendPassword = async (email: string) => {
 await sendPasswordResetEmail(auth, email)
}

export const changePassword = async (oldPassword: string, newPassword: string) => {
    const user = auth.currentUser;
    if (!user) {
        return;
    }
    const email = user.email;
    if (!email) {
        return
    }
    const password = oldPassword
    const credentials = await signInWithEmailAndPassword(auth, email, password);
    await updatePassword(credentials.user, newPassword);
}