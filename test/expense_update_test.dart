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

import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/expense_controller.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/add_edit_expense_screen.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/components/expense_attachments.dart';

import 'payment_screenshot_test.dart' show ScreenshotFile;

class ManyFilesPicker extends FilePickerPlatform {
  final int count;
  ManyFilesPicker(this.count);
  @override
  Future<List<PlatformFile>> pickFiles({
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
  }) async => List.generate(count, (i) => ScreenshotFile('bill-$i.png'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FilePickerPlatform originalPicker;
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('t2p_update_test_');
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
    FlutterSecureStorage.setMockInitialValues({
      'logistics_access_token': 'test-token',
    });
  });
  tearDown(() {
    FilePickerPlatform.instance = originalPicker;
    Get.reset();
  });

  for (final count in [15, 25]) {
    testWidgets(
      '$count documents save draft then batches before submit; failed batch retries without reuploading saved files',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        FilePickerPlatform.instance = ManyFilesPicker(count);
        var version = 1, documentCount = 0, submits = 0, creates = 0;
        var failLastBatch = count == 25;
        var status = 'draft';
        final batches = <int>[];
        Map<String, dynamic> details = {};
        Map<String, dynamic> full() => {
          'expense': {
            '_id': 'e1',
            'category': 'PETROL',
            'status': status,
            'business_date': '2026-11-03',
            'details': details,
            'version': version,
            'amount': {'total': 10000},
            'documents': List.generate(
              documentCount,
              (i) => {'_id': 'd$i', 'name': 'bill-$i.png'},
            ),
          },
          'actions': {
            'edit': status == 'draft',
            'upload': status == 'draft',
            'submit': status == 'draft',
          },
          'history': [],
          'ledger_entries': [],
        };
        final client = dio.Dio();
        client.interceptors.add(
          dio.InterceptorsWrapper(
            onRequest: (options, handler) {
              final path = Uri.parse(options.path).path;
              dynamic data = {};
              if (path == '/v1/expenses' && options.method == 'POST') {
                creates++;
                final body = options.data as dio.FormData;
                final fields = Map.fromEntries(body.fields);
                expect(fields['submit'], 'false');
                expect(fields['client_request_id'], isNotEmpty);
                expect(body.files.map((e) => e.key).toSet(), {'files'});
                expect(body.files.length, 10);
                expect(
                  body.files.every(
                    (e) => e.value.contentType.toString() == 'image/png',
                  ),
                  isTrue,
                );
                details = Map<String, dynamic>.from(
                  jsonDecode(fields['details']!),
                );
                documentCount = 10;
                batches.add(10);
                data = full();
              } else if (path == '/v1/expenses/e1' &&
                  options.method == 'PATCH') {
                final body = options.data as Map;
                expect(body['version'], version);
                details = Map<String, dynamic>.from(body['details']);
                version++;
                data = full();
              } else if (path.endsWith('/documents')) {
                final body = options.data as dio.FormData;
                expect(body.files.length, lessThanOrEqualTo(10));
                if (failLastBatch && body.files.length == 5) {
                  failLastBatch = false;
                  handler.reject(
                    dio.DioException(
                      requestOptions: options,
                      response: dio.Response(
                        requestOptions: options,
                        statusCode: 503,
                        data: {
                          'status': 'error',
                          'message': 'Upload temporarily unavailable',
                        },
                      ),
                    ),
                  );
                  return;
                }
                batches.add(body.files.length);
                documentCount += body.files.length;
                version++;
                data = full();
              } else if (path.endsWith('/submit')) {
                expect(documentCount, count);
                expect((options.data as Map)['version'], version);
                submits++;
                status = 'submitted';
                data = full();
              } else if (path == '/v1/expenses/e1') {
                data = full();
              } else if (path == '/v1/expenses') {
                data = [];
              } else if (path == '/v1/cash-ledger/me') {
                data = {
                  'account': {'balance': 0},
                  'summary': {},
                  'entries': [],
                };
              } else {
                fail('Unexpected request ${options.method} $path');
              }
              handler.resolve(
                dio.Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'status': 'success', 'data': data},
                ),
              );
            },
          ),
        );
        final c = Get.put<ExpenseController>(
          ExpenseController(apiService: ApiService(expenseDio: client)),
        );
        c.meta = {
          'categories': [
            {'code': 'PETROL', 'label': 'Petrol Filling'},
          ],
          // A stale metadata value must not become a total-document cap.
          'upload': {'max_files': 5, 'max_mb': 10},
        };
        await tester.pumpWidget(
          const GetMaterialApp(home: AddEditExpenseScreen()),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Expense type'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Petrol Filling').last);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Rate per litre (₹)'),
          '100',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Litres'),
          '1',
        );
        tester.testTextInput.hide();
        await tester.pumpAndSettle();
        final choose = find.byKey(const ValueKey('expense-choose-files'));
        await tester.scrollUntilVisible(
          choose,
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(choose);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('expense-save-submit')));
        await tester.pumpAndSettle();
        if (count == 25) {
          expect(documentCount, 20);
          expect(submits, 0);
          expect(find.textContaining('5 files pending'), findsOneWidget);
          await tester.tap(find.byKey(const ValueKey('expense-save-submit')));
          await tester.pumpAndSettle();
        }
        expect(creates, 1);
        expect(submits, 1);
        expect(documentCount, count);
        expect(batches, count == 15 ? [10, 5] : [10, 10, 5]);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'existing attachments above metadata max still allow adding documents',
    (tester) async {
      var selected = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExpenseAttachments(
                documents: List.generate(
                  15,
                  (i) => {'_id': '$i', 'name': 'Bill $i'},
                ),
                settings: const {'max_files': 5},
                canUpload: true,
                busy: false,
                onCamera: () {},
                onFiles: () => selected = true,
                onView: (_) {},
                onRemove: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Photos / PDF'));
      expect(selected, isTrue);
      expect(find.text('15 files'), findsOneWidget);
    },
  );
}
