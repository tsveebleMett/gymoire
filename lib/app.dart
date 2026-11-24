import 'package:material_ui/material_ui.dart';

import 'data/training_repository.dart';
import 'ui/calendar_screen.dart';
import 'ui/statistics_screen.dart';
import 'ui/theme.dart';
import 'ui/today_screen.dart';
import 'ui/weight_screen.dart';

class GymoireApp extends StatelessWidget {
  const GymoireApp({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Gymoire',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(brightness: Brightness.light),
        darkTheme: buildTheme(brightness: Brightness.dark),
        // Follows the system's dark mode setting.
        themeMode: ThemeMode.system,
        locale: const Locale('de'),
        supportedLocales: const [Locale('de'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: HomeShell(repository: repository),
      );
}

/// Four tabs: today's workout, the calendar, statistics and body weight.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: BookPage(child: SafeArea(
          child: ListenableBuilder(
            listenable: widget.repository,
            builder: (context, _) => switch (_tab) {
              0 => TodayScreen(repository: widget.repository),
              1 => CalendarScreen(repository: widget.repository),
              2 => StatisticsScreen(repository: widget.repository),
              _ => WeightScreen(repository: widget.repository),
            },
          ),
        )),
        // The page edge: an ink rule above the tabs.
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: context.palette.border))),
          child: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.fitness_center_rounded), label: 'Heute'),
              NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: 'Kalender'),
              NavigationDestination(icon: Icon(Icons.insights_rounded), label: 'Statistik'),
              NavigationDestination(icon: Icon(Icons.monitor_weight_outlined), label: 'Gewicht'),
            ],
          ),
        ),
      );
}
