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
    "General/Uncategorized Resources": "misc",
    "ELECTRICAL ENGINEERING / SIGNALS / BME TRACK": "ee",
    "SOFTWARE ENGINEERING + FULL-STACK TRACK": "se"
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
projects = []
current_track = None
current_course = None
current_course_id = 0
resource_id_counter = 1000 
project_id_counter = 1

# -------------------------------------------------------
# PART 1: Parse Resources (organized_resources_by_track.md)
# -------------------------------------------------------
file_path_res = 'organized_resources_by_track.md'

try:
    with open(file_path_res, 'r', encoding='utf-8') as f:
        lines = f.readlines()
except FileNotFoundError:
    # Fallback or error
    lines = []

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
        track_name_clean = re.sub(r'[^\w\s/]', '', track_name).strip()
        
        found = False
        if track_name in track_map:
            current_track = track_map[track_name]
            found = True
        elif track_name_clean in track_map:
            current_track = track_map[track_name_clean]
            found = True
        else:
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
    if line.startswith('|') and current_track and current_course:
        parts = [p.strip() for p in line.split('|')]
        if len(parts) < 4: continue
        if '---' in parts[1]: continue
        if parts[1].lower() == 'course' or parts[1].lower() == 'area': continue
        
        col_name = parts[1]
        col_desc = parts[2]
        col_links = parts[3]
        
        urls = re.findall(r'https?://[^ \n\]\)]+', col_links)
        seen_urls = set()
        clean_urls = []
        for u in urls:
            if u not in seen_urls:
                clean_urls.append(u)
                seen_urls.add(u)
            
        for i, url in enumerate(clean_urls):
            r_title = col_name
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
        
    # Legacy Resource detection
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

# -------------------------------------------------------
# PART 2: Parse Projects (organized_projects.md)
# -------------------------------------------------------
file_path_proj = 'organized_projects.md'

# Reset current track context for projects parsing
current_track = None
current_course_title = None 

try:
    with open(file_path_proj, 'r', encoding='utf-8') as f:
        lines = f.readlines()
except FileNotFoundError:
    lines = []

# Helper to find course ID by fuzzy title match
def find_course_id(title):
    # Direct match
    for c in courses:
        if c['title'] == title:
            return c['id'], c['trackId']
            
    # Partial match (projects file title inside existing course title)
    # e.g. Proj: "Organic Chemistry" -> Course: "Organic Chemistry I & II"
    for c in courses:
        if title.lower() in c['title'].lower():
            return c['id'], c['trackId']
            
    # Reverse partial
    for c in courses:
        if c['title'].lower() in title.lower():
            return c['id'], c['trackId']
            
    return None, None

for line in lines:
    line = line.strip()
    if not line: continue
    
    # Track Header in Projects file
    if line.startswith('## ') and 'TRACK' in line:
        track_name = line[3:].strip()
        # Map track name
        # Try direct or partial
        if track_name in track_map:
            current_track = track_map[track_name]
        else:
            for k, v in track_map.items():
                if k in track_name:
                    current_track = v
                    break
        continue

    # Course/Topic Header
    # Could be '## Topic' or '### Topic' depending on file structure
    # In organized_projects.md, tracks are '## ... TRACK' and topics are '## Topic' or '### Topic'
    
    is_header = False
    header_title = ""
    
    if line.startswith('## ') and 'TRACK' not in line:
        header_title = line[3:].strip()
        is_header = True
    elif line.startswith('### '):
        header_title = line[4:].strip()
        is_header = True
        
    if is_header:
        current_course_title = header_title
        # Try to find existing course ID
        cid, tid = find_course_id(header_title)
        # If found, use it. If not, and we have a current_track, maybe we default to that track?
        # Or we just use 'misc'.
        continue
        
    # Project Item: 1️⃣ Level 1: ...
    # Regex: 1️⃣? Level (\d+): (.*)
    match = re.search(r'Level (\d+): (.*)', line)
    if match and current_course_title:
        level = int(match.group(1))
        desc = match.group(2)
        
        # Determine course ID and Track ID
        cid, tid = find_course_id(current_course_title)
        
        if not tid and current_track:
            tid = current_track
            
        if not tid:
            tid = 'misc' # Fallback
            
        # If no course found, but we have a track, we might want to create a "Project Placeholder" course or null
        # For now, let's keep courseId null if not found, or maybe 0
        
        projects.append({
            "id": project_id_counter,
            "title": f"{current_course_title} - Level {level}",
            "trackId": tid,
            "courseId": cid, # can be None
            "difficulty": level,
            "status": "Not Started",
            "description": desc,
            "steps": "1. Plan\n2. Build\n3. Test", # Generic steps
            "img": "" # Placeholder
        })
        project_id_counter += 1


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
    "projects": projects
}

with open('seed_output.json', 'w', encoding='utf-8') as f:
    json.dump(seed_data, f, indent=4)
