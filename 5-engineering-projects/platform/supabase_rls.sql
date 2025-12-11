-- Enable Row Level Security (RLS) on tables
alter table tasks enable row level security;
alter table notes enable row level security;
alter table courses enable row level security;
alter table resources enable row level security;
alter table tracks enable row level security;

-- TASKS POLICIES
create policy "Users can create their own tasks"
on tasks for insert
with check (auth.uid() = user_id);

create policy "Users can view their own tasks"
on tasks for select
using (auth.uid() = user_id);

create policy "Users can update their own tasks"
on tasks for update
using (auth.uid() = user_id);

create policy "Users can delete their own tasks"
on tasks for delete
using (auth.uid() = user_id);

-- NOTES POLICIES
create policy "Users can create their own notes"
on notes for insert
with check (auth.uid() = user_id);

create policy "Users can view their own notes"
on notes for select
using (auth.uid() = user_id);

create policy "Users can update their own notes"
on notes for update
using (auth.uid() = user_id);

create policy "Users can delete their own notes"
on notes for delete
using (auth.uid() = user_id);

-- Repeat similar policies for other tables (courses, resources, tracks) if they have user_id

