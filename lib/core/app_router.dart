import 'package:ai_pc_builder_project/presentation/screens/testing/test.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_pc_builder_project/presentation/screens/start/start.dart';
import 'package:ai_pc_builder_project/presentation/screens/registration/registration.dart';
import 'package:ai_pc_builder_project/presentation/screens/login/login.dart';
import 'package:ai_pc_builder_project/presentation/screens/home/home_screen.dart';
import 'package:ai_pc_builder_project/presentation/screens/components/components_links.dart';
import 'package:ai_pc_builder_project/presentation/screens/components/components.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const StartScreen()),

    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationScreen(),
    ),

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    GoRoute(
      path: '/ComponentsLinks',
      builder: (context, state) => const ComponentsLinks(),
    ),

    GoRoute(
      path: '/components',
      builder: (context, state) {
        final budget = state.extra as int?;
        return Components(initialBudget: budget ?? 0);
      },
    ),

    GoRoute(
      path: '/testing',
      builder: (context, state) => const TestingSCreen(),
    ),
  ],
);
