"use client";

import React, { useState } from "react";
import { Copy, Check, Code2, Sparkles, FileJson } from "lucide-react";

interface LiveJsonPreviewerProps {
  data: any;
  title?: string;
}

export default function LiveJsonPreviewer({
  data,
  title = "Live Firestore Payload (gameData)",
}: LiveJsonPreviewerProps) {
  const [copied, setCopied] = useState(false);

  const jsonString = JSON.stringify(data, null, 2);
  const byteSize = new Blob([jsonString]).size;

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(jsonString);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (e) {
      console.error("Copy failed", e);
    }
  };

  // Syntax highlighting helper for JSON string
  const formatJsonSyntax = (json: string) => {
    return json.replace(
      /("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g,
      (match) => {
        let cls = "text-amber-300"; // number
        if (/^"/.test(match)) {
          if (/:$/.test(match)) {
            cls = "text-purple-300 font-semibold"; // key
          } else {
            cls = "text-emerald-300"; // string
          }
        } else if (/true|false/.test(match)) {
          cls = "text-pink-400 font-bold"; // boolean
        } else if (/null/.test(match)) {
          cls = "text-slate-500 italic"; // null
        }
        return `<span class="${cls}">${match}</span>`;
      }
    );
  };

  return (
    <div className="rounded-2xl glass-panel border border-purple-500/20 overflow-hidden shadow-xl flex flex-col h-full">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 bg-[#120E33] border-b border-slate-800">
        <div className="flex items-center gap-2">
          <div className="p-1 rounded-md bg-purple-500/20 text-purple-300">
            <FileJson className="w-3.5 h-3.5" />
          </div>
          <span className="text-xs font-bold text-white">{title}</span>
          <span className="text-[10px] px-1.5 py-0.2 rounded bg-slate-800 text-slate-400 font-mono">
            {byteSize} B
          </span>
        </div>

        <button
          type="button"
          onClick={handleCopy}
          className="flex items-center gap-1 px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-[11px] font-semibold text-slate-300 hover:text-white transition-colors"
        >
          {copied ? (
            <>
              <Check className="w-3 h-3 text-emerald-400" />
              <span className="text-emerald-400">Copied!</span>
            </>
          ) : (
            <>
              <Copy className="w-3 h-3" />
              <span>Copy JSON</span>
            </>
          )}
        </button>
      </div>

      {/* Code Block Container */}
      <div className="p-4 bg-[#0B0920] font-mono text-[11px] leading-relaxed overflow-x-auto max-h-[380px] overflow-y-auto flex-1 select-text scrollbar-thin">
        <pre
          className="text-slate-300"
          dangerouslySetInnerHTML={{ __html: formatJsonSyntax(jsonString) }}
        />
      </div>
    </div>
  );
}
