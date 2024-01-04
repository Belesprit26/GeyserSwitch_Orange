import 'dart:io';

String fixture(String fileName) =>
    File('test/unit-tests/fixtures/$fileName').readAsStringSync();
//test\unit-tests\fixtures\eskom.json
