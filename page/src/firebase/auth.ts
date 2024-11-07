import { useAuth } from "@vueuse/firebase/useAuth";
import { GoogleAuthProvider, getAuth, signInWithPopup } from "firebase/auth";
import { computed } from "vue";
import { app } from "./firebase";

const auth = getAuth(app);

const { isAuthenticated, user: rawUser } = useAuth(auth);
export { isAuthenticated };
export const user = computed(() => rawUser.value);

export const signIn = () => signInWithPopup(auth, new GoogleAuthProvider());

export const signOut = () => auth.signOut();
