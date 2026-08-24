import { initializeApp } from "firebase/app";
import { getFirestore, collection, getDocs, doc, deleteDoc } from "firebase/firestore";

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

async function cleanVideos() {
  console.log("Fetching all video documents from Firestore 'videos' collection...");
  const colRef = collection(db, "videos");
  const snapshot = await getDocs(colRef);

  console.log(`Total video documents found: ${snapshot.docs.length}`);

  let grade5Count = 0;
  let toDeleteDocs = [];

  for (const docSnap of snapshot.docs) {
    const data = docSnap.data();
    const targetGrade = data.targetGrade ?? data.grade;
    const title = data.title || "";

    // Determine if it is Grade 3 or Grade 4
    const isGrade3or4 =
      targetGrade === 3 ||
      targetGrade === 4 ||
      targetGrade === "3" ||
      targetGrade === "4" ||
      title.includes("Grade 3") ||
      title.includes("Grade 4") ||
      title.includes("3 ශ්‍රේණිය") ||
      title.includes("4 ශ්‍රේණිය");

    const isExplicitGrade5 =
      targetGrade === 5 ||
      targetGrade === "5" ||
      title.includes("Grade 5") ||
      title.includes("5 ශ්‍රේණිය") ||
      title.includes("Scholarship") ||
      title.includes("ශිෂ්‍යත්ව");

    if (isGrade3or4 && !isExplicitGrade5) {
      toDeleteDocs.push({ id: docSnap.id, title, grade: targetGrade });
    } else {
      grade5Count++;
      console.log(`[KEEP] Grade 5 Video -> ${docSnap.id}: "${title}" (grade: ${targetGrade})`);
    }
  }

  console.log(`\n========================================`);
  console.log(`Summary:`);
  console.log(`Grade 5 videos to KEEP: ${grade5Count}`);
  console.log(`Grade 3/4 videos to DELETE: ${toDeleteDocs.length}`);
  console.log(`========================================\n`);

  for (const item of toDeleteDocs) {
    console.log(`Deleting [Grade ${item.grade}] ${item.id}: "${item.title}"`);
    await deleteDoc(doc(db, "videos", item.id));
  }

  console.log(`\nSuccessfully deleted ${toDeleteDocs.length} Grade 3 & Grade 4 videos from Firestore!`);
  process.exit(0);
}

cleanVideos().catch((err) => {
  console.error("Error cleaning videos:", err);
  process.exit(1);
});
