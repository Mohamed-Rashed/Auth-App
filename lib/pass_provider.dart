import 'dart:typed_data';

import 'package:flutter/services.dart';

const SAMPLE_PASS_PATH = 'assets/passes/pass.pkpass';

final Future<Uint8List> Function() passProvider = () async {
  ByteData pass = await rootBundle.load(SAMPLE_PASS_PATH);
  print("kkkkkk ${pass}");
  print("kkkkkk ${pass.buffer.asUint8List()}");
  return pass.buffer.asUint8List();
};