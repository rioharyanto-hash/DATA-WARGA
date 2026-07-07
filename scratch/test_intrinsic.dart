import 'package:pdf/widgets.dart' as pw;

void main() {
  print(pw.Row().runtimeType);
  try {
    // There is no pw.IntrinsicHeight probably. Let's see if pw.Table works.
  } catch (e) {
    print(e);
  }
}
