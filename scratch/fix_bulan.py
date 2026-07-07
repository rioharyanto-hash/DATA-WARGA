import sys

path = r'lib\src\features\report\data\services\pdf_perincian_service.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

target = '    required String kota,\n  }) async {'
replacement = '''    required String kota,
    String bulanTahun = '',
  }) async {'''
content = content.replace(target, replacement)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Replaced parameter')
