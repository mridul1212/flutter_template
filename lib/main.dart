import 'package:flutter/material.dart';
import 'package:flutter_template/core/di/app_dependencies.dart';
import 'package:flutter_template/presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  runApp(AppBootstrap(dependencies: dependencies));
}
