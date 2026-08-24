import { initializeApp } from "firebase/app";
import { getAuth, signInWithEmailAndPassword } from "firebase/auth";
import { getFirestore, collection, doc, setDoc, getDocs } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyAHn3e3YIOH-TvQOL6HF-JTvwXXH97tBS4",
  authDomain: "sisupal-782d3.firebaseapp.com",
  projectId: "sisupal-782d3",
  storageBucket: "sisupal-782d3.firebasestorage.app",
  messagingSenderId: "213942877787",
  appId: "1:213942877787:web:814aadc8f8fd5e523a497e",
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

async function test() {
  console.log("Signing in with testadmin@gmail.com...");
  const userCred = await signInWithEmailAndPassword(auth, "testadmin@gmail.com", "Admin123@");
  console.log(`Signed in successfully! UID: ${userCred.user.uid}`);

  const collectionsToTest = ["students", "student_roster", "users", "math_lessons", "story_quests", "game_templates"];

  for (const colName of collectionsToTest) {
    try {
      console.log(`\nTesting read on '${colName}'...`);
      const snap = await getDocs(collection(db, colName));
      console.log(`  ✅ Read succeeded: ${snap.docs.length} docs`);
    } catch (err) {
      console.log(`  ❌ Read failed: ${err.message}`);
    }

    try {
      console.log(`Testing write on '${colName}'...`);
      await setDoc(doc(db, colName, "test_doc_perm_check"), {
        test: true,
        updatedAt: new Date().toISOString(),
      });
      console.log(`  ✅ Write succeeded on '${colName}'`);
    } catch (err) {
      console.log(`  ❌ Write failed on '${colName}': ${err.message}`);
    }
  }

  process.exit(0);
}

test().catch(console.error);
