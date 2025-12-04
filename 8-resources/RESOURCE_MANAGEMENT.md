# Resource Management System

This directory contains tools and data for managing educational resources organized by **Tracks → Courses → Resources**.

## Structure

```
8-resources/
├── parse_resources.py          # Parser for full workspace resources.ini
├── merge_resources.py          # Merge script to integrate into study app
├── organized_resources.json    # Generated organized resources (JSON)
└── RESOURCE_MANAGEMENT.md      # This file
```

## Workflow

### 1. Parse Resources

Parse the full workspace resources file to extract and organize resources:

```bash
python 8-resources/parse_resources.py
```

This creates `organized_resources.json` with:
- **Tracks**: Top-level categories (Software Engineering, Computer Science, etc.)
- **Courses**: Subject-specific courses within tracks
- **Resources**: Individual links/resources organized by course

### 2. Merge into Study App

Merge the organized resources into the study app's SEED data:

```bash
python 8-resources/merge_resources.py
```

This script:
- Preserves existing resources and data
- Avoids duplicates (by URL)
- Maps courses correctly
- Updates the study app's `index.html`

## Resource Organization

Resources are organized hierarchically:

```
Track (e.g., "Mathematics")
  └── Course (e.g., "Linear Algebra")
      ├── Resource 1
      ├── Resource 2
      └── Resource 3
  └── Course (e.g., "Differential Equations")
      └── Resource 1
```

## Renaming Resources

### In the Study App

1. **Rename Tracks**:
   - Go to Resources page
   - Click the edit icon (✏️) next to any track name
   - Or use the sidebar "+" button to add/edit tracks

2. **Rename Courses**:
   - Go to Resources page
   - Click the edit icon (✏️) next to any course name
   - Or go to Courses database and click edit

3. **Rename Resources**:
   - Go to Resources page
   - Click the edit icon (✏️) next to any resource
   - Update title, URL, track, or course assignment

### Features

- **Hierarchical View**: Resources organized by Track → Course
- **Search**: Filter resources across all levels
- **Inline Editing**: Click edit icons to rename directly
- **Bulk Management**: View all resources in one organized interface

## Track Mappings

The parser automatically categorizes resources into tracks based on keywords:

- **Software Engineering** (`se`): React, Next.js, Node.js, Django, Python, TypeScript
- **Computer Science** (`cs`): Algorithms, Data Structures, OS, Architecture
- **Neural Engineering** (`neuro`): Neuroscience, Neural Engineering, BCI, Brain
- **Mathematics** (`math`): Linear Algebra, Calculus, Differential Equations, Probability
- **Chemistry** (`chem`): Organic, Biochemistry, Physical Chemistry, Thermodynamics
- **Electrical Engineering** (`ee`): Circuits, Signals, Embedded Systems, Power
- **Misc** (`misc`): Everything else

## Course Detection

Courses are identified by keywords in resource titles/URLs:

- Linear Algebra: "linear algebra", "matrix", "eigenvalue", "svd"
- Differential Equations: "differential equation", "ode", "pde"
- Organic Chemistry: "organic chemistry", "orgo", "reaction mechanism"
- And many more...

## File Locations

- **Source**: `c:\Users\JTerr\Downloads\full workspace resources.ini`
- **Output**: `8-resources/organized_resources.json`
- **Study App**: `5-engineering-projects/Jonny_Study_App/index.html`

## Notes

- The merge script preserves all existing data
- Duplicates are detected by URL
- Course IDs are automatically mapped during merge
- Resource IDs are auto-incremented to avoid conflicts

