import { initializeApp } from "firebase/app";
import { getAuth, signInWithEmailAndPassword } from "firebase/auth";
import { getFirestore, collection, doc, setDoc, getDoc, getDocs } from "firebase/firestore";

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
  await signInWithEmailAndPassword(auth, "testadmin@gmail.com", "Admin123@");
  console.log("Logged in!");

  const testUserId = "student_kasun_01";
  await setDoc(doc(db, "users", testUserId), {
    name: "කසුන් පෙරේරා (Kasun Perera)",
    role: "student",
    isStudent: true,
    grade: 5,
    district: "Colombo",
    xp: 1450,
    streak: 7,
    school: "Royal College, Colombo",
    email: "kasun.p@sisupal.lk",
    avatarUrl: "https://api.dicebear.com/7.x/bottts/svg?seed=Kasun",
    lastActiveDate: new Date().toISOString(),
    questionAttempts: [
      {
        skillTag: "place_value_identification",
        isCorrect: true,
        hintUsed: false,
        timeTaken: 8,
        timestamp: new Date().toISOString(),
        conceptId: "c1_jungle_map",
      },
      {
        skillTag: "expanded_form",
        isCorrect: false,
        hintUsed: true,
        timeTaken: 25,
        timestamp: new Date().toISOString(),
        conceptId: "c5_unlocking_chest",
      },
    ],
  });
  console.log("  ✅ Saved student with questionAttempts embedded in users collection!");

  const readDoc = await getDoc(doc(db, "users", testUserId));
  console.log("  ✅ Read back document:", readDoc.data().name, "with", readDoc.data().questionAttempts.length, "attempts");
  process.exit(0);
}

test().catch(console.error);
