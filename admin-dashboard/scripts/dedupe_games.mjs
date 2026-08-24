import { initializeApp } from "firebase/app";
import { getFirestore, collection, getDocs, doc, deleteDoc, setDoc, serverTimestamp } from "firebase/firestore";

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

async function inspectAndDedupe() {
  console.log("Fetching math_games collection...");
  const snap = await getDocs(collection(db, "math_games"));
  console.log(`Total documents found: ${snap.docs.length}`);

  const seenTitles = new Map();
  const duplicateIds = [];

  for (const docSnap of snap.docs) {
    const data = docSnap.data();
    const title = (data.title || "").trim();
    console.log(`- Doc [${docSnap.id}] Title: "${title}" | Template: ${data.templateType} | Status: ${data.status}`);

    if (seenTitles.has(title)) {
      // Duplicate found!
      duplicateIds.push({ id: docSnap.id, title });
    } else {
      seenTitles.set(title, docSnap.id);
    }
  }

  console.log(`\nUnique games: ${seenTitles.size}`);
  console.log(`Duplicates to remove: ${duplicateIds.length}`);

  for (const dup of duplicateIds) {
    console.log(`Deleting duplicate doc: ${dup.id} ("${dup.title}")`);
    await deleteDoc(doc(db, "math_games", dup.id));
  }

  console.log("Deduplication complete!");
  process.exit(0);
}

inspectAndDedupe().catch((err) => {
  console.error("Error:", err);
  process.exit(1);
});
