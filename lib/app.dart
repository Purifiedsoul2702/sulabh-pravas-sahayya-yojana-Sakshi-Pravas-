import 'package:flutter/material.dart';
import 'core/app_router.dart';
import 'core/app_theme.dart';

class SakhiPravasApp extends StatelessWidget {
  const SakhiPravasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'सुलभ प्रवास सहाय्य योजना',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
