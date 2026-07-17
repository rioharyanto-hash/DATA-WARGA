import re

with open('lib/src/features/settings/presentation/screens/form_user_screen.dart', 'r') as f:
    content = f.read()

# Pattern to replace the Nama Kelompok custom widget
pattern = re.compile(r"Column\(\s*crossAxisAlignment:\s*CrossAxisAlignment\.start,\s*children:\s*\[\s*const\s*Text\(\s*'Nama Kelompok'[\s\S]*?DropdownButtonHideUnderline\(\s*child:\s*DropdownButton<String>\(")

replacement = """InputDecorator(
  decoration: const InputDecoration(
    labelText: 'Nama Kelompok',
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    floatingLabelBehavior: FloatingLabelBehavior.always,
  ),
  child: Row(
    children: [
      const Text('BUAH GOWOK 010.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      DropdownButtonHideUnderline(
        child: DropdownButton<String>("""

content, count = pattern.subn(replacement, content)
print(f"Replaced {count} instances of Nama Kelompok header.")

pattern_end = re.compile(r"\}\),\s*onChanged:\s*\(val\)\s*=>\s*setState\(\s*\(\)\s*=>\s*_dawisNoUrut\s*=\s*val,\s*\),\s*\),\s*\),\s*],\s*\),\s*\),\s*\],\s*\),\s*const\s*SizedBox\(height:\s*16\),")

replacement_end = """}),
  onChanged: (val) => setState(() => _dawisNoUrut = val),
),
),
],
),
),
const SizedBox(height: 16),"""

content, count2 = pattern_end.subn(replacement_end, content)
print(f"Replaced {count2} instances of Nama Kelompok footer.")

with open('lib/src/features/settings/presentation/screens/form_user_screen.dart', 'w') as f:
    f.write(content)
