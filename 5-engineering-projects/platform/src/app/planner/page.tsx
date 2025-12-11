import KanbanBoard from "@/components/kanban/KanbanBoard";

export default function PlannerPage() {
  return (
    <div className="h-[calc(100vh-4rem)] flex flex-col">
      <div className="mb-6 flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Weekly Planner</h1>
          <p className="text-gray-500 dark:text-gray-400">Manage your tasks and study sessions.</p>
        </div>
      </div>
      
      <div className="flex-1 overflow-hidden">
        <KanbanBoard />
      </div>
    </div>
  );
}

