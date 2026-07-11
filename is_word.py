import mmap
import os

def search_dictionary(word, data_type):
    file_path = fr"C:\Users\sethr\backup\Desktop\Blurbby\wn3.1.dict\dict\index.{data_type}"
    search_target = word.lower().encode('utf-8') + b' '
    
    if not os.path.exists(file_path):
        return None

    with open(file_path, "rb") as f:
        size = os.path.getsize(file_path)
        if size == 0:
            return None
            
        mm = mmap.mmap(f.fileno(), length=0, access=mmap.ACCESS_READ)
        low, high = 0, size
        
        while low < high: # binary search 
            mid = (low + high) // 2
            while mid > 0 and mm[mid - 1] != ord('\n'):
                mid -= 1
                
            mm.seek(mid)
            line = mm.readline()
            
            if line.startswith(b' '): # skip headers
                low = mid + len(line)
                continue
                
            if line.startswith(search_target):
                mm.close()
                return line.decode('utf-8').strip()
            
            current_word = line.split(b' ')[0]
            if current_word < search_target: # compare alphabetically
                low = mid + len(line)
            else:
                high = mid - 1
                
        mm.close()
    return None

def get_definition(index_line, data_type):
    """
    Takes a raw index line (e.g., 'hello n 1 1 @... 06645018')
    and pulls the actual definitions from the matching data file,
    removing any example sentences.
    """
    data_file_path = fr"C:\Users\sethr\backup\Desktop\Blurbby\wn3.1.dict\dict\data.{data_type}"
    
    if not os.path.exists(data_file_path):
        return ["Error: Companion data file missing."]

    tokens = index_line.split()
    offsets = [t for t in tokens if t.isdigit() and len(t) == 8]
    definitions = []
    
    with open(data_file_path, "rb") as f:
        for offset_str in offsets:
            offset = int(offset_str)
            
            f.seek(offset)
            raw_data_line = f.readline().decode('utf-8').strip()
            
            if '|' in raw_data_line:
                # 1. Isolate the gloss side (right side of '|')
                full_gloss = raw_data_line.split('|')[1].strip()
                
                # 2. Split at the first semicolon to separate definition from examples
                # 3. Clean up any trailing space
                definition_only = full_gloss.split(';')[0].strip()
                
                definitions.append(definition_only)
                
    return definitions

# --- Main Program Execution ---
print("\n")
word = input("Enter word: ")
found_entry = None
found_type = None

# Step 1: Scan indexes to find the word and its type
for word_type in ["adj", "adv", "noun", "verb"]:
    index_result = search_dictionary(word, word_type)
    if index_result:
        found_entry = index_result
        found_type = word_type
        break

# Step 2: Use the index line coordinates to jump straight to the definitions
if found_entry:
    
    meanings = get_definition(found_entry, found_type)
    print("\n")
    print(f"{word}: {found_type}")
    print("\n")
    for i, meaning in enumerate(meanings, 1):
        print(f"{i}. {meaning}")
    print("\n")
else:
    print("\n")
    print(f"'{word}' is not a word in WordNet.")
    print("\n")