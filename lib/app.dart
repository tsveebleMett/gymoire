import 'package:material_ui/material_ui.dart';

import 'data/training_repository.dart';
import 'ui/calendar_screen.dart';
import 'ui/theme.dart';
import 'ui/today_screen.dart';
import 'ui/weight_screen.dart';

class HamstrongApp extends StatelessWidget {
  const HamstrongApp({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Hamstrong',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        themeMode: ThemeMode.light,
        locale: const Locale('de'),
        supportedLocales: const [Locale('de'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: HomeShell(repository: repository),
      );
}

/// Three tabs: today's workout, the calendar and body weight.
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
        body: SafeArea(
          child: ListenableBuilder(
            listenable: widget.repository,
            builder: (context, _) => switch (_tab) {
              0 => TodayScreen(repository: widget.repository),
              1 => CalendarScreen(repository: widget.repository),
              _ => WeightScreen(repository: widget.repository),
            },
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.fitness_center_rounded), label: 'Heute'),
            NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: 'Kalender'),
            NavigationDestination(icon: Icon(Icons.monitor_weight_outlined), label: 'Gewicht'),
          ],
        ),
      );
}
