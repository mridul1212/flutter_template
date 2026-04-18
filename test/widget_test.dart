import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_template/core/di/app_dependencies.dart';
import 'package:flutter_template/presentation/app.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App bootstraps', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'flutter_template',
      packageName: 'com.example.flutter_template',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
      installerStore: '',
    );
    final dependencies = await AppDependencies.create(
      enableConnectivityMonitoring: false,
      enableVersionGate: false,
      enableClientTelemetry: false,
    );
    await tester.pumpWidget(AppBootstrap(dependencies: dependencies));
    await tester.pump();
    expect(find.byType(AppBootstrap), findsOneWidget);
  });
}
