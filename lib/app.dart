import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/locale/locale_cubit.dart';
import 'l10n/app_localizations.dart';
import 'core/responsive.dart';
import 'bloc/home/home_bloc.dart';
import 'bloc/home/home_event.dart';
import 'bloc/navigation/navigation_bloc.dart';
import 'bloc/navigation/navigation_event.dart';
import 'bloc/navigation/navigation_state.dart';
import 'screens/home/home_screen.dart';
import 'screens/payslip/payslip_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/document/document_screen.dart';
import 'screens/support/support_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/widgets/app_drawer.dart';

// App is StatefulWidget so _localeCubit is a stable field —
// every BlocProvider.value and BlocBuilder.bloc reference the
// exact same instance, no BlocProvider.of() tree-walk needed.
// This is the reliable pattern for locale changes on both
// Flutter web and mobile.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _localeCubit = LocaleCubit();

  @override
  void dispose() {
    _localeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _localeCubit,
      child: BlocBuilder<LocaleCubit, Locale>(
        bloc: _localeCubit,
        builder: (context, locale) => MaterialApp(
          title: 'ETAPMS',
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // Re-inject the same cubit instance below the Navigator
          // so every pushed route (Language, Profile, etc.) can
          // call context.read<LocaleCubit>() without a tree-walk.
          builder: (_, child) => BlocProvider.value(
            value: _localeCubit,
            child: child!,
          ),
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF354E48),
              brightness: Brightness.light,
            ),
            fontFamily: 'Roboto',
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

/// Public shell — used after login to host the main nav + screens.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const _screens = <Widget>[
    HomeScreen(),
    PayslipScreen(),
    HistoryScreen(),
    DocumentScreen(),
    SupportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => HomeBloc()..add(const HomeInitialized())),
        BlocProvider(create: (_) => NavigationBloc()),
      ],
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, navState) {
          return Scaffold(
            backgroundColor: Colors.white,
            drawer: const AppDrawer(),
            body: SafeArea(
              child: IndexedStack(
                index: navState.currentIndex,
                children: _screens,
              ),
            ),
            bottomNavigationBar: _BottomNavBar(
              currentIndex: navState.currentIndex,
              onTap: (i) => context
                  .read<NavigationBloc>()
                  .add(NavigationTabChanged(i)),
            ),
          );
        },
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF242F31),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withValues(alpha: 0.45),
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: context.sp(11),
      ),
      unselectedLabelStyle: TextStyle(fontSize: context.sp(11)),
      elevation: 0,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: l.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.credit_card_outlined),
          activeIcon: const Icon(Icons.credit_card),
          label: l.payslip,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.history),
          activeIcon: const Icon(Icons.history),
          label: l.history,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.description_outlined),
          activeIcon: const Icon(Icons.description),
          label: l.document,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.headset_mic_outlined),
          activeIcon: const Icon(Icons.headset_mic),
          label: l.support,
        ),
      ],
    );
  }
}
