"use client";

import React, { createContext, useContext, useState, useCallback, ReactNode } from "react";
import { CheckCircle2, AlertTriangle, AlertCircle, Info, X } from "lucide-react";
import { ToastMessage } from "@/types";

interface ToastContextType {
  showToast: (title: string, type?: "success" | "error" | "info" | "warning", description?: string) => void;
  dismissToast: (id: string) => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

export const ToastProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [toasts, setToasts] = useState<ToastMessage[]>([]);

  const dismissToast = useCallback((id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  }, []);

  const showToast = useCallback((title: string, type: "success" | "error" | "info" | "warning" = "info", description?: string) => {
    const id = `${Date.now()}-${Math.random().toString(36).substring(2, 6)}`;
    const newToast: ToastMessage = { id, title, type, description };

    setToasts((prev) => {
      // Prevent duplicate messages
      if (prev.some((t) => t.title === title && t.type === type)) {
        return prev;
      }
      return [...prev.slice(-2), newToast];
    });

    setTimeout(() => {
      dismissToast(id);
    }, 4000);
  }, [dismissToast]);

  return (
    <ToastContext.Provider value={{ showToast, dismissToast }}>
      {children}
      <div className="fixed bottom-5 right-5 z-50 flex flex-col gap-2 max-w-sm w-full pointer-events-none">
        {toasts.map((toast) => {
          const colors = {
            success: "bg-emerald-950/90 border-emerald-500/40 text-emerald-200",
            error: "bg-rose-950/90 border-rose-500/40 text-rose-200",
            warning: "bg-amber-950/90 border-amber-500/40 text-amber-200",
            info: "bg-indigo-950/90 border-indigo-500/40 text-indigo-200",
          }[toast.type];

          const IconComponent = {
            success: CheckCircle2,
            error: AlertCircle,
            warning: AlertTriangle,
            info: Info,
          }[toast.type];

          return (
            <div
              key={toast.id}
              className={`pointer-events-auto p-4 rounded-xl border backdrop-blur-xl shadow-2xl flex items-start gap-3 transition-all duration-300 transform translate-y-0 ${colors}`}
            >
              <IconComponent className="w-5 h-5 flex-shrink-0 mt-0.5" />
              <div className="flex-1 text-xs">
                <p className="font-bold">{toast.title}</p>
                {toast.description && <p className="opacity-80 mt-0.5">{toast.description}</p>}
              </div>
              <button
                onClick={() => dismissToast(toast.id)}
                className="opacity-60 hover:opacity-100 transition-opacity p-0.5"
              >
                <X className="w-4 h-4" />
              </button>
            </div>
          );
        })}
      </div>
    </ToastContext.Provider>
  );
};

export const useToast = () => {
  const context = useContext(ToastContext);
  if (!context) {
    throw new Error("useToast must be used within a ToastProvider");
  }
  return context;
};
