import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_theme.dart';
import 'config/environment.dart';
import 'config/supabase_client_provider.dart';

import 'data/category_remote_data_source.dart';
import 'data/task_remote_data_source.dart';

import 'providers/category_provider.dart';
import 'providers/nav_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/task_provider.dart';

import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔧 Inicializar entorno
  await Environment.init();

  // 🔧 Inicializar Supabase
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );

  SupabaseClientProvider.init(
    supabaseUrl: Environment.supabaseUrl,
    supabaseAnonKey: Environment.supabaseAnonKey,
  );

  // 🌍 Fechas en español
  await initializeDateFormatting('es');

  // 🔐 Sesión anónima automática (requiere Anonymous Auth activado en Supabase)
  final supabase = Supabase.instance.client;
  if (supabase.auth.currentSession == null) {
    await supabase.auth.signInAnonymously();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final taskDataSource =
    TaskRemoteDataSource(SupabaseClientProvider.instance.client);

    final categoryDataSource =
    CategoryRemoteDataSource(SupabaseClientProvider.instance.client);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskDataSource)),
        ChangeNotifierProvider(create: (_) => StatsProvider(taskDataSource)),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(categoryDataSource),
        ),
      ],
      child: MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        locale: const Locale('es'),
        home: const MainScreen(),
      ),
    );
  }
}