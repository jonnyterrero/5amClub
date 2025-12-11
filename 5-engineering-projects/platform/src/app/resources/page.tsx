"use client";

import { useState, useEffect } from "react";
import { Search, Filter, ExternalLink, FileText, Video, Book } from "lucide-react";

interface Resource {
  id: string;
  title: string;
  type: "BOOK" | "VIDEO" | "ARTICLE" | "COURSE";
  url: string;
  isCompleted: boolean;
}

export default function ResourcesPage() {
  const [resources, setResources] = useState<Resource[]>([]);
  const [filter, setFilter] = useState("ALL");

  useEffect(() => {
    // In a real app, fetch from /api/resources
    // Mock data for UI development
    setResources([
      { id: "1", title: "Introduction to Linear Algebra (Strang)", type: "BOOK", url: "#", isCompleted: false },
      { id: "2", title: "Andrew Ng Machine Learning", type: "COURSE", url: "#", isCompleted: true },
      { id: "3", title: "Neuroscience: Exploring the Brain", type: "BOOK", url: "#", isCompleted: false },
    ]);
  }, []);

  const getIcon = (type: string) => {
    switch (type) {
      case "VIDEO": return <Video className="w-4 h-4" />;
      case "BOOK": return <Book className="w-4 h-4" />;
      default: return <FileText className="w-4 h-4" />;
    }
  };

  return (
    <div className="max-w-5xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white">Resource Library</h1>
        <p className="text-gray-500 dark:text-gray-400">Curated collection of textbooks, papers, and lectures.</p>
      </div>

      <div className="flex flex-col md:flex-row gap-4 mb-6">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input 
            type="text" 
            placeholder="Search resources..." 
            className="w-full pl-10 pr-4 py-2 bg-white dark:bg-darkSurface border border-gray-200 dark:border-gray-800 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 dark:text-white"
          />
        </div>
        <div className="flex gap-2">
            {["ALL", "BOOK", "VIDEO", "ARTICLE"].map((type) => (
                <button 
                    key={type}
                    onClick={() => setFilter(type)}
                    className={`px-4 py-2 text-sm font-medium rounded-md transition-colors ${
                        filter === type 
                        ? "bg-gray-900 dark:bg-white text-white dark:text-black" 
                        : "bg-white dark:bg-darkSurface text-gray-600 dark:text-gray-300 border border-gray-200 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-gray-800"
                    }`}
                >
                    {type}
                </button>
            ))}
        </div>
      </div>

      <div className="bg-white dark:bg-darkSurface border border-gray-200 dark:border-gray-800 rounded-lg overflow-hidden">
        <table className="w-full text-left border-collapse">
            <thead className="bg-gray-50 dark:bg-gray-800/50 text-xs uppercase text-gray-500 font-medium">
                <tr>
                    <th className="px-6 py-3">Type</th>
                    <th className="px-6 py-3">Title</th>
                    <th className="px-6 py-3">Status</th>
                    <th className="px-6 py-3 text-right">Action</th>
                </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-gray-800">
                {resources.map((resource) => (
                    <tr key={resource.id} className="hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors">
                        <td className="px-6 py-4">
                            <span className="inline-flex items-center gap-2 px-2.5 py-1 rounded-full text-xs font-medium bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300">
                                {getIcon(resource.type)}
                                {resource.type}
                            </span>
                        </td>
                        <td className="px-6 py-4 text-sm font-medium text-gray-900 dark:text-white">
                            {resource.title}
                        </td>
                        <td className="px-6 py-4">
                            {resource.isCompleted ? (
                                <span className="text-green-600 text-xs font-bold bg-green-100 dark:bg-green-900/30 px-2 py-1 rounded">COMPLETED</span>
                            ) : (
                                <span className="text-gray-500 text-xs">To Read</span>
                            )}
                        </td>
                        <td className="px-6 py-4 text-right">
                            <a href={resource.url} className="text-blue-500 hover:text-blue-600 inline-flex items-center gap-1 text-sm">
                                Open <ExternalLink className="w-3 h-3" />
                            </a>
                        </td>
                    </tr>
                ))}
            </tbody>
        </table>
      </div>
    </div>
  );
}

