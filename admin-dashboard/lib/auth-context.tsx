"use client";

import React, { createContext, useContext, useEffect, useState, ReactNode } from "react";
import {
  User,
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut,
} from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";
import { auth, db } from "./firebase";
import { AdminUser } from "@/types";

interface AuthContextType {
  user: User | null;
  adminProfile: AdminUser | null;
  role: string | null;
  loading: boolean;
  signInWithEmail: (email: string, pass: string) => Promise<void>;
  signOutUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [adminProfile, setAdminProfile] = useState<AdminUser | null>(null);
  const [role, setRole] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      setUser(firebaseUser);
      if (firebaseUser) {
        try {
          // Check Firestore user doc for Admin/Teacher role
          const userDoc = await getDoc(doc(db, "users", firebaseUser.uid));
          if (userDoc.exists()) {
            const data = userDoc.data();
            const userRole = data.role || "Admin";
            setRole(userRole);
            setAdminProfile({
              uid: firebaseUser.uid,
              email: firebaseUser.email,
              displayName: data.name || firebaseUser.displayName || "Admin",
              role: userRole,
              photoURL: data.avatar || firebaseUser.photoURL,
            });
          } else {
            // Default to Admin role for authenticated portal users
            setRole("Admin");
            setAdminProfile({
              uid: firebaseUser.uid,
              email: firebaseUser.email,
              displayName: firebaseUser.displayName || "Administrator",
              role: "Admin",
            });
          }
        } catch (error) {
          console.warn("Could not fetch user profile from Firestore:", error);
          setRole("Admin");
          setAdminProfile({
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: "Administrator",
            role: "Admin",
          });
        }
      } else {
        setAdminProfile(null);
        setRole(null);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const signInWithEmail = async (email: string, pass: string) => {
    setLoading(true);
    try {
      await signInWithEmailAndPassword(auth, email, pass);
    } finally {
      setLoading(false);
    }
  };

  const signOutUser = async () => {
    await signOut(auth);
    setUser(null);
    setAdminProfile(null);
    setRole(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        adminProfile,
        role,
        loading,
        signInWithEmail,
        signOutUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};
