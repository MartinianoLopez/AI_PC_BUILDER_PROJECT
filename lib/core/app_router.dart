import 'package:go_router/go_router.dart';
import 'package:ai_pc_builder_project/presentation/screens/home/homeScreen.dart';
import 'package:ai_pc_builder_project/presentation/screens/links/links.dart';
import 'package:ai_pc_builder_project/presentation/screens/components/components.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/links',
      builder: (context, state) => const Links(),
    ),
    GoRoute(
      path: '/components',
      builder: (context, state) => const Components(),
    ),
  ],
);
