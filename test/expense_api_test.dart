import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/domain/Model/expense/expense_v1.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/auth/auth_controller.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/expense_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';

class SessionUser extends UserController {
  bool cleared = false;
  @override
  Future<void> clearUser() async {
    cleared = true;
    await Get.find<AuthController>().clearAccessToken();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('t2p_expense_api_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => dir.path,
        );
    await GetStorage.init();
  });
  const base = String.fromEnvironment('EXPENSE_TEST_BASE_URL');
  final productionBase = URIConstants.baseURI;
  test('paise display and rupee form values keep two decimals', () {
    expect(expenseMoney(34050), '₹340.50');
    expect(expenseRupees(10477), '104.77');
    expect(expenseMoney(-72450), '₹-724.50');
    expect(expenseDay('2026-10-15T21:00:00Z'), '2026-10-16');
  });
  group(
    'Expense API over real Dio HTTP against Postman simulation',
    () {
      late ApiService api;
      late ExpenseController controller;
      late SessionUser user;
      setUp(() async {
        HttpOverrides.global = null;
        Get.testMode = true;
        FlutterSecureStorage.setMockInitialValues({
          'logistics_access_token': 'test-token',
        });
        Get.put(AuthController());
        user = SessionUser();
        Get.put<UserController>(user);
        URIConstants.baseURI = '$base/';
        api = ApiService();
        controller = ExpenseController(apiService: api);
        await Dio().post('$base/__reset');
      });
      tearDown(() async {
        URIConstants.baseURI = productionBase;
        Get.reset();
      });
      Future<ExpenseDetail> create(Map<String, dynamic> body) async {
        final response = await api.expenseRequest(
          'v1/expenses',
          method: 'POST',
          data: body,
        );
        return ExpenseDetail.fromJson(response.data['data']);
      }

      Map<String, dynamic> petrol(String id) => {
        'category': 'PETROL',
        'expense_date': '2026-10-16',
        'client_request_id': id,
        'details': {
          'rate_per_litre': '104.77',
          'litres': '3.25',
          'start_km': '15230',
        },
      };
      test('create retry returns the same record; submit/recall/cancel refresh cash', () async {
        final body = petrol('request-1');
        final draft = await create(body);
        expect(draft.expense.total, 34050);
        expect(draft.expense.details['rate_per_litre'], 10477);
        expect(draft.can('submit'), true);
        final retry = await create(body);
        expect(retry.expense.id, draft.expense.id);
        await controller.getExpenseList();
        expect(controller.expenses.length, 1);
        final submitted = await controller.action(draft, 'submit');
        expect(submitted.expense.status, 'submitted');
        expect(submitted.can('edit'), false);
        await controller.loadLedger();
        expect(expenseMap(controller.ledger['account'])['balance'], 465950);
        final recalled = await controller.action(submitted, 'recall');
        expect(recalled.can('edit'), true);
        await controller.loadLedger();
        expect(expenseMap(controller.ledger['account'])['balance'], 500000);
        final again = await controller.action(recalled, 'submit');
        final cancelled = await controller.action(
          again,
          'cancel',
          reason: 'Entered twice',
        );
        expect(cancelled.expense.status, 'cancelled');
        await controller.loadLedger();
        expect(expenseMap(controller.ledger['account'])['balance'], 500000);
        expect(expenseMaps(controller.ledger['entries']).length, 4);
      });
      test(
        'edit sends full details with version; stale version is a 409',
        () async {
          final draft = await create(petrol('request-edit'));
          final updated = await controller.save({
            'version': draft.expense.version,
            'details': {
              'rate_per_litre': '100',
              'litres': '2',
              'start_km': '15230',
            },
          }, id: draft.expense.id);
          expect(updated!.expense.total, 20000);
          await expectLater(
            api.expenseRequest(
              'v1/expenses/${draft.expense.id}',
              method: 'PATCH',
              data: {
                'version': draft.expense.version,
                'details': draft.expense.details,
              },
            ),
            throwsA(
              isA<ExpenseApiException>().having(
                (e) => e.statusCode,
                'status',
                409,
              ),
            ),
          );
        },
      );
      test(
        '422 preserves field paths and a revoked token clears login',
        () async {
          final body = petrol('bad');
          (body['details'] as Map)['litres'] = '0';
          await expectLater(
            create(body),
            throwsA(
              isA<ExpenseApiException>()
                  .having((e) => e.statusCode, 'status', 422)
                  .having(
                    (e) => e.fields['details.litres'],
                    'field',
                    'litres must be positive',
                  ),
            ),
          );
          await Get.find<AuthController>().saveAccessToken('expired-token');
          await expectLater(
            api.expenseRequest('v1/expenses/meta'),
            throwsA(
              isA<ExpenseApiException>().having(
                (e) => e.statusCode,
                'status',
                401,
              ),
            ),
          );
          expect(user.cleared, true);
          expect(await Get.find<AuthController>().readAccessToken(), '');
        },
      );
      test('food lookup combines orders; signed adjustment and GST use server totals', () async {
        final lookup = await controller.lookupData(
          'food-purchase-lines',
          query: {'orders': 'order-1,order-2'},
        );
        expect(expenseMaps(lookup['lines']).single['order_quantity'], 4);
        final saved = await create({
          'category': 'FOOD_PURCHASE',
          'client_request_id': 'food-1',
          'details': {
            'orders': ['order-1', 'order-2'],
            'items': [
              {
                'product': 'product-1',
                'rate': '250',
                'discount_type': 'amount',
                'discount_value': '20',
                'adjustments': [
                  {'quantity': '-1', 'note': 'Only 3 available'},
                ],
              },
            ],
          },
        });
        final item = expenseMaps(saved.expense.details['items']).single;
        expect(item['order_quantity'], 4);
        expect(item['quantity'], 3);
        expect(saved.expense.total, 76650); // (750 - 20) + 5% GST.
      });
      test('cancelled orders approve directly and never affect cash', () async {
        final draft = await create({
          'category': 'CANCELLED_ORDER',
          'client_request_id': 'cancelled-1',
          'details': {
            'order': 'cancelled-1',
            'items': [
              {
                'line_id': 'line-1',
                'dispositions': [
                  {
                    'type': 'consumed',
                    'quantity': '1',
                    'note': 'Office staff',
                    'date': '2026-10-16',
                  },
                ],
              },
            ],
          },
        });
        expect(draft.can('submit'), false);
        expect(draft.can('approve'), true);
        expect(draft.expense.details['total_left'], 1);
        final approved = await controller.action(draft, 'approve');
        expect(approved.expense.status, 'approved');
        expect(approved.can('edit'), false);
        await controller.loadLedger();
        expect(expenseMap(controller.ledger['account'])['balance'], 500000);
        expect(expenseMaps(controller.ledger['entries']), isEmpty);
      });
      test(
        'rate limits preserve Retry-After and prevent immediate repeat calls',
        () async {
          final dio = Dio(
            BaseOptions(headers: {'x-expense-test-response': '429'}),
          );
          final limited = ExpenseController(
            apiService: ApiService(expenseDio: dio),
          );
          await expectLater(
            limited.request('v1/expenses/meta'),
            throwsA(
              isA<ExpenseApiException>()
                  .having((e) => e.statusCode, 'status', 429)
                  .having((e) => e.retryAfter, 'retry after', 2),
            ),
          );
          expect(limited.retryAt, isNotNull);
          await expectLater(
            limited.request('v1/expenses/meta'),
            throwsA(
              isA<ExpenseApiException>().having(
                (e) => e.message,
                'message',
                contains('Please wait'),
              ),
            ),
          );
        },
      );
      test(
        'an HTML server error becomes a readable error, not a parser failure',
        () async {
          final dio = Dio(
            BaseOptions(headers: {'x-expense-test-response': '500-html'}),
          );
          await expectLater(
            ApiService(expenseDio: dio).expenseRequest('v1/expenses/meta'),
            throwsA(
              isA<ExpenseApiException>().having(
                (e) => e.statusCode,
                'status',
                500,
              ),
            ),
          );
        },
      );
      test(
        'upload sends repeated files with image MIME and multipart boundaries',
        () async {
          final draft = await create(petrol('upload-envelope'));
          final dio = Dio();
          String? serialized;
          dio.interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) async {
                if (options.data is FormData) {
                  final form = options.data as FormData;
                  expect(form.files.map((e) => e.key).toList(), [
                    'files',
                    'files',
                  ]);
                  expect(
                    form.files
                        .map((e) => e.value.contentType.toString())
                        .toList(),
                    ['image/png', 'image/png'],
                  );
                  final bytes = await form.clone().finalize().fold<List<int>>(
                    [],
                    (all, chunk) => all..addAll(chunk),
                  );
                  serialized = String.fromCharCodes(bytes);
                }
                handler.next(options);
              },
            ),
          );
          final folder = await Directory.systemTemp.createTemp(
            'expense_upload_wire_',
          );
          final image = File('${folder.path}/receipt.png');
          await image.writeAsBytes([137, 80, 78, 71, 13, 10, 26, 10]);
          try {
            final uploadClient = ExpenseController(
              apiService: ApiService(expenseDio: dio),
            );
            await uploadClient.upload(draft.expense.id, [
              await MultipartFile.fromFile(image.path, filename: 'receipt.png'),
              await MultipartFile.fromFile(
                image.path,
                filename: 'receipt-2.png',
              ),
            ]);
            expect(
              serialized,
              contains('name="files"; filename="receipt.png"'),
            );
            expect(
              serialized,
              contains('name="files"; filename="receipt-2.png"'),
            );
            expect(serialized, isNot(contains('name="files[]"')));
            expect(serialized, contains('content-type: image/png'));
          } finally {
            await image.delete();
            await folder.delete();
          }
        },
      );
      test(
        'empty results clear previous rows; server filters stay in query',
        () async {
          await create(petrol('filter-1'));
          await controller.getExpenseList();
          expect(controller.expenses.length, 1);
          controller.status = 'approved';
          await controller.getExpenseList();
          expect(controller.expenses, isEmpty);
        },
      );
    },
    skip: base.isEmpty
        ? 'Start the local Postman simulation and pass EXPENSE_TEST_BASE_URL.'
        : false,
  );
}
