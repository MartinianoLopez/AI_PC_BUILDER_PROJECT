
import 'package:go_router/go_router.dart';
import 'package:ai_pc_builder_project/presentation/screens/home/HomeScreen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
