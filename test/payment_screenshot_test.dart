import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/domain/Model/expense/expense_v1.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/expense_controller.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/expense_ledger.dart';

final class ScreenshotFile extends PlatformFile {
  @override
  final String name;
  final int size;
  ScreenshotFile(this.name, {this.size = 8});
  @override
  Uri get uri => Uri.parse('memory:///$name');
  @override
  XFile get xFile => XFile.fromData(Uint8List(size), name: name);
  @override
  int lengthSync() => size;
  @override
  Future<int?> length() async => size;
  @override
  Future<Uint8List> readAsBytes() async => Uint8List(size);
  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(Uint8List(size));
}

final class UnknownSizeScreenshot extends ScreenshotFile {
  UnknownSizeScreenshot() : super('provider-image.png');
  int reads = 0;
  @override
  Future<int?> length() async => null;
  @override
  Future<Uint8List> readAsBytes() async {
    reads++;
    if (reads > 1) throw StateError('Provider grant expired');
    return Uint8List(8);
  }
}

class ScreenshotPicker extends FilePickerPlatform {
  PlatformFile? file = ScreenshotFile('payment.png');
  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    expect(allowedExtensions, isNot(contains('pdf')));
    expect(compressionQuality, 0);
    return file;
  }
}

class CashController extends ExpenseController {
  int uploads = 0, ledgerLoads = 0;
  ExpenseApiException? failure;
  Completer<Map<String, dynamic>>? pending;
  @override
  Future<void> loadLedger({
    int nextPage = 1,
    String from = '',
    String to = '',
    String type = '',
  }) async {
    ledgerLoads++;
    ledger = {
      'account': {'balance': uploads > 0 && failure == null ? 500000 : 0},
    };
  }

  @override
  Future<Map<String, dynamic>> uploadPaymentScreenshot(
    dio.MultipartFile file,
  ) async {
    uploads++;
    if (failure != null) throw failure!;
    return pending?.future ??
        Future.value({
          'amount': 5000,
          'ref_no': 'REF-123',
          'paid_from': {'name': 'Maa Traders'},
          'message': 'Bank transfer credited by server',
        });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ScreenshotPicker picker;
  late FilePickerPlatform originalPicker;
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('t2p_payment_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => dir.path,
        );
    await GetStorage.init();
  });
  setUp(() {
    Get.testMode = true;
    originalPicker = FilePickerPlatform.instance;
    picker = ScreenshotPicker();
    FilePickerPlatform.instance = picker;
  });
  tearDown(() {
    FilePickerPlatform.instance = originalPicker;
    Get.reset();
  });

  Future<void> openUpload(WidgetTester tester, CashController c) async {
    Get.put<ExpenseController>(c);
    await tester.pumpWidget(const GetMaterialApp(home: ExpenseLedgerScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload payment screenshot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose image'));
    await tester.pumpAndSettle();
  }

  testWidgets('provider image with unknown size stays readable for retries', (
    tester,
  ) async {
    final file = UnknownSizeScreenshot();
    picker.file = file;
    final c = CashController()
      ..failure = ExpenseApiException(503, 'Reading service busy');
    await openUpload(tester, c);
    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();
    expect(find.text('Reading service busy'), findsOneWidget);
    c.failure = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Amount: \u20b95000.00'), findsOneWidget);
    expect(c.uploads, 2);
    expect(file.reads, 1);
  });

  testWidgets(
    'cancelled picker keeps the refusal for the selected screenshot',
    (tester) async {
      final c = CashController()
        ..failure = ExpenseApiException(422, 'Sender is not the company');
      await openUpload(tester, c);
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      picker.file = null;
      await tester.tap(find.text('Choose image'));
      await tester.pumpAndSettle();
      expect(find.text('Sender is not the company'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Upload'))
            .onPressed,
        isNull,
      );
      expect(c.uploads, 1);
    },
  );

  testWidgets(
    'slow upload stays busy, shows rupee amount and refreshes server balance',
    (tester) async {
      final c = CashController()..pending = Completer<Map<String, dynamic>>();
      await openUpload(tester, c);
      await tester.tap(find.text('Upload'));
      await tester.pump();
      expect(find.textContaining('up to 3 minutes'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Upload'))
            .onPressed,
        isNull,
      );
      c.pending!.complete({
        'amount': 5000,
        'ref_no': 'REF-123',
        'paid_from': {'name': 'Maa Traders'},
      });
      await tester.pumpAndSettle();
      expect(find.text('Amount: \u20b95000.00'), findsOneWidget);
      expect(find.text('Reference: REF-123'), findsOneWidget);
      expect(find.text('From: Maa Traders'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(c.uploads, 1);
      expect(c.ledgerLoads, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'success uses server text and a generic 500 server message is never hidden',
    (tester) async {
      final c = CashController()
        ..failure = ExpenseApiException(500, 'Something went wrong');
      await openUpload(tester, c);
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong'), findsOneWidget);
      c.failure = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Bank transfer credited by server'), findsOneWidget);
    },
  );
  testWidgets(
    'duplicate shows server message and refreshes cash without another upload',
    (tester) async {
      final c = CashController()
        ..failure = ExpenseApiException(409, 'Reference already saved');
      await openUpload(tester, c);
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      expect(find.text('Reference already saved'), findsOneWidget);
      await tester.tap(find.text('Refresh balance'));
      await tester.pumpAndSettle();
      expect(c.uploads, 1);
      expect(c.ledgerLoads, 2);
    },
  );

  testWidgets(
    'refused screenshot is not retried; unavailable service allows manual retry',
    (tester) async {
      final c = CashController()
        ..failure = ExpenseApiException(422, 'Sender is not the company');
      await openUpload(tester, c);
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      expect(find.text('Sender is not the company'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Upload'))
            .onPressed,
        isNull,
      );
      expect(c.uploads, 1);
      await tester.tap(find.text('Choose image'));
      await tester.pumpAndSettle();
      c.failure = ExpenseApiException(503, 'Reading service busy');
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      expect(find.text('Reading service busy'), findsOneWidget);
      c.failure = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Amount: \u20b95000.00'), findsOneWidget);
      expect(c.uploads, 3);
    },
  );

  testWidgets(
    'payment cooldown disables upload and expires without resending',
    (tester) async {
      final c = CashController()
        ..paymentRetryAt = DateTime.now().add(const Duration(seconds: 60));
      await openUpload(tester, c);
      final retry = find.byType(FilledButton).last;
      expect(tester.widget<FilledButton>(retry).onPressed, isNull);
      expect(find.textContaining('Try again in'), findsOneWidget);
      expect(c.uploads, 0);
      c.paymentRetryAt = DateTime.now().subtract(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(retry).onPressed, isNotNull);
      expect(c.uploads, 0);
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      expect(c.uploads, 1);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final file in [
    ScreenshotFile('payment.pdf'),
    ScreenshotFile('large.png', size: 10 * 1024 * 1024 + 1),
  ]) {
    testWidgets('invalid image ${file.name} is blocked before upload', (
      tester,
    ) async {
      picker.file = file;
      final c = CashController();
      await openUpload(tester, c);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Upload'))
            .onPressed,
        isNull,
      );
      expect(c.uploads, 0);
    });
  }

  test(
    'payment request uses bearer auth, one file and a three minute timeout',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'logistics_access_token': 'payment-test-token',
      });
      final client = dio.Dio();
      client.interceptors.add(
        dio.InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, endsWith('/v1/ocr/payment-bill'));
            expect(options.method, 'POST');
            expect(
              options.headers['Authorization'],
              'Bearer payment-test-token',
            );
            expect(options.sendTimeout, const Duration(minutes: 3));
            expect(options.receiveTimeout, const Duration(minutes: 3));
            final body = options.data as dio.FormData;
            expect(body.fields, isEmpty);
            expect(body.files.single.key, 'file');
            expect(body.files.single.value.contentType.toString(), 'image/png');
            handler.resolve(
              dio.Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'status': 'success',
                  'data': {'amount': 5000, 'balance_after': 500000},
                },
              ),
            );
          },
        ),
      );
      final c = ExpenseController(apiService: ApiService(expenseDio: client));
      final result = await c.uploadPaymentScreenshot(
        dio.MultipartFile.fromBytes(
          [1, 2, 3],
          filename: 'payment.png',
          contentType: dio.DioMediaType('image', 'png'),
        ),
      );
      expect(result['amount'], 5000);
      expect(result['balance_after'], 500000);
    },
  );
  for (final encoded in [false, true]) {
    test(
      'payment API preserves a server 500 message with ${encoded ? 'text JSON' : 'JSON'} response',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          'logistics_access_token': 'payment-test-token',
        });
        final client = dio.Dio();
        client.interceptors.add(
          dio.InterceptorsWrapper(
            onRequest: (options, handler) {
              final body = {
                'status': 'error',
                'message': 'Something went wrong',
              };
              handler.reject(
                dio.DioException(
                  requestOptions: options,
                  type: dio.DioExceptionType.badResponse,
                  response: dio.Response(
                    requestOptions: options,
                    statusCode: 500,
                    data: encoded ? jsonEncode(body) : body,
                  ),
                ),
              );
            },
          ),
        );
        final c = ExpenseController(apiService: ApiService(expenseDio: client));
        await expectLater(
          c.uploadPaymentScreenshot(
            dio.MultipartFile.fromBytes(
              [1],
              filename: 'bank.png',
              contentType: dio.DioMediaType('image', 'png'),
            ),
          ),
          throwsA(
            isA<ExpenseApiException>().having(
              (e) => e.message,
              'message',
              'Something went wrong',
            ),
          ),
        );
      },
    );
  }
}
