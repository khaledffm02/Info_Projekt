import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/models/CurrencyStateModel.dart';
import 'package:watch_it/watch_it.dart';

class CurrencyConvertingHelper {
String groupCurrencyName = "";

   Future<Map<String, dynamic>> convertUseridBalanceMap (Map<String, dynamic> sourceBalances, String groupId) async{


     final docSnapshot = await FirebaseFirestore.instance
         .collection('groups')
         .doc(groupId)
         .get();


     if (docSnapshot.exists) {
       Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

       if (data != null && data.containsKey('currency')) {
         groupCurrencyName = data['currency'];
         print('Currency: $groupCurrencyName'); // Gibt 'EUR' aus
       } else {
         print('Das Feld "currency" ist nicht verfügbar.');
       }
     } else {
       print("Das Dokument mit der ID $groupId wurde nicht gefunden.");
     }
     if (groupCurrencyName != di<CurrencyStateModel>().userCurrency){
    var groupRate = di<CurrencyStateModel>().getRateOfCurrency(groupCurrencyName);
     var userRate = di<CurrencyStateModel>().getRateOfCurrency(di<CurrencyStateModel>().userCurrency);


    sourceBalances.forEach((userId, balance) {
      sourceBalances[userId] = _CurrencyConversion(balance, groupRate, userRate);
    });
        }
   return sourceBalances;
 }

double convertSingleAmountToUserCurrency(double amount, String? currencyName){
     if (currencyName == null || currencyName.isEmpty) currencyName = "EUR";

     var fromRate = di<CurrencyStateModel>().getRateOfCurrency(currencyName);
     var toRate = di<CurrencyStateModel>().getRateOfCurrency(di<CurrencyStateModel>().userCurrency);
     return _CurrencyConversion(amount, fromRate, toRate);
}

  double _CurrencyConversion(balance, double groupRate, double userRate) {
return double.parse((balance * userRate / groupRate).toStringAsFixed(2));
  }
}