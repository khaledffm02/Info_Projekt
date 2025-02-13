import 'package:flutter/material.dart';
import 'package:frontend/models/CurrencyStateModel.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:watch_it/watch_it.dart';

class RatesService {
  static Future <void> UpdateRates() async {
    var rates = await ApiService.getRates();

    if (rates != null) {
      for (var rate in rates.entries) {
        if (rate.key != "timestamp") {
          var currencyInState = di<CurrencyStateModel>()
              .currencies
              .firstWhere((x) => x.name == rate.key);
          currencyInState.rate = double.parse(rate.value.toString());
        }
      }
    }
  }
}
