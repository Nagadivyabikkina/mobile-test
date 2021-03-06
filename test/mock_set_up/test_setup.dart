import 'package:flutter/services.dart';
import 'package:mobile_test/src/bloc/qr_code_generator_bloc.dart';
import 'package:mobile_test/src/model/seed.dart';
import 'package:mockito/mockito.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../model/seed_mock.dart';
import 'mock_classes.dart';

QRCodeGeneratorBloc mockQRCodeGeneratorBloc(
    {bool dataLoaded = true,
    String dateTime,
    Map<String, dynamic> mockSeedData}) {
  mockSeedData ??= mockSeed;
  dateTime ??= DateTime.now().toString();
  final MockQRCodeGeneratorBloc mockQRCodeGeneratorBloc =
      MockQRCodeGeneratorBloc();
  if (dataLoaded) {
    when(mockQRCodeGeneratorBloc.getGenerateQRCode()).thenAnswer(
        (_) => Future<SeedResponse>.value(SeedResponse.fromJson(mockSeedData)));

    when(mockQRCodeGeneratorBloc.qrCodeExpiresAt$).thenAnswer((_) =>
        BehaviorSubject<String>.seeded(
                SeedResponse.fromJson(mockSeedData).expiresAt)
            .stream);

    when(mockQRCodeGeneratorBloc.qrCodeSeed$).thenAnswer((_) =>
        BehaviorSubject<QrImage>.seeded(
                QrImage(data: SeedResponse.fromJson(mockSeedData).seed))
            .stream);

    when(mockQRCodeGeneratorBloc.getCurrentDateTime)
        .thenReturn(DateTime.parse(dateTime));
  } else {
    when(mockQRCodeGeneratorBloc.getGenerateQRCode())
        .thenAnswer((_) => Future<SeedResponse>.value(null));

    when(mockQRCodeGeneratorBloc.qrCodeExpiresAt$)
        .thenAnswer((_) => BehaviorSubject<String>.seeded(null).stream);

    when(mockQRCodeGeneratorBloc.qrCodeSeed$)
        .thenAnswer((_) => BehaviorSubject<QrImage>.seeded(null));
  }

  return mockQRCodeGeneratorBloc;
}

Future<void> throwPlatformException() async =>
    throw PlatformException(code: 'a', message: 'PERMISSION_NOT_GRANTED');
void mockBarcodeScanner({
  String qrCode,
  bool exception = false,
}) {
  if (exception) {
    const MethodChannel('com.apptreesoftware.barcode_scan')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return throwPlatformException;
    });
  } else {
    const MethodChannel('com.apptreesoftware.barcode_scan')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return Future<String>.value(qrCode);
    });
  }
}
