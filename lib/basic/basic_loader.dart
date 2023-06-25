import 'dart:typed_data';

class BasicLoader {
  String wrap(Uint8List bytes) {
    final sb = StringBuffer();
    sb.writeln('10 REM *** LOADER ***');
    sb.writeln('20 FOR I=0 TO ${bytes.length - 1}');
    sb.writeln('30 READ A');
    sb.writeln('40 POKE 49152+I,A');
    sb.writeln('50 NEXT I');
    sb.writeln('60 SYS 49152');
    sb.writeln('70 DATA ${bytes.map((e) => e.toString()).join(",")}');
    return sb.toString();
  }
}
