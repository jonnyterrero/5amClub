import re
import json
import sys

# Track IDs mapping
track_map = {
    "SOFTWARE ENGINEERING TRACK": "se",
    "COMPUTER SCIENCE TRACK": "cs",
    "NEURAL ENGINEERING / NEUROSCIENCE TRACK": "neuro",
    "NEURAL ENGINEERING": "neuro",
    "MATHEMATICS TRACK": "math",
    "CHEMISTRY TRACK": "chem",
    "ELECTRICAL ENGINEERING / BME TRACK": "ee",
    "CROSS-TRACK / GENERAL RESOURCES": "misc",
    # Fallbacks
    "Software Engineering": "se",
    "Computer Science": "cs",
    "Neural Engineering": "neuro",
    "Mathematics": "math",
    "Chemistry": "chem",
    "Electrical Engineering": "ee",
    "General/Uncategorized Resources": "misc"
}

# Base IDs for courses
course_id_bases = {
    "se": 100,
    "cs": 200,
    "neuro": 300,
    "math": 400,
    "chem": 500,
    "ee": 600,
    "misc": 700
}

courses = []
resources = []
current_track = None
current_course = None
current_course_id = 0
resource_id_counter = 1000 

file_path = 'organized_resources_by_track.md'

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
except FileNotFoundError:
    with open('seed_output.json', 'w') as f:
        f.write(json.dumps({"error": "file not found"}))
    sys.exit(1)

course_counters = {k: v for k, v in course_id_bases.items()}

def clean_title(t):
    return t.replace("**", "").strip()

def get_res_type(url, desc=""):
    desc = desc.lower()
    if "youtube.com" in url or "youtu.be" in url or "playlist" in desc:
        return "Video"
    if "github.com" in url:
        return "Repo"
    if ".pdf" in url or "book" in desc or "textbook" in desc:
        return "Book"
    if "coursera" in url or "edx.org" in url or "udemy" in url or "course" in desc:
        return "Course"
    return "Web"

for line in lines:
    line = line.strip()
    if not line:
        continue
    
    # Track detection
    if line.startswith('## '):
        track_name = line[3:].strip()
        # Remove emojis if present
        track_name_clean = re.sub(r'[^\w\s/]', '', track_name).strip()
        
        found = False
        # Direct match
        if track_name in track_map:
            current_track = track_map[track_name]
            found = True
        elif track_name_clean in track_map:
            current_track = track_map[track_name_clean]
            found = True
        else:
             # Partial match
            for k, v in track_map.items():
                if k in track_name:
                    current_track = v
                    found = True
                    break
        
        if found:
            current_course = None
        continue
        
    # Course detection
    if line.startswith('### '):
        course_title = line[4:].strip()
        if current_track:
            course_counters[current_track] += 1
            current_course_id = course_counters[current_track]
            
            # Create course object
            courses.append({
                "id": current_course_id,
                "trackId": current_track,
                "title": course_title,
                "status": "Not Started",
                "progress": 0,
                "goals": [] 
            })
            current_course = course_title
        continue

    # Table Row Detection
    # | Name | Desc | Link |
    if line.startswith('|') and current_track and current_course:
        parts = [p.strip() for p in line.split('|')]
        # parts[0] is empty string before first |
        # parts[1] is col 1, parts[2] is col 2, parts[3] is col 3
        if len(parts) < 4: continue
        
        # Skip header separator
        if '---' in parts[1]: continue
        # Skip header row if it matches keywords
        if parts[1].lower() == 'course' or parts[1].lower() == 'area': continue
        
        col_name = parts[1]
        col_desc = parts[2]
        col_links = parts[3]
        
        # Extract links
        # Regex for [text](url) or just raw url
        # We want the URLs
        
        # Simple extraction of http links
        # Stop at space, closing paren, or closing bracket
        urls = re.findall(r'https?://[^ \n\]\)]+', col_links)
        # Dedup URLs while preserving order
        clean_urls = []
        seen_urls = set()
        for u in urls:
            if u not in seen_urls:
                clean_urls.append(u)
                seen_urls.add(u)
            
        # If multiple links, create multiple resources
        for i, url in enumerate(clean_urls):
            r_title = col_name
            if len(clean_urls) > 1:
                 # Try to differentiate if needed, or just use same title
                 # Maybe append domain?
                 pass
            
            # If title is generic "Resource", maybe use desc?
            if r_title.lower() == 'resource':
                r_title = col_desc[:30] + "..."
            
            resources.append({
                "id": resource_id_counter,
                "title": clean_title(r_title),
                "url": url,
                "type": get_res_type(url, col_desc),
                "trackId": current_track,
                "courseId": current_course_id
            })
            resource_id_counter += 1
        continue
        
    # Legacy Resource detection (fallback)
    if line.startswith('- ') and current_track and current_course:
        content = line[2:].strip()
        
        url = ""
        title = ""
        
        if content.startswith("http"):
            url = content.split(' ')[0]
            title = "Resource"
        else:
            http_idx = content.find("http")
            if http_idx != -1:
                url_part = content[http_idx:]
                url = url_part.split(' ')[0]
                if '|' in url: url = url.split('|')[0].strip()
                
                title_part = content[:http_idx].strip()
                if title_part.endswith(':'):
                    title_part = title_part[:-1].strip()
                elif title_part.endswith('-'):
                    title_part = title_part[:-1].strip()
                title = title_part
            else:
                continue 

        if not url:
            continue

        resources.append({
            "id": resource_id_counter,
            "title": clean_title(title),
            "url": url,
            "type": get_res_type(url),
            "trackId": current_track,
            "courseId": current_course_id
        })
        resource_id_counter += 1

seed_data = {
    "tracks": [
        { "id": 'se', "name": 'Software Engineering', "icon": 'laptop', "order": 0 },
        { "id": 'cs', "name": 'Computer Science', "icon": 'terminal', "order": 1 },
        { "id": 'neuro', "name": 'Neural Engineering', "icon": 'brain', "order": 2 },
        { "id": 'math', "name": 'Mathematics', "icon": 'calculator', "order": 3 },
        { "id": 'chem', "name": 'Chemistry', "icon": 'flask-conical', "order": 4 },
        { "id": 'ee', "name": 'Electrical Engineering', "icon": 'zap', "order": 5 },
        { "id": 'misc', "name": 'Misc / Extras', "icon": 'folder', "order": 6 }
    ],
    "courses": courses,
    "resources": resources,
    "projects": [
         { "id": 1, "title": "Matrix Calculator", "trackId": 'math', "courseId": 401, "difficulty": 1, "status": "Not Started", "description": "Linear Algebra CLI", "steps": "1. Input\\n2. Calc\\n3. Output", "img": "https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=400&q=80" },
         { "id": 2, "title": "React Dashboard", "trackId": 'se', "courseId": 101, "difficulty": 2, "status": "In Progress", "description": "Personal dashboard app", "steps": "1. Scaffold\\n2. Components", "img": "https://images.unsplash.com/photo-1555099962-4199c345e5dd?auto=format&fit=crop&w=400&q=80" },
         { "id": 3, "title": "EEG Analyzer", "trackId": 'neuro', "courseId": 302, "difficulty": 3, "status": "Not Started", "description": "Brain wave analysis", "steps": "1. Load Data", "img": "https://images.unsplash.com/photo-1559757175-5700dde675bc?auto=format&fit=crop&w=400&q=80" },
         { "id": 4, "title": "CLI Calculator", "trackId": 'cs', "courseId": 208, "difficulty": 1, "status": "Not Started", "description": "Python Basics", "steps": "...", "img": "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=400&q=80" },
         { "id": 5, "title": "Circuit Sim", "trackId": 'ee', "courseId": 601, "difficulty": 2, "status": "Not Started", "description": "RC/RL Circuits", "steps": "...", "img": "https://images.unsplash.com/photo-1517077304055-6e89abbec40b?auto=format&fit=crop&w=400&q=80" }
    ]
}

with open('seed_output.json', 'w', encoding='utf-8') as f:
    json.dump(seed_data, f, indent=4)
