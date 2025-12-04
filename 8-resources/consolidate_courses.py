"""
Consolidate courses in the study app.
- Removes "extra" courses (IDs >= 1000) from all tracks EXCEPT Software Engineering.
- Relinks resources from removed courses to valid courses (IDs < 1000) in the same track if a match is found.
- If no match is found, moves resources to 'General' course in 'Misc / Extras' track.
"""
import json
import re
import os

INDEX_PATH = '5-engineering-projects/Jonny_Study_App/index.html'

# Keywords for fuzzy matching resources to valid courses
COURSE_KEYWORDS = {
    # CS
    'nand2tetris': 201,
    'algorithms': 202, 'sorting': 202, 'graphs': 202,
    'operating systems': 203, 'os': 203, 'kernel': 203,
    'compilers': 204, 'lexing': 204, 'parsing': 204,
    'digital systems': 205, 'logic gates': 205,
    'computer networks': 206, 'tcp': 206, 'http': 206,
    'computer architecture': 207, 'isa': 207, 'pipelining': 207,
    'intro to cs': 208, 'python': 208, 'recursion': 208,
    
    # Neuro
    'neuroscience': 301, 'neurons': 301,
    'sensory': 302, 'vision': 302, 'auditory': 302,
    'neural engineering': 303, 'bci': 303, 'prosthetics': 303,
    'signal acquisition': 304, 'eeg': 304,
    'data analysis': 305, 'decoding': 305, 'spike': 305,
    
    # Math
    'linear algebra': 401, 'vectors': 401, 'matrices': 401,
    'statistics': 402, 'probability': 402, 'inference': 402,
    'multivariable': 403, 'gradients': 403,
    'differential equations': 404, 'ode': 404,
    'partial differential': 405, 'pde': 405, 'heat': 405, 'wave': 405,
    'numerical': 406, 'approximation': 406,
    'foundations': 407, 'proofs': 407, 'logic': 407,
    
    # Chem
    'organic': 501, 'reaction': 501, 'synthesis': 501,
    'biochemistry': 502, 'metabolism': 502, 'enzymes': 502,
    'physical chemistry': 503, 'quantum': 503, 'thermodynamics': 503,
    'inorganic': 504, 'metals': 504, 'bonding': 504,
    
    # EE
    'circuits': 601, 'electronics': 601, 'ohm': 601,
    'signals': 602, 'systems': 602, 'fourier': 602, 'lti': 602,
    'intro to biomedical': 603, 'biomedical engineering': 603,
    'bioinstrumentation': 604, 'instrumentation': 604,
    'imaging': 605, 'design': 605,
    'signal processing': 606, 'bsp': 606
}

def extract_seed(html):
    start_marker = 'const SEED = {'
    start_idx = html.find(start_marker)
    if start_idx == -1: raise Exception("SEED not found")
    json_start = start_idx + len('const SEED = ')
    open_braces = 0
    in_string = False
    string_char = ''
    escape = False
    for i, char in enumerate(html[json_start:], start=json_start):
        if in_string:
            if escape: escape = False
            elif char == '\\': escape = True
            elif char == string_char: in_string = False
        else:
            if char == '"' or char == "'": in_string = True; string_char = char
            elif char == '{': open_braces += 1
            elif char == '}': open_braces -= 1; 
            if open_braces == 0: return html[json_start:i+1], start_idx, i+1
    raise Exception("Could not find end of SEED object")

def consolidate_courses(seed):
    courses = seed['courses']
    resources = seed['resources']
    
    # 1. Identify Keep vs Remove
    # SE track (id 'se') is EXCLUDED from removal
    
    valid_courses = {} # id -> course object
    courses_to_remove = set()
    
    print("Analyzing courses...")
    for c in courses:
        if c['trackId'] == 'se':
            # Keep all SE courses
            valid_courses[c['id']] = c
        elif c['id'] < 1000:
            # Keep original manually added courses
            valid_courses[c['id']] = c
        else:
            # Remove generated courses in other tracks
            courses_to_remove.add(c['id'])
            
    print(f"Identified {len(courses_to_remove)} courses to remove.")
    
    # 2. Ensure 'General' course exists in 'misc' track for fallback
    misc_general = next((c for c in courses if c['trackId'] == 'misc' and c['title'] == 'General' and c['id'] < 1000), None)
    if not misc_general:
        # Check if one exists in removal list that we can repurpose? 
        # Or just create a new one.
        # Let's see if there is a valid misc course.
        # Actually, let's just look for any valid misc course to be the default.
        misc_courses = [c for c in valid_courses.values() if c['trackId'] == 'misc']
        if misc_courses:
            misc_general = misc_courses[0] # Pick first available
        else:
            # Create one
            misc_general = {
                "id": 999,
                "trackId": "misc",
                "title": "General",
                "status": "Not Started",
                "progress": 0,
                "goals": []
            }
            valid_courses[999] = misc_general
            courses.append(misc_general) # Add to main list (will be filtered later)
            
    print(f"Fallback course: {misc_general['title']} (ID: {misc_general['id']})")

    # 3. Relink Resources
    remapped_count = 0
    moved_to_misc = 0
    
    for r in resources:
        c_id = r.get('courseId')
        
        # If resource is in a course to be removed
        if c_id in courses_to_remove:
            # Try to find a target in valid courses
            # Strategy: Use keywords on Resource Title or URL
            text = (r.get('title', '') + ' ' + r.get('url', '')).lower()
            
            target_id = None
            
            # Try to match keywords
            for keyword, mapped_id in COURSE_KEYWORDS.items():
                if keyword in text:
                    # Check if mapped_id is actually in our valid list
                    if mapped_id in valid_courses:
                        target_id = mapped_id
                        break
            
            if target_id:
                r['courseId'] = target_id
                r['trackId'] = valid_courses[target_id]['trackId']
                remapped_count += 1
            else:
                # Move to Misc General
                r['courseId'] = misc_general['id']
                r['trackId'] = misc_general['trackId']
                moved_to_misc += 1
    
    print(f"Remapped {remapped_count} resources to valid courses.")
    print(f"Moved {moved_to_misc} resources to Misc/General.")
    
    # 4. Filter Courses
    # Keep only valid courses
    seed['courses'] = [c for c in courses if c['id'] in valid_courses]
    
    return seed

def main():
    if not os.path.exists(INDEX_PATH):
        print("Index file not found")
        return

    with open(INDEX_PATH, 'r', encoding='utf-8') as f:
        html = f.read()

    seed_str, start, end = extract_seed(html)
    seed = json.loads(seed_str)
    
    seed = consolidate_courses(seed)
    
    new_seed_json = json.dumps(seed, indent=4)
    new_html = html[:start+len('const SEED = ')] + new_seed_json + html[end:]
    
    with open(INDEX_PATH, 'w', encoding='utf-8') as f:
        f.write(new_html)
    
    print("Consolidation complete.")

if __name__ == '__main__':
    main()

