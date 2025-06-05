import 'package:ai_pc_builder_project/presentation/screens/search_component/search_component.dart';
import 'package:ai_pc_builder_project/presentation/screens/testing/ai_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_pc_builder_project/presentation/screens/start/start.dart';
import 'package:ai_pc_builder_project/presentation/screens/registration/registration.dart';
import 'package:ai_pc_builder_project/presentation/screens/login/login.dart';
import 'package:ai_pc_builder_project/presentation/screens/home/home_screen.dart';
import 'package:ai_pc_builder_project/presentation/screens/links/components_links_view.dart';
import 'package:ai_pc_builder_project/presentation/screens/builder/builder_view.dart';

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
      path: '/links',
      builder: (context, state) => const ComponentsLinks(),
    ),

    GoRoute(
      path: '/components',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;

        return ComponenetsView(
          initialBudget: args?['budget'] ?? 0,
          selectedOption: args?['selectedOption'],
          idArmado: args?['editId'],
          nombreArmado: args?['name'],
          seleccionados: args?['seleccionados'],
          esAmd: args?['esAmd'] ?? true,
        );
      },
    ),
    GoRoute(
      path: '/search-component/:category',
      name: 'search-component',
      builder: (context, state) {
        final categoryStr = state.pathParameters['category'];
        final category = categoryStr ?? 'null';
        return SearchComponentScreen(category: category);
      },
    ),

    GoRoute(
      path: '/testing',
      builder: (context, state) => const TestingSCreen(),
    ),
  ],
);
