import {
  collection,
  doc,
  getDocs,
  addDoc,
  setDoc,
  deleteDoc,
  query,
  orderBy,
  serverTimestamp,
  DocumentData,
  QueryConstraint,
} from "firebase/firestore";
import { db } from "./firebase";

/**
 * Generic fetch all documents from a Firestore collection
 */
export async function fetchCollection<T extends { id?: string }>(
  collectionName: string,
  sortField?: string,
  sortDirection: "asc" | "desc" = "desc"
): Promise<T[]> {
  try {
    const colRef = collection(db, collectionName);
    const constraints: QueryConstraint[] = [];

    if (sortField) {
      constraints.push(orderBy(sortField, sortDirection));
    }

    const q = constraints.length > 0 ? query(colRef, ...constraints) : colRef;
    const snapshot = await getDocs(q);

    return snapshot.docs.map((docSnap) => ({
      id: docSnap.id,
      ...docSnap.data(),
    })) as T[];
  } catch (error) {
    console.error(`Error fetching collection '${collectionName}':`, error);
    // Fallback without sort if index is missing
    const fallbackSnap = await getDocs(collection(db, collectionName));
    return fallbackSnap.docs.map((docSnap) => ({
      id: docSnap.id,
      ...docSnap.data(),
    })) as T[];
  }
}

/**
 * Generic create document in a Firestore collection
 */
export async function createDocument<T extends DocumentData>(
  collectionName: string,
  data: T
): Promise<string> {
  const colRef = collection(db, collectionName);
  const docRef = await addDoc(colRef, {
    ...data,
    createdAt: serverTimestamp(),
    timestamp: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  return docRef.id;
}

/**
 * Set document with a deterministic ID (clean upsert without auto-ID duplicates)
 */
export async function setDocumentWithId<T extends DocumentData>(
  collectionName: string,
  id: string,
  data: T
): Promise<void> {
  const docRef = doc(db, collectionName, id);
  await setDoc(docRef, {
    ...data,
    updatedAt: serverTimestamp(),
  });
}

/**
 * Generic update/upsert document in a Firestore collection
 */
export async function updateDocument<T extends DocumentData>(
  collectionName: string,
  id: string,
  data: Partial<T>
): Promise<void> {
  const docRef = doc(db, collectionName, id);
  await setDoc(
    docRef,
    {
      ...data,
      updatedAt: serverTimestamp(),
    },
    { merge: true }
  );
}

/**
 * Generic delete document from a Firestore collection
 */
export async function deleteDocument(
  collectionName: string,
  id: string
): Promise<void> {
  const docRef = doc(db, collectionName, id);
  await deleteDoc(docRef);
}

/**
 * Fetch documents from a subcollection (e.g. students/{studentId}/question_attempts)
 */
export async function fetchSubcollection<T extends { id?: string }>(
  parentCollection: string,
  parentId: string,
  subCollectionName: string,
  sortField?: string,
  sortDirection: "asc" | "desc" = "desc"
): Promise<T[]> {
  try {
    const subColRef = collection(db, parentCollection, parentId, subCollectionName);
    const constraints: QueryConstraint[] = [];

    if (sortField) {
      constraints.push(orderBy(sortField, sortDirection));
    }

    const q = constraints.length > 0 ? query(subColRef, ...constraints) : subColRef;
    const snapshot = await getDocs(q);

    return snapshot.docs.map((docSnap) => ({
      id: docSnap.id,
      ...docSnap.data(),
    })) as T[];
  } catch (error) {
    console.error(`Error fetching subcollection '${subCollectionName}':`, error);
    try {
      const fallbackSnap = await getDocs(
        collection(db, parentCollection, parentId, subCollectionName)
      );
      return fallbackSnap.docs.map((docSnap) => ({
        id: docSnap.id,
        ...docSnap.data(),
      })) as T[];
    } catch (e) {
      return [];
    }
  }
}

/**
 * Add document to a subcollection
 */
export async function createSubcollectionDoc<T extends DocumentData>(
  parentCollection: string,
  parentId: string,
  subCollectionName: string,
  data: T
): Promise<string> {
  const subColRef = collection(db, parentCollection, parentId, subCollectionName);
  const docRef = await addDoc(subColRef, {
    ...data,
    createdAt: serverTimestamp(),
    timestamp: serverTimestamp(),
  });
  return docRef.id;
}

/**
 * Set document with ID in a subcollection
 */
export async function setSubcollectionDocWithId<T extends DocumentData>(
  parentCollection: string,
  parentId: string,
  subCollectionName: string,
  docId: string,
  data: T
): Promise<void> {
  const docRef = doc(db, parentCollection, parentId, subCollectionName, docId);
  await setDoc(docRef, {
    ...data,
    createdAt: serverTimestamp(),
    timestamp: serverTimestamp(),
  });
}

/**
 * Helper to extract YouTube Video ID from any YouTube URL format
 */
export function extractYoutubeId(url: string): string {
  if (!url) return "";
  const regExp =
    /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
  const match = url.match(regExp);
  return match && match[2].length === 11 ? match[2] : "";
}

/**
 * Helper to generate HQ YouTube thumbnail URL
 */
export function getYoutubeThumbnail(url: string): string {
  const id = extractYoutubeId(url);
  return id ? `https://img.youtube.com/vi/${id}/hqdefault.jpg` : "";
}
