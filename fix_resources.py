import json
import re
import os

# Paths
INDEX_PATH = '5-engineering-projects/Jonny_Study_App/index.html'
ORGANIZED_LINKS_PATH = '8-resources/organized_links.md'

def load_index_html():
    with open(INDEX_PATH, 'r', encoding='utf-8') as f:
        return f.read()

def extract_seed(html):
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

def parse_organized_links():
    resources = []
    with open(ORGANIZED_LINKS_PATH, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Strategy 1: Parse the Markdown Table "Study Links Database"
    in_table = False
    for line in lines:
        if '| **Subject/Course** |' in line:
            in_table = True
            continue
        if in_table and line.strip().startswith('|'):
            if '---' in line: continue
            parts = [p.strip() for p in line.split('|') if p.strip()]
            # Expected: Subject/Course | Institution/Instructor | Link
            if len(parts) >= 3:
                subject = parts[0].replace('**', '')
                inst = parts[1]
                link_part = parts[2]
                
                # Extract URL and Title from Link part: [Title](URL)
                match = re.search(r'\[(.*?)\]\((.*?)\)', link_part)
                if match:
                    title = match.group(1)
                    url = match.group(2)
                    resources.append({'title': title, 'url': url, 'course_hint': subject})
    
    # Strategy 2: Parse the YouTube Playlists section (Lines ~47-188)
    # Format often: URL then Title on same line or next
    # Or: Title \n URL
    # Let's look for https:// lines and check surrounding lines
    
    for i, line in enumerate(lines):
        line = line.strip()
        if line.startswith('https://'):
            url = line.split(' ')[0] # In case of "URL Title"
            
            # Potential Title candidates
            title_candidate = ""
            
            # Check if title is on the same line
            if len(line) > len(url):
                title_candidate = line[len(url):].strip()
            
            # Check previous line
            if not title_candidate and i > 0:
                prev = lines[i-1].strip()
                if prev and not prev.startswith('http'):
                    title_candidate = prev
            
            # Check next line (sometimes title is below)
            if not title_candidate and i < len(lines) - 1:
                nxt = lines[i+1].strip()
                if nxt and not nxt.startswith('http'):
                    title_candidate = nxt
            
            if title_candidate and len(title_candidate) < 100: # Sanity check
                # Clean up title
                title_candidate = title_candidate.replace('Playlist:', '').strip()
                resources.append({'title': title_candidate, 'url': url, 'course_hint': ''})

    return resources

def main():
    print("Loading files...")
    html = load_index_html()
    seed_str, start, end = extract_seed(html)
    seed = json.loads(seed_str)
    
    parsed_resources = parse_organized_links()
    print(f"Parsed {len(parsed_resources)} potential resources.")
    
    # Create a lookup map for parsed resources by URL
    url_map = {r['url']: r for r in parsed_resources}
    
    updated_count = 0
    
    # Fix existing resources in SEED
    for r in seed['resources']:
        if r['title'] == "Resource" or r['title'].strip() == "":
            # Try to find a better title
            match = url_map.get(r['url'])
            if match:
                r['title'] = match['title']
                updated_count += 1
                # Try to improve course linkage if missing
                if not r['courseId'] and match['course_hint']:
                    # Simple fuzzy match for course hint
                    for c in seed['courses']:
                        if match['course_hint'].lower() in c['title'].lower():
                            r['courseId'] = c['id']
                            r['trackId'] = c['trackId']
                            break
    
    print(f"Updated {updated_count} resources with better titles.")
    
    # Write back
    new_seed_json = json.dumps(seed, indent=4)
    prefix = html[:start+len('const SEED = ')]
    suffix = html[end:]
    new_html = prefix + new_seed_json + suffix
    
    with open(INDEX_PATH, 'w', encoding='utf-8') as f:
        f.write(new_html)
    
    print("Index.html updated.")

if __name__ == '__main__':
    main()

