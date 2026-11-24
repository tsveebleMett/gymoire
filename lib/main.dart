import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'data/training_repository.dart';
import 'data/training_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final repository = await TrainingRepository.open(await FileTrainingStore.create());
  runApp(GymoireApp(repository: repository));
}
