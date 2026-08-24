"use client";

import React, { useState, useMemo, ReactNode } from "react";
import { Search, Plus, Edit2, Trash2, ChevronLeft, ChevronRight, Inbox } from "lucide-react";

export interface ColumnDef<T> {
  header: string;
  accessorKey?: keyof T;
  cell?: (item: T) => ReactNode;
  className?: string;
}

interface DataTableProps<T> {
  data: T[];
  columns: ColumnDef<T>[];
  searchPlaceholder?: string;
  searchFilter: (item: T, query: string) => boolean;
  onAdd?: () => void;
  addLabel?: string;
  onEdit?: (item: T) => void;
  onDelete?: (item: T) => void;
  loading?: boolean;
  emptyTitle?: string;
  emptySubtitle?: string;
  pageSize?: number;
}

export default function DataTable<T extends { id?: string }>({
  data,
  columns,
  searchPlaceholder = "Search records...",
  searchFilter,
  onAdd,
  addLabel = "Add New",
  onEdit,
  onDelete,
  loading = false,
  emptyTitle = "No records found",
  emptySubtitle = "Create your first record or try a different search filter.",
  pageSize = 10,
}: DataTableProps<T>) {
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);

  // Filter items
  const filteredData = useMemo(() => {
    if (!searchQuery.trim()) return data;
    return data.filter((item) => searchFilter(item, searchQuery.toLowerCase().trim()));
  }, [data, searchQuery, searchFilter]);

  // Pagination calculations
  const totalPages = Math.ceil(filteredData.length / pageSize) || 1;
  const paginatedData = useMemo(() => {
    const start = (currentPage - 1) * pageSize;
    return filteredData.slice(start, start + pageSize);
  }, [filteredData, currentPage, pageSize]);

  return (
    <div className="space-y-4">
      {/* Table Toolbar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => {
              setSearchQuery(e.target.value);
              setCurrentPage(1);
            }}
            placeholder={searchPlaceholder}
            className="w-full pl-10 pr-4 py-2.5 rounded-xl glass-input text-xs focus:outline-none transition-all placeholder:text-slate-500"
          />
        </div>

        {onAdd && (
          <button
            onClick={onAdd}
            className="px-4 py-2.5 rounded-xl bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-500 hover:to-indigo-500 text-white font-bold text-xs shadow-lg shadow-purple-600/30 transition-all flex items-center justify-center gap-2 flex-shrink-0 cursor-pointer"
          >
            <Plus className="w-4 h-4" />
            <span>{addLabel}</span>
          </button>
        )}
      </div>

      {/* Table Container */}
      <div className="rounded-2xl glass-panel overflow-hidden border border-slate-800 shadow-xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="border-b border-slate-800 bg-[#120E33]/60 text-slate-400 font-semibold uppercase tracking-wider text-[11px]">
                {columns.map((col, idx) => (
                  <th key={idx} className={`py-3.5 px-4 ${col.className || ""}`}>
                    {col.header}
                  </th>
                ))}
                {(onEdit || onDelete) && (
                  <th className="py-3.5 px-4 text-right">Actions</th>
                )}
              </tr>
            </thead>

            <tbody className="divide-y divide-slate-800/60">
              {loading ? (
                // Loading Skeleton Rows
                Array.from({ length: 5 }).map((_, rIdx) => (
                  <tr key={rIdx} className="animate-pulse">
                    {columns.map((_, cIdx) => (
                      <td key={cIdx} className="py-4 px-4">
                        <div className="h-4 bg-slate-800 rounded-md w-3/4" />
                      </td>
                    ))}
                    {(onEdit || onDelete) && (
                      <td className="py-4 px-4 text-right">
                        <div className="h-4 bg-slate-800 rounded-md w-16 ml-auto" />
                      </td>
                    )}
                  </tr>
                ))
              ) : paginatedData.length === 0 ? (
                // Empty State Row
                <tr>
                  <td
                    colSpan={columns.length + (onEdit || onDelete ? 1 : 0)}
                    className="py-12 px-4 text-center"
                  >
                    <div className="max-w-xs mx-auto space-y-2">
                      <div className="w-12 h-12 rounded-2xl bg-slate-800/80 text-slate-500 flex items-center justify-center mx-auto">
                        <Inbox className="w-6 h-6" />
                      </div>
                      <h4 className="text-sm font-bold text-white">{emptyTitle}</h4>
                      <p className="text-xs text-slate-400">{emptySubtitle}</p>
                    </div>
                  </td>
                </tr>
              ) : (
                // Data Rows
                paginatedData.map((item, idx) => (
                  <tr
                    key={item.id || idx}
                    className="hover:bg-purple-950/20 transition-colors group"
                  >
                    {columns.map((col, cIdx) => (
                      <td key={cIdx} className={`py-3.5 px-4 text-slate-200 ${col.className || ""}`}>
                        {col.cell
                          ? col.cell(item)
                          : col.accessorKey
                          ? String(item[col.accessorKey] ?? "")
                          : null}
                      </td>
                    ))}

                    {(onEdit || onDelete) && (
                      <td className="py-3.5 px-4 text-right">
                        <div className="flex items-center justify-end gap-1.5 opacity-80 group-hover:opacity-100 transition-opacity">
                          {onEdit && (
                            <button
                              onClick={() => onEdit(item)}
                              title="Edit Record"
                              className="p-1.5 rounded-lg text-slate-400 hover:text-purple-300 hover:bg-purple-500/10 transition-colors"
                            >
                              <Edit2 className="w-3.5 h-3.5" />
                            </button>
                          )}
                          {onDelete && (
                            <button
                              onClick={() => onDelete(item)}
                              title="Delete Record"
                              className="p-1.5 rounded-lg text-slate-400 hover:text-rose-400 hover:bg-rose-500/10 transition-colors"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          )}
                        </div>
                      </td>
                    )}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination Footer */}
        {!loading && filteredData.length > pageSize && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-slate-800 bg-[#120E33]/40 text-xs text-slate-400">
            <div>
              Showing{" "}
              <span className="font-semibold text-white">
                {(currentPage - 1) * pageSize + 1}
              </span>{" "}
              to{" "}
              <span className="font-semibold text-white">
                {Math.min(currentPage * pageSize, filteredData.length)}
              </span>{" "}
              of <span className="font-semibold text-white">{filteredData.length}</span> records
            </div>

            <div className="flex items-center gap-1.5">
              <button
                onClick={() => setCurrentPage((p) => Math.max(p - 1, 1))}
                disabled={currentPage === 1}
                className="p-1.5 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
              <span className="px-2 font-medium text-white">
                {currentPage} / {totalPages}
              </span>
              <button
                onClick={() => setCurrentPage((p) => Math.min(p + 1, totalPages))}
                disabled={currentPage === totalPages}
                className="p-1.5 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
