const fs = require('fs');

const path = 'lib/src/features/settings/presentation/screens/settings_screen.dart';
let content = fs.readFileSync(path, 'utf8');

const regex = /(\s*)String\?\s+outputFile\s*=\s*await\s+FilePicker\.saveFile\(\s*dialogTitle:\s*'([^']+)',\s*fileName:\s*'([^']+)',\s*type:\s*FileType\.custom,\s*allowedExtensions:\s*\['csv'\],\s*\);\s*if\s*\(outputFile\s*!=\s*null\)\s*\{\s*final\s+file\s*=\s*File\(outputFile\);\s*await\s+file\.writeAsString\(csvData\);\s*if\s*\(mounted\)\s*\{\s*ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(content:\s*Text\('([^']+):\s*\$outputFile'\)\),\s*\);\s*\}\s*\}/g;

content = content.replace(regex, (match, indent, title, filename, snackbarPrefix) => {
    return `${indent}final bytes = Uint8List.fromList(utf8.encode(csvData));
${indent}String? outputFile = await FilePicker.saveFile(
${indent}  dialogTitle: '${title}',
${indent}  fileName: '${filename}',
${indent}  type: FileType.custom,
${indent}  allowedExtensions: ['csv'],
${indent}  bytes: bytes,
${indent});

${indent}if (kIsWeb) {
${indent}  if (mounted) {
${indent}    ScaffoldMessenger.of(context).showSnackBar(
${indent}      const SnackBar(content: Text('File CSV berhasil diunduh.')),
${indent}    );
${indent}  }
${indent}} else {
${indent}  if (outputFile != null) {
${indent}    final file = File(outputFile);
${indent}    await file.writeAsBytes(bytes);

${indent}    if (mounted) {
${indent}      ScaffoldMessenger.of(context).showSnackBar(
${indent}        SnackBar(content: Text('${snackbarPrefix}: \\$outputFile')),
${indent}      );
${indent}    }
${indent}  }
${indent}}`;
});

fs.writeFileSync(path, content, 'utf8');
console.log("Done");
