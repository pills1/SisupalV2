import { initializeApp } from "firebase/app";
import { getFirestore, collection, getDocs } from "firebase/firestore";

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

async function inspect() {
  console.log("=== Inspecting math_lessons ===");
  const lessonsSnap = await getDocs(collection(db, "math_lessons"));
  console.log(`math_lessons total: ${lessonsSnap.docs.length}`);
  lessonsSnap.docs.forEach((d) => console.log(`- [${d.id}] ${d.data().title}`));

  console.log("\n=== Inspecting story_quests ===");
  const questsSnap = await getDocs(collection(db, "story_quests"));
  console.log(`story_quests total: ${questsSnap.docs.length}`);
  questsSnap.docs.forEach((d) => console.log(`- [${d.id}] ${d.data().title}`));

  process.exit(0);
}

inspect().catch(console.error);
