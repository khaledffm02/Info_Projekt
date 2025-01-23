import 'package:flutter/material.dart';

import 'Currency.dart';

class CurrencyStateModel extends ChangeNotifier {
  List<Currency> _currencies = [new Currency("EUR", 1, 0),
                               new Currency("USD", 2, 0),
                               new Currency("GBP", 3, 0),
                               new Currency("JPY", 4, 0),
                               new Currency("INR", 5, 0),
                              ];
  int _userCurrency=1;

  int get userCurrency => _userCurrency;

  set userCurrency(int value) {
    _userCurrency = value;
  }

  List<Currency> get currencies => _currencies;

  set currencies(List<Currency> value) {
    _currencies = value;
  }
}
