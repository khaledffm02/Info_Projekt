import 'package:frontend/models/CurrencyStateModel.dart';
import 'package:frontend/models/LogInStateModel.dart';
import 'package:watch_it/watch_it.dart';

void initializeDependencies(){

  di.registerSingleton<LogInStateModel>(LogInStateModel());
  di.registerSingleton<CurrencyStateModel>(CurrencyStateModel());

}