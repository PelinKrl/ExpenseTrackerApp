//UTILS FOR THE APP

import 'package:intl/intl.dart';

  double convertStringToDouble(String string){
  double? amount = double.tryParse(string);
  return amount ?? 0;
}


  //format double amounts to tl
  String formatAmount(double amount){
    final format = NumberFormat.currency(locale: "en_US",symbol: "₺",decimalDigits: 2);
    return format.format(amount);
  }

  //calculate the number of months sinse the first month

  int calculateMonthCount(int startYear,startMonth,currentYear,currentMonth){
    int monthCount = (currentYear-startYear)*12 +currentMonth-startMonth+1;
    return monthCount;

  }

  //get current month name
  String getCurrentMonthName(){
    DateTime now = DateTime.now();
    List<String> months = [
      "JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"
    ];
    return months[now.month -1];
  }

