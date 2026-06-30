import os
import re

workspace_dir = r"c:\Users\Sergio Santana Noh B\Documents\flosu"

# Extensions definitions
format_members = {
    r'\.log\(', r'\.logProperty\(', r'\.formatted', r'\.format\b'
}
models_members = {
    r'\.pressed\(', r'\.changed\(', r'\.changedAndPressed\(', 
    r'\.isCtrlPressed\b', r'\.isAltPressed\b', r'\.abs\(', r'\.asGroups\b', r'\.containsMod\('
}
ui_members = {
    r'\.theme\b', r'\.tStyle\b', r'\.scheme\b', r'\.screenSize\b', 
    r'\.scaleX\b', r'\.scaleY\b', r'\.scale\b', r'\.pixelRatio\b', 
    r'\.screenScaled\b', r'\.hiddenCursor\b'
}

def analyze_and_update(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    old_import = "import 'package:flosu/core/extensions.dart';"
    if old_import not in content:
        return
        
    # Remove comments temporarily to avoid detecting comments as usage
    temp_content = re.sub(r'//.*', '', content)
    temp_content = re.sub(r'/\*.*?\*/', '', temp_content, flags=re.DOTALL)
    
    uses_format = any(re.search(pat, temp_content) for pat in format_members)
    uses_models = any(re.search(pat, temp_content) for pat in models_members)
    uses_ui = any(re.search(pat, temp_content) for pat in ui_members)
    
    new_imports = []
    if uses_format:
        new_imports.append("import 'package:flosu/core/extensions/format.dart';")
    if uses_models:
        new_imports.append("import 'package:flosu/core/extensions/models.dart';")
    if uses_ui:
        new_imports.append("import 'package:flosu/core/extensions/ui.dart';")
        
    replacement = "\n".join(new_imports)
    
    # If no replacement matches (unused import), replacement is empty string
    # We want to replace the old import line (including the newline after it if possible, to avoid empty line)
    # Let's replace the old_import text
    new_content = content.replace(old_import, replacement)
    
    # Clean up multiple newlines if we removed import completely
    if not new_imports:
        # Just clean up potential duplicate blank lines
        new_content = re.sub(r'\n\s*\n\s*\n', '\n\n', new_content)
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
        
    print(f"Updated {os.path.relpath(filepath, workspace_dir)}: format={uses_format}, models={uses_models}, ui={uses_ui}")

# Walk the workspace
for root, dirs, files in os.walk(os.path.join(workspace_dir, "lib")):
    for file in files:
        if file.endswith('.dart'):
            analyze_and_update(os.path.join(root, file))
