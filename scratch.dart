import "dart:io"; void main() { print(Directory("C:\\Users\\user\\Documents").listSync().where((f) => f.path.contains("dasawisma"))); }
