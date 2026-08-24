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
  const userCred = await signInWithEmailAndPassword(auth, "testadmin@gmail.com", "Admin123@");
  console.log(`Signed in! UID: ${userCred.user.uid}`);

  const testUserId = "student_kasun_01";
  console.log(`Testing write on users/${testUserId}...`);
  try {
    await setDoc(doc(db, "users", testUserId), {
      name: "කසුන් පෙරේරා (Kasun Perera)",
      role: "student",
      grade: 5,
      district: "Colombo",
      xp: 1450,
      streak: 7,
      isStudent: true,
      lastActiveDate: new Date().toISOString(),
    });
    console.log("  ✅ Succeeded write to users!");
  } catch (err) {
    console.log("  ❌ Failed write to users:", err.message);
  }

  console.log(`Testing subcollection users/${testUserId}/question_attempts...`);
  try {
    await setDoc(doc(db, "users", testUserId, "question_attempts", "att_1"), {
      skillTag: "place_value_identification",
      isCorrect: true,
      hintUsed: false,
      timeTaken: 10,
      timestamp: new Date().toISOString(),
    });
    console.log("  ✅ Succeeded write to subcollection users/{id}/question_attempts!");
  } catch (err) {
    console.log("  ❌ Failed write to subcollection users/{id}/question_attempts:", err.message);
  }

  process.exit(0);
}

test().catch(console.error);
