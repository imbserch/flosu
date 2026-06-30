import os
import re

lib_dir = r"c:\Users\Sergio Santana Noh B\Documents\flosu\lib"

class_pattern = re.compile(r'\b(?:abstract\s+|sealed\s+|mixin\s+)?class\s+(\w+)(?:\s+extends\s+([\w<>, ]+))?(?:\s+with\s+[\w<>, ]+)?(?:\s+implements\s+[\w<>, ]+)?')

widget_classes = {
    'StatelessWidget', 'StatefulWidget', 'ConsumerWidget', 'ConsumerStatefulWidget',
    'State', 'ConsumerState', 'CustomPainter', 'InheritedWidget', 'AnimatablePage',
    'AnimatablePageState', 'CustomClipper', 'SingleChildRenderObjectWidget', 'RenderObjectWidget'
}

results = []

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
            except Exception:
                continue
            
            # Remove comments to avoid false positives
            content = re.sub(r'//.*', '', content)
            content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
            
            for match in class_pattern.finditer(content):
                class_name = match.group(1)
                extends_clause = match.group(2) or ''
                
                # Extract first word of extends clause if generic, e.g. "Parser<T>" -> "Parser"
                extends_name = re.match(r'^(\w+)', extends_clause.strip())
                extends_name = extends_name.group(1) if extends_name else None
                
                # Skip private classes ending in State or extending something with State
                if class_name.startswith('_') and (class_name.endswith('State') or (extends_name and 'State' in extends_name)):
                    continue
                
                # Skip standard widget base classes
                if extends_name in widget_classes:
                    continue
                    
                if class_name.endswith('State') or (extends_name and 'State' in extends_name):
                    continue
                    
                results.append((class_name, extends_clause, filepath))

results.sort(key=lambda x: (os.path.dirname(x[2]), x[0]))

for class_name, extends_clause, filepath in results:
    rel_path = os.path.relpath(filepath, lib_dir)
    extends_str = f" extends {extends_clause}" if extends_clause else ""
    print(f"Class: {class_name}{extends_str} | Path: lib/{rel_path.replace(os.sep, '/')}")
