"use client";

import { useState, useEffect } from "react";
import { BookOpen, Plus, ExternalLink, Trash2 } from "lucide-react";
import clsx from "clsx";

interface Course {
  id: string;
  title: string;
  code: string;
  status: "NOT_STARTED" | "IN_PROGRESS" | "COMPLETED";
  track: {
    title: string;
    color: string;
  };
  _count: {
    resources: number;
    tasks: number;
  };
}

export default function CoursesPage() {
  const [courses, setCourses] = useState<Course[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchCourses();
  }, []);

  const fetchCourses = async () => {
    try {
      const res = await fetch("/api/courses");
      if (res.ok) {
        const data = await res.json();
        setCourses(data);
      }
    } catch (error) {
      console.error("Failed to fetch courses", error);
    } finally {
      setIsLoading(false);
    }
  };

  const statusColors = {
    NOT_STARTED: "bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400",
    IN_PROGRESS: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300",
    COMPLETED: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300",
  };

  return (
    <div className="max-w-6xl mx-auto">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">Courses</h1>
          <p className="text-gray-500 dark:text-gray-400">Track your academic progress across all disciplines.</p>
        </div>
        <button className="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md transition-colors font-medium">
          <Plus className="w-4 h-4" />
          Add Course
        </button>
      </div>

      {isLoading ? (
        <div className="text-center py-12 text-gray-500">Loading courses...</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {courses.map((course) => (
            <div key={course.id} className="bg-white dark:bg-darkSurface border border-gray-200 dark:border-gray-800 rounded-lg p-6 hover:shadow-lg transition-shadow group">
              <div className="flex justify-between items-start mb-4">
                <div className="w-10 h-10 rounded bg-gray-100 dark:bg-gray-800 flex items-center justify-center text-gray-600 dark:text-gray-300">
                  <BookOpen className="w-5 h-5" />
                </div>
                <span className={clsx("text-xs font-semibold px-2 py-1 rounded-full", statusColors[course.status])}>
                  {course.status.replace("_", " ")}
                </span>
              </div>
              
              <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-1">{course.title}</h3>
              <p className="text-sm text-gray-500 mb-4">{course.code} • <span className="text-blue-500">{course.track?.title || "General"}</span></p>
              
              <div className="flex items-center gap-4 text-sm text-gray-500 dark:text-gray-400 border-t border-gray-100 dark:border-gray-700 pt-4">
                <div className="flex items-center gap-1">
                    <span className="font-semibold text-gray-900 dark:text-white">{course._count?.resources || 0}</span> Resources
                </div>
                <div className="flex items-center gap-1">
                    <span className="font-semibold text-gray-900 dark:text-white">{course._count?.tasks || 0}</span> Tasks
                </div>
              </div>
            </div>
          ))}

          {/* Empty State / Add New */}
          <button className="border-2 border-dashed border-gray-200 dark:border-gray-800 rounded-lg p-6 flex flex-col items-center justify-center text-gray-400 hover:text-blue-500 hover:border-blue-500 transition-colors h-full min-h-[200px]">
            <Plus className="w-8 h-8 mb-2" />
            <span className="font-medium">Add New Course</span>
          </button>
        </div>
      )}
    </div>
  );
}

