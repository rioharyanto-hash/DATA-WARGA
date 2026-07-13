import 'dart:io';

void main() {
  final file = File('e:/Project/DAWIS/lib/core/database/local_db_helper.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    '      } catch (_) {}\\n    }\\n  }\\n\\n  static Future<void> _createDB',
    '      } catch (_) {}\\n    }\\n  }\\n}\\n\\n  static Future<void> _createDB'
  );
  file.writeAsStringSync(content);
}
