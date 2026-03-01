import os
import re

def normalize_tags(file_path):
    """
    Normalizes tag format in Gleam files.
    - lowercase
    - space separated (no commas)
    - hyphenated internal words
    - trimmed
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return False
    
    changed = False
    new_lines = []
    for line in lines:
        if line.startswith('/// Tags:'):
            prefix = '/// Tags: '
            # Extract the tags part, removing the prefix and leading/trailing whitespace
            tags_part = line[len('/// Tags:'):].strip()
            
            # Lowercase
            normalized = tags_part.lower()
            # Replace commas with spaces
            normalized = normalized.replace(',', ' ')
            # Replace underscores with hyphens
            normalized = normalized.replace('_', '-')
            
            # Collapse spaces and split into individual tags
            tags = [t.strip() for t in normalized.split() if t.strip()]
            final_tags = ' '.join(tags)
            
            # Construct the new line. If there are no tags, we just keep the prefix (trimmed if empty)
            if final_tags:
                new_line = prefix + final_tags + '\n'
            else:
                new_line = '/// Tags:\n'
            
            if new_line != line:
                new_lines.append(new_line)
                changed = True
            else:
                new_lines.append(line)
        else:
            new_lines.append(line)
            
    if changed:
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            return True
        except Exception as e:
            print(f"Error writing {file_path}: {e}")
            return False
    return False

def main():
    # Find active directory (project root)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    
    src_dir = os.path.join(project_root, 'src')
    
    if not os.path.exists(src_dir):
        print(f"Source directory not found: {src_dir}")
        return

    count = 0
    for root, _, files in os.walk(src_dir):
        for file in files:
            if file.endswith('.gleam'):
                path = os.path.join(root, file)
                if normalize_tags(path):
                    print(f"Normalized: {path}")
                    count += 1
    
    if count == 0:
        print("All tags were already normalized.")
    else:
        print(f"Normalization complete. Updated {count} file(s).")

if __name__ == "__main__":
    main()
