"""
Merge organized resources into the study app's SEED data
Preserves existing data and adds new organized resources
"""
import json
import re
import os

INDEX_PATH = '5-engineering-projects/Jonny_Study_App/index.html'
ORGANIZED_RESOURCES = '8-resources/organized_resources.json'

def extract_seed(html):
    """Extract SEED object from HTML"""
    start_marker = 'const SEED = {'
    start_idx = html.find(start_marker)
    if start_idx == -1:
        raise Exception("SEED not found")
    
    json_start = start_idx + len('const SEED = ')
    open_braces = 0
    in_string = False
    string_char = ''
    escape = False
    
    for i, char in enumerate(html[json_start:], start=json_start):
        if in_string:
            if escape:
                escape = False
            elif char == '\\':
                escape = True
            elif char == string_char:
                in_string = False
        else:
            if char == '"' or char == "'":
                in_string = True
                string_char = char
            elif char == '{':
                open_braces += 1
            elif char == '}':
                open_braces -= 1
                if open_braces == 0:
                    return html[json_start:i+1], start_idx, i+1
    
    raise Exception("Could not find end of SEED object")

def merge_resources(existing_seed, organized_data):
    """Merge organized resources into existing SEED, avoiding duplicates"""
    
    # Create sets of existing URLs and titles for duplicate detection
    existing_urls = {r.get('url', '') for r in existing_seed.get('resources', [])}
    existing_titles = {r.get('title', '').lower() for r in existing_seed.get('resources', [])}
    
    # Track existing course IDs to avoid duplicates
    existing_course_ids = {c.get('id') for c in existing_seed.get('courses', [])}
    max_course_id = max(existing_course_ids) if existing_course_ids else 1000
    
    # Track existing resource IDs
    existing_resource_ids = {r.get('id') for r in existing_seed.get('resources', [])}
    max_resource_id = max(existing_resource_ids) if existing_resource_ids else 10000
    
    # Merge tracks (preserve existing, add new)
    existing_track_ids = {t.get('id') for t in existing_seed.get('tracks', [])}
    for track in organized_data.get('tracks', []):
        if track.get('id') not in existing_track_ids:
            existing_seed.setdefault('tracks', []).append(track)
    
    # Merge courses (avoid duplicates by title + trackId)
    existing_courses_map = {}
    for course in existing_seed.get('courses', []):
        key = (course.get('title', '').lower(), course.get('trackId', ''))
        existing_courses_map[key] = course
    
    new_course_id = max_course_id + 1
    course_id_mapping = {}  # Map from organized course ID to existing/new ID
    
    for course in organized_data.get('courses', []):
        key = (course.get('title', '').lower(), course.get('trackId', ''))
        if key not in existing_courses_map:
            # New course
            new_course = course.copy()
            old_id = new_course.get('id')
            new_course['id'] = new_course_id
            course_id_mapping[old_id] = new_course_id
            existing_seed.setdefault('courses', []).append(new_course)
            existing_courses_map[key] = new_course
            new_course_id += 1
        else:
            # Course exists, map to existing ID
            course_id_mapping[course.get('id')] = existing_courses_map[key].get('id')
    
    # Merge resources (avoid duplicates by URL)
    new_resource_id = max_resource_id + 1
    added_count = 0
    
    for resource in organized_data.get('resources', []):
        url = resource.get('url', '')
        title = resource.get('title', '').lower()
        
        # Skip if URL or title already exists
        if url in existing_urls or title in existing_titles:
            continue
        
        # Create new resource with updated IDs
        new_resource = resource.copy()
        new_resource['id'] = new_resource_id
        new_resource_id += 1
        
        # Map course ID
        old_course_id = new_resource.get('courseId')
        if old_course_id and old_course_id in course_id_mapping:
            new_resource['courseId'] = course_id_mapping[old_course_id]
        else:
            new_resource['courseId'] = None
        
        existing_seed.setdefault('resources', []).append(new_resource)
        existing_urls.add(url)
        existing_titles.add(title)
        added_count += 1
    
    return existing_seed, added_count

def main():
    print("Loading files...")
    
    # Load organized resources
    if not os.path.exists(ORGANIZED_RESOURCES):
        print(f"Error: Organized resources file not found at {ORGANIZED_RESOURCES}")
        print("Please run parse_resources.py first.")
        return
    
    with open(ORGANIZED_RESOURCES, 'r', encoding='utf-8') as f:
        organized_data = json.load(f)
    
    # Load existing HTML and extract SEED
    if not os.path.exists(INDEX_PATH):
        print(f"Error: Index file not found at {INDEX_PATH}")
        return
    
    with open(INDEX_PATH, 'r', encoding='utf-8') as f:
        html = f.read()
    
    seed_str, start, end = extract_seed(html)
    existing_seed = json.loads(seed_str)
    
    print(f"Existing: {len(existing_seed.get('tracks', []))} tracks, {len(existing_seed.get('courses', []))} courses, {len(existing_seed.get('resources', []))} resources")
    print(f"Organized: {len(organized_data.get('tracks', []))} tracks, {len(organized_data.get('courses', []))} courses, {len(organized_data.get('resources', []))} resources")
    
    # Merge
    merged_seed, added_count = merge_resources(existing_seed, organized_data)
    
    print(f"\n✓ Merged successfully!")
    print(f"  Added {added_count} new resources")
    print(f"  Final: {len(merged_seed.get('tracks', []))} tracks, {len(merged_seed.get('courses', []))} courses, {len(merged_seed.get('resources', []))} resources")
    
    # Write back to HTML
    new_seed_json = json.dumps(merged_seed, indent=4)
    prefix = html[:start+len('const SEED = ')]
    suffix = html[end:]
    new_html = prefix + new_seed_json + suffix
    
    with open(INDEX_PATH, 'w', encoding='utf-8') as f:
        f.write(new_html)
    
    print(f"\n✓ Updated {INDEX_PATH}")

if __name__ == '__main__':
    main()

