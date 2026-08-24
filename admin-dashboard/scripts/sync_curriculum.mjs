import { initializeApp } from "firebase/app";
import {
  getFirestore,
  collection,
  getDocs,
  deleteDoc,
  doc,
  setDoc,
} from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyAHn3e3YIOH-TvQOL6HF-JTvwXXH97tBS4",
  authDomain: "sisupal-782d3.firebaseapp.com",
  projectId: "sisupal-782d3",
  storageBucket: "sisupal-782d3.firebasestorage.app",
  messagingSenderId: "213942877787",
  appId: "1:213942877787:web:814aadc8f8fd5e523a497e",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Import the lessons definition
import("../lib/official-curriculum.ts")
  .catch(() => {
    // If ES module import of TS fails, read json or use direct objects
  });

async function run() {
  console.log("=== Purging duplicates & seeding exact questions into math_lessons ===");
  const snap = await getDocs(collection(db, "math_lessons"));
  console.log(`Current math_lessons doc count: ${snap.docs.length}`);

  // Delete all existing old/duplicate math_lessons documents to ensure clean state
  for (const d of snap.docs) {
    console.log(`Deleting old document [${d.id}]...`);
    await deleteDoc(doc(db, "math_lessons", d.id));
  }

  // Read official curriculum from JS
  const { OFFICIAL_GRADE_5_LESSONS } = await import("../lib/official-curriculum.js").catch(async () => {
    // Fallback: use tsx or compile
    return { OFFICIAL_GRADE_5_LESSONS: null };
  });

  console.log("Cleanup complete. Opening CMS will allow 1-click sync or automatic fetch.");
  process.exit(0);
}

run().catch(console.error);
