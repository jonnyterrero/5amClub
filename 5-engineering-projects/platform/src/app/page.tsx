import { ProgressCard } from "@/components/ui/ProgressCard";
import { BookOpen, CheckSquare, Clock, Trophy } from "lucide-react";

export default function Dashboard() {
  return (
    <div className="max-w-6xl mx-auto space-y-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">Good Morning, Jonny</h1>
          <p className="text-gray-500 dark:text-gray-400">Monday, December 8 • "Discipline is freedom."</p>
        </div>
        <div className="flex gap-3">
            <button className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm font-medium transition-colors">
                Start Session
            </button>
            <button className="px-4 py-2 bg-white dark:bg-darkSurface border border-gray-200 dark:border-gray-700 text-gray-700 dark:text-gray-200 rounded-md text-sm font-medium hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors">
                Quick Note
            </button>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white dark:bg-darkSurface border border-gray-200 dark:border-gray-800 p-4 rounded-lg flex items-center gap-4">
            <div className="w-10 h-10 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center text-blue-600 dark:text-blue-400">
                <Clock className="w-5 h-5" />
            </div>
            <div>
                <p className="text-sm text-gray-500 dark:text-gray-400">Study Hours</p>
                <p className="text-xl font-bold text-gray-900 dark:text-white">12.5h</p>
            </div>
        </div>
        <div className="bg-white dark:bg-darkSurface border border-gray-200 dark:border-gray-800 p-4 rounded-lg flex items-center gap-4">
            <div className="w-10 h-10 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center text-green-600 dark:text-green-400">
                <CheckSquare className="w-5 h-5" />
            </div>
            <div>
                <p className="text-sm text-gray-500 dark:text-gray-400">Tasks Done</p>
                <p className="text-xl font-bold text-gray-900 dark:text-white">8/12</p>
            </div>
        </div>
        <div className="bg-white dark:bg-darkSurface border border-gray-200 dark:border-gray-800 p-4 rounded-lg flex items-center gap-4">
            <div className="w-10 h-10 rounded-full bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center text-purple-600 dark:text-purple-400">
                <BookOpen className="w-5 h-5" />
            </div>
            <div>
                <p className="text-sm text-gray-500 dark:text-gray-400">Active Courses</p>
                <p className="text-xl font-bold text-gray-900 dark:text-white">3</p>
            </div>
        </div>
        <div className="bg-white dark:bg-darkSurface border border-gray-200 dark:border-gray-800 p-4 rounded-lg flex items-center gap-4">
            <div className="w-10 h-10 rounded-full bg-orange-100 dark:bg-orange-900/30 flex items-center justify-center text-orange-600 dark:text-orange-400">
                <Trophy className="w-5 h-5" />
            </div>
            <div>
                <p className="text-sm text-gray-500 dark:text-gray-400">Streak</p>
                <p className="text-xl font-bold text-gray-900 dark:text-white">5 Days</p>
            </div>
        </div>
      </div>

      {/* Progress Section */}
      <section>
        <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Track Progress</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <ProgressCard title="Biomedical Engineering" value={45} total={120} color="blue" />
            <ProgressCard title="Computer Science" value={30} total={90} color="green" />
            <ProgressCard title="Neuroscience" value={12} total={60} color="purple" />
        </div>
      </section>

      {/* Recent Activity / Next Up */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <section className="bg-white dark:bg-darkSurface border border-gray-200 dark:border-gray-800 rounded-lg p-6">
            <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Up Next</h2>
            <div className="space-y-4">
                {[
                    { title: "Review Linear Algebra Notes", time: "10:00 AM", tag: "Math" },
                    { title: "React Components Lab", time: "2:00 PM", tag: "CS" },
                    { title: "Neuroanatomy Quiz Prep", time: "4:30 PM", tag: "Neuro" },
                ].map((item, i) => (
                    <div key={i} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-darkBg rounded-md border border-gray-100 dark:border-gray-700/50">
                        <div className="flex items-center gap-3">
                            <div className="w-2 h-2 rounded-full bg-blue-500"></div>
                            <div>
                                <p className="font-medium text-sm text-gray-900 dark:text-white">{item.title}</p>
                                <p className="text-xs text-gray-500">{item.time}</p>
                            </div>
                        </div>
                        <span className="text-xs px-2 py-1 bg-gray-200 dark:bg-gray-700 rounded text-gray-600 dark:text-gray-300">{item.tag}</span>
                    </div>
                ))}
            </div>
        </section>

        <section className="bg-white dark:bg-darkSurface border border-gray-200 dark:border-gray-800 rounded-lg p-6">
            <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Weekly Focus</h2>
            <div className="space-y-4">
                <div className="p-4 bg-gradient-to-br from-indigo-500/10 to-purple-500/10 border border-indigo-500/20 rounded-lg">
                    <h3 className="font-medium text-indigo-400 text-sm uppercase tracking-wide mb-1">Theme</h3>
                    <p className="text-lg font-semibold text-gray-900 dark:text-white">Deep Work & System Design</p>
                    <p className="text-sm text-gray-500 mt-2">Focus on migrating the platform architecture and finalizing the BME study plan.</p>
                </div>
            </div>
        </section>
      </div>
    </div>
  );
}
