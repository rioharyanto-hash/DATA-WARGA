import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # 1. Remove style: ElevatedButton.styleFrom(...) completely
    
    idx = 0
    while True:
        idx = content.find('style: ElevatedButton.styleFrom(', idx)
        if idx == -1:
            break
        
        # find matching closing parenthesis
        open_parens = 0
        end_idx = -1
        for i in range(idx + 32, len(content)):
            if content[i] == '(':
                open_parens += 1
            elif content[i] == ')':
                if open_parens == 0:
                    end_idx = i
                    break
                else:
                    open_parens -= 1
        
        if end_idx != -1:
            # Check if there is a trailing comma
            remove_end = end_idx + 1
            if remove_end < len(content) and content[remove_end] == ',':
                remove_end += 1
            
            # Remove the style block
            content = content[:idx] + content[remove_end:]
        else:
            idx += 1
            
    # Same for OutlinedButton
    idx = 0
    while True:
        idx = content.find('style: OutlinedButton.styleFrom(', idx)
        if idx == -1:
            break
        open_parens = 0
        end_idx = -1
        for i in range(idx + 32, len(content)):
            if content[i] == '(':
                open_parens += 1
            elif content[i] == ')':
                if open_parens == 0:
                    end_idx = i
                    break
                else:
                    open_parens -= 1
        
        if end_idx != -1:
            remove_end = end_idx + 1
            if remove_end < len(content) and content[remove_end] == ',':
                remove_end += 1
            content = content[:idx] + content[remove_end:]
        else:
            idx += 1

    # Same for FilledButton
    idx = 0
    while True:
        idx = content.find('style: FilledButton.styleFrom(', idx)
        if idx == -1:
            break
        open_parens = 0
        end_idx = -1
        for i in range(idx + 30, len(content)):
            if content[i] == '(':
                open_parens += 1
            elif content[i] == ')':
                if open_parens == 0:
                    end_idx = i
                    break
                else:
                    open_parens -= 1
        
        if end_idx != -1:
            remove_end = end_idx + 1
            if remove_end < len(content) and content[remove_end] == ',':
                remove_end += 1
            content = content[:idx] + content[remove_end:]
        else:
            idx += 1
            
    # Same for TextButton
    idx = 0
    while True:
        idx = content.find('style: TextButton.styleFrom(', idx)
        if idx == -1:
            break
        open_parens = 0
        end_idx = -1
        for i in range(idx + 28, len(content)):
            if content[i] == '(':
                open_parens += 1
            elif content[i] == ')':
                if open_parens == 0:
                    end_idx = i
                    break
                else:
                    open_parens -= 1
        
        if end_idx != -1:
            remove_end = end_idx + 1
            if remove_end < len(content) and content[remove_end] == ',':
                remove_end += 1
            content = content[:idx] + content[remove_end:]
        else:
            idx += 1

    # Replace hardcoded colors with primary color where appropriate
    content = content.replace('Colors.blue.shade700', 'Theme.of(context).colorScheme.primary')
    content = content.replace('Colors.blue.shade900', 'Theme.of(context).colorScheme.primary')
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
