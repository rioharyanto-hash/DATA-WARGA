import re

with open('lib/src/features/settings/presentation/screens/settings_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = re.compile(r"""(\s*)String\?\s+outputFile\s*=\s*await\s+FilePicker\.saveFile\(\s*dialogTitle:\s*('[^']+'),\s*fileName:\s*('[^']+'),\s*type:\s*FileType\.custom,\s*allowedExtensions:\s*\['csv'\],\s*\);\s*if\s*\(outputFile\s*!=\s*null\)\s*\{\s*final\s+file\s*=\s*File\(outputFile\);\s*await\s+file\.writeAsString\(csvData\);\s*if\s*\(mounted\)\s*\{\s*ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(content:\s*Text\('([^']+):\s*\$outputFile'\)\),\s*\);\s*\}\s*\}""")

def replacer(match):
    indent = match.group(1)
    title = match.group(2)
    filename = match.group(3)
    snackbar_prefix = match.group(4)
    
    return f"""{indent}final bytes = Uint8List.fromList(utf8.encode(csvData));
{indent}String? outputFile = await FilePicker.saveFile(
{indent}  dialogTitle: {title},
{indent}  fileName: {filename},
{indent}  type: FileType.custom,
{indent}  allowedExtensions: ['csv'],
{indent}  bytes: bytes,
{indent});

{indent}if (kIsWeb) {{
{indent}  if (mounted) {{
{indent}    ScaffoldMessenger.of(context).showSnackBar(
{indent}      const SnackBar(content: Text('File CSV berhasil diunduh.')),
{indent}    );
{indent}  }}
{indent}}} else {{
{indent}  if (outputFile != null) {{
{indent}    final file = File(outputFile);
{indent}    await file.writeAsBytes(bytes);

{indent}    if (mounted) {{
{indent}      ScaffoldMessenger.of(context).showSnackBar(
{indent}        SnackBar(content: Text('{snackbar_prefix}: $outputFile')),
{indent}      );
{indent}    }}
{indent}  }}
{indent}}}"""

new_content = pattern.sub(replacer, content)

if 'import \'dart:convert\';' not in new_content:
    new_content = "import 'dart:convert';\nimport 'dart:typed_data';\n" + new_content

with open('lib/src/features/settings/presentation/screens/settings_screen.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Done")
