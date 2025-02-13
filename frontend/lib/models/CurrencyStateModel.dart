import 'package:flutter/material.dart';

import 'Currency.dart';

class CurrencyStateModel extends ChangeNotifier {
  List<Currency> _currencies = [
    new Currency("CHF", 1, 0),
    new Currency("CNY", 2, 0),
    new Currency("EUR", 3, 0),
    new Currency("GBP", 4, 0),
    new Currency("JPY", 5, 0),
    new Currency("USD", 6, 0),
  ];
  String _userCurrency = "EUR";

  String get userCurrency => _userCurrency;

  set userCurrency(String value) {
    _userCurrency = value;
  }

  List<Currency> get currencies => _currencies;

  set currencies(List<Currency> value) {
    _currencies = value;
  }

  double getRateOfCurrency(String currencyName) {
    return _currencies.firstWhere((x) => x.name == currencyName).rate;
  }
}
