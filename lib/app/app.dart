import 'package:flutter/material.dart';

import 'app_router.dart';

class EtsMovilApp extends StatelessWidget {
  const EtsMovilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETS Movil',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.home,
      routes: AppRouter.routes,
    );
  }
}
