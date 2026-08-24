import { initializeApp } from "firebase/app";
import { getAuth, signInWithEmailAndPassword } from "firebase/auth";
import { getFirestore, doc, setDoc, getDocs, collection, deleteDoc } from "firebase/firestore";

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

// Import compiled or raw revision questions
import { OFFICIAL_REVISION_QUESTIONS } from "../lib/official-revision-bank.ts";

async function seed() {
  console.log("Signing in with testadmin@gmail.com...");
  await signInWithEmailAndPassword(auth, "testadmin@gmail.com", "Admin123@");
  console.log("Logged in successfully!");

  console.log(`\nSeeding ${OFFICIAL_REVISION_QUESTIONS.length} unique Grade 5 revision questions into 'questions' collection...`);

  let count = 0;
  for (const q of OFFICIAL_REVISION_QUESTIONS) {
    const { id, ...data } = q;
    await setDoc(doc(db, "questions", id), {
      ...data,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });
    count++;
    console.log(`  [${count}/${OFFICIAL_REVISION_QUESTIONS.length}] Seeded: ${id} - ${q.questionText.slice(0, 45)}...`);
  }

  console.log(`\n🎉 Successfully seeded all ${count} revision questions into Firestore 'questions' collection!`);
  process.exit(0);
}

seed().catch(console.error);
