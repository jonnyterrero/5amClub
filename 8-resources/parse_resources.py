"""
Parser for full workspace resources.ini
Organizes resources by: Tracks → Courses → Resources
"""
import json
import re
import os
from collections import defaultdict
from typing import Dict, List, Any

RESOURCES_FILE = r'c:\Users\JTerr\Downloads\full workspace resources.ini'
OUTPUT_JSON = '8-resources/organized_resources.json'

# Track mappings based on content analysis
TRACK_MAPPINGS = {
    'software engineering': 'se',
    'full-stack': 'se',
    'react': 'se',
    'next.js': 'se',
    'node.js': 'se',
    'django': 'se',
    'python': 'se',
    'typescript': 'se',
    'computer science': 'cs',
    'algorithms': 'cs',
    'data structures': 'cs',
    'operating systems': 'cs',
    'computer architecture': 'cs',
    'compiler': 'cs',
    'neuroscience': 'neuro',
    'neural engineering': 'neuro',
    'neural': 'neuro',
    'brain': 'neuro',
    'biomedical': 'neuro',
    'mathematics': 'math',
    'linear algebra': 'math',
    'differential equations': 'math',
    'calculus': 'math',
    'probability': 'math',
    'statistics': 'math',
    'pde': 'math',
    'numerical': 'math',
    'chemistry': 'chem',
    'organic chemistry': 'chem',
    'biochemistry': 'chem',
    'physical chemistry': 'chem',
    'thermodynamics': 'chem',
    'electrical engineering': 'ee',
    'circuits': 'ee',
    'signals': 'ee',
    'systems': 'ee',
    'embedded': 'ee',
    'power systems': 'ee',
    'communication': 'ee',
}

# Course keyword mappings
COURSE_KEYWORDS = {
    'linear algebra': ['linear algebra', 'matrix', 'eigenvalue', 'svd', 'pca'],
    'differential equations': ['differential equation', 'ode', 'pde', 'partial differential'],
    'calculus': ['calculus', 'derivative', 'integral', 'multivariable'],
    'probability': ['probability', 'statistics', 'random process', 'bayesian'],
    'organic chemistry': ['organic chemistry', 'orgo', 'reaction mechanism', 'smiles'],
    'biochemistry': ['biochemistry', 'enzyme', 'metabolism', 'protein'],
    'physical chemistry': ['physical chemistry', 'quantum', 'thermodynamics', 'kinetics'],
    'circuits': ['circuit', 'ohm', 'resistor', 'capacitor', 'inductor'],
    'signals and systems': ['signals and systems', 'fourier', 'laplace', 'convolution', 'lti'],
    'neural engineering': ['neural engineering', 'bci', 'brain-computer', 'neural signal'],
    'neuroscience': ['neuroscience', 'neural', 'brain', 'neuron', 'synapse'],
    'algorithms': ['algorithm', 'data structure', 'sorting', 'graph', 'tree'],
    'operating systems': ['operating system', 'os', 'process', 'memory', 'scheduling'],
    'computer architecture': ['computer architecture', 'cpu', 'instruction', 'assembly'],
}

def extract_url(line: str) -> str:
    """Extract URL from a line"""
    url_pattern = r'https?://[^\s<>"{}|\\^`\[\]]+'
    match = re.search(url_pattern, line)
    return match.group(0) if match else None

def extract_title(line: str, url: str = None) -> str:
    """Extract title from a line, cleaning it up"""
    if url:
        line = line.replace(url, '').strip()
    
    # Remove bullet points and markers
    line = re.sub(r'^[●•\-\*]\s*', '', line)
    line = re.sub(r'^\d+\.\s*', '', line)
    line = line.strip()
    
    # Remove common prefixes
    prefixes = ['by ', 'from ', 'Playlist: ', 'Course: ']
    for prefix in prefixes:
        if line.lower().startswith(prefix.lower()):
            line = line[len(prefix):].strip()
    
    return line

def identify_track(text: str) -> str:
    """Identify track from text"""
    text_lower = text.lower()
    for keyword, track_id in TRACK_MAPPINGS.items():
        if keyword in text_lower:
            return track_id
    return 'misc'

def identify_course(text: str) -> str:
    """Identify course from text"""
    text_lower = text.lower()
    for course_name, keywords in COURSE_KEYWORDS.items():
        for keyword in keywords:
            if keyword in text_lower:
                return course_name
    return None

def parse_resources_file(filepath: str) -> Dict[str, Any]:
    """Parse the resources file and organize by tracks → courses → resources"""
    
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Structure: {track_id: {course_name: [resources]}}
    organized = defaultdict(lambda: defaultdict(list))
    current_track = 'misc'
    current_course = None
    resource_id_counter = 10000
    
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        
        # Skip empty lines
        if not line:
            i += 1
            continue
        
        # Check if this is a track header (no bullet, capitalized, standalone)
        if not line.startswith('●') and not line.startswith('•') and not line.startswith('http'):
            # Check if it's a major section header
            if len(line) > 5 and line[0].isupper() and 'http' not in line:
                # Check if next few lines are resources
                is_header = False
                for j in range(min(3, len(lines) - i - 1)):
                    next_line = lines[i + j + 1].strip()
                    if next_line.startswith('●') or next_line.startswith('•') or 'http' in next_line:
                        is_header = True
                        break
                
                if is_header:
                    track_id = identify_track(line)
                    current_track = track_id
                    current_course = None
                    i += 1
                    continue
        
        # Extract URL
        url = extract_url(line)
        if url:
            title = extract_title(line, url)
            
            # If title is too short or generic, try to get from context
            if len(title) < 5 or title.lower() in ['play all', 'course', 'playlist']:
                # Look at surrounding lines
                if i > 0:
                    prev_line = lines[i-1].strip()
                    if prev_line and not prev_line.startswith('http'):
                        title = extract_title(prev_line)
                
                if (len(title) < 5 or title.lower() in ['play all', 'course']) and i < len(lines) - 1:
                    next_line = lines[i+1].strip()
                    if next_line and not next_line.startswith('http'):
                        title = extract_title(next_line)
            
            # If still no good title, create one from URL
            if len(title) < 5:
                if 'youtube.com' in url or 'youtu.be' in url:
                    title = 'YouTube Video/Playlist'
                elif 'github.com' in url:
                    title = 'GitHub Repository'
                elif 'ocw.mit.edu' in url:
                    title = 'MIT OpenCourseWare'
                else:
                    # Extract domain as title
                    domain = re.search(r'https?://(?:www\.)?([^/]+)', url)
                    title = domain.group(1) if domain else 'Resource'
            
            # Identify course
            course_name = identify_course(line + ' ' + title)
            if not course_name:
                course_name = 'General'
            
            resource = {
                'id': resource_id_counter,
                'title': title,
                'url': url,
                'type': 'link'
            }
            
            organized[current_track][course_name].append(resource)
            resource_id_counter += 1
        
        i += 1
    
    # Convert to final structure
    result = {
        'tracks': [],
        'courses': [],
        'resources': []
    }
    
    track_order = ['se', 'cs', 'neuro', 'math', 'chem', 'ee', 'misc']
    track_names = {
        'se': 'Software Engineering',
        'cs': 'Computer Science',
        'neuro': 'Neural Engineering',
        'math': 'Mathematics',
        'chem': 'Chemistry',
        'ee': 'Electrical Engineering',
        'misc': 'Misc / Extras'
    }
    
    course_id_counter = 1000
    track_id_map = {}
    
    # Create tracks
    for idx, track_id in enumerate(track_order):
        if track_id in organized:
            track = {
                'id': track_id,
                'name': track_names[track_id],
                'icon': get_track_icon(track_id),
                'order': idx
            }
            result['tracks'].append(track)
            track_id_map[track_id] = track
    
    # Create courses and resources
    for track_id, courses in organized.items():
        if track_id not in track_id_map:
            continue
        
        for course_name, resources in courses.items():
            course = {
                'id': course_id_counter,
                'trackId': track_id,
                'title': course_name.title(),
                'status': 'Not Started',
                'order': course_id_counter
            }
            result['courses'].append(course)
            
            # Add resources with course linkage
            for resource in resources:
                resource['courseId'] = course_id_counter
                resource['trackId'] = track_id
                result['resources'].append(resource)
            
            course_id_counter += 1
    
    return result

def get_track_icon(track_id: str) -> str:
    """Get icon name for track"""
    icons = {
        'se': 'laptop',
        'cs': 'terminal',
        'neuro': 'brain',
        'math': 'calculator',
        'chem': 'flask-conical',
        'ee': 'zap',
        'misc': 'folder'
    }
    return icons.get(track_id, 'folder')

def main():
    print("Parsing resources file...")
    
    if not os.path.exists(RESOURCES_FILE):
        print(f"Error: Resources file not found at {RESOURCES_FILE}")
        print("Please update RESOURCES_FILE path in the script.")
        return
    
    organized = parse_resources_file(RESOURCES_FILE)
    
    # Save to JSON
    output_path = os.path.join(os.path.dirname(__file__), 'organized_resources.json')
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(organized, f, indent=2, ensure_ascii=False)
    
    print(f"\n✓ Parsed {len(organized['tracks'])} tracks")
    print(f"✓ Parsed {len(organized['courses'])} courses")
    print(f"✓ Parsed {len(organized['resources'])} resources")
    print(f"\n✓ Saved to: {output_path}")

if __name__ == '__main__':
    main()

