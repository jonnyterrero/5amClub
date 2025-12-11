"use client";

import { DragDropContext, Droppable, Draggable, DropResult } from "@hello-pangea/dnd";
import { useState } from "react";
import { Plus, MoreHorizontal } from "lucide-react";
import clsx from "clsx";

type Task = {
  id: string;
  content: string;
  tag?: string;
};

type Column = {
  id: string;
  title: string;
  tasks: Task[];
};

const initialData: Column[] = [
  {
    id: "todo",
    title: "To Do",
    tasks: [
      { id: "t1", content: "Review Linear Algebra", tag: "Math" },
      { id: "t2", content: "Setup Next.js Project", tag: "Dev" },
    ],
  },
  {
    id: "in_progress",
    title: "In Progress",
    tasks: [
      { id: "t3", content: "Migrate Dashboard UI", tag: "Dev" },
    ],
  },
  {
    id: "done",
    title: "Done",
    tasks: [
      { id: "t4", content: "Initialize Repo", tag: "Dev" },
    ],
  },
];

export default function KanbanBoard() {
  const [columns, setColumns] = useState<Column[]>(initialData);

  const onDragEnd = (result: DropResult) => {
    const { source, destination } = result;

    if (!destination) return;

    // If dropped in the same column
    if (source.droppableId === destination.droppableId) {
      const columnIndex = columns.findIndex((c) => c.id === source.droppableId);
      const column = columns[columnIndex];
      const newTasks = Array.from(column.tasks);
      const [movedTask] = newTasks.splice(source.index, 1);
      newTasks.splice(destination.index, 0, movedTask);

      const newColumns = [...columns];
      newColumns[columnIndex] = { ...column, tasks: newTasks };
      setColumns(newColumns);
    } else {
      // If dropped in a different column
      const sourceColIndex = columns.findIndex((c) => c.id === source.droppableId);
      const destColIndex = columns.findIndex((c) => c.id === destination.droppableId);
      
      const sourceCol = columns[sourceColIndex];
      const destCol = columns[destColIndex];

      const sourceTasks = Array.from(sourceCol.tasks);
      const destTasks = Array.from(destCol.tasks);

      const [movedTask] = sourceTasks.splice(source.index, 1);
      destTasks.splice(destination.index, 0, movedTask);

      const newColumns = [...columns];
      newColumns[sourceColIndex] = { ...sourceCol, tasks: sourceTasks };
      newColumns[destColIndex] = { ...destCol, tasks: destTasks };
      setColumns(newColumns);
    }
  };

  return (
    <div className="h-full overflow-x-auto">
      <div className="flex gap-6 h-full min-w-full pb-4">
        <DragDropContext onDragEnd={onDragEnd}>
          {columns.map((column) => (
            <div key={column.id} className="w-80 flex-shrink-0 flex flex-col bg-gray-100 dark:bg-[#1E1E1E] rounded-lg border border-gray-200 dark:border-gray-800 h-fit max-h-full">
              {/* Column Header */}
              <div className="p-3 flex justify-between items-center border-b border-gray-200 dark:border-gray-800">
                <div className="flex items-center gap-2">
                  <h3 className="font-semibold text-gray-700 dark:text-gray-200 text-sm">
                    {column.title}
                  </h3>
                  <span className="text-xs bg-gray-200 dark:bg-gray-700 px-2 py-0.5 rounded-full text-gray-500 dark:text-gray-400">
                    {column.tasks.length}
                  </span>
                </div>
                <div className="flex gap-1">
                    <button className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200">
                        <Plus className="w-4 h-4" />
                    </button>
                    <button className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200">
                        <MoreHorizontal className="w-4 h-4" />
                    </button>
                </div>
              </div>

              {/* Tasks */}
              <Droppable droppableId={column.id}>
                {(provided) => (
                  <div
                    {...provided.droppableProps}
                    ref={provided.innerRef}
                    className="p-3 space-y-3 overflow-y-auto min-h-[100px]"
                  >
                    {column.tasks.map((task, index) => (
                      <Draggable key={task.id} draggableId={task.id} index={index}>
                        {(provided, snapshot) => (
                          <div
                            ref={provided.innerRef}
                            {...provided.draggableProps}
                            {...provided.dragHandleProps}
                            className={clsx(
                              "bg-white dark:bg-[#2C2C2C] p-3 rounded shadow-sm border border-gray-200 dark:border-gray-700 group hover:shadow-md transition-shadow",
                              snapshot.isDragging && "ring-2 ring-blue-500 rotate-2 opacity-90"
                            )}
                          >
                            <div className="flex justify-between items-start mb-2">
                                <span className="text-xs font-medium px-2 py-0.5 rounded bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300">
                                    {task.tag}
                                </span>
                            </div>
                            <p className="text-sm font-medium text-gray-800 dark:text-gray-200">
                              {task.content}
                            </p>
                          </div>
                        )}
                      </Draggable>
                    ))}
                    {provided.placeholder}
                  </div>
                )}
              </Droppable>
              
              {/* Add Task Button Footer */}
              <button className="m-3 mt-0 py-2 flex items-center justify-center gap-2 text-sm text-gray-500 hover:bg-gray-200 dark:hover:bg-gray-700/50 rounded transition-colors border border-dashed border-gray-300 dark:border-gray-700">
                <Plus className="w-4 h-4" />
                Add Task
              </button>
            </div>
          ))}
        </DragDropContext>
      </div>
    </div>
  );
}

