import 'dart:io';

import '../main.dart';

void checkDateReturn(){

  final DateTime endDate = DateTime(2024, 10, 25);

  final DateTime currentDate = DateTime.now();

  if (currentDate.isAfter(endDate)) {
    talker.debug('Функция завершает выполнение, так как текущая дата превышает 25 октября 2024.');
    // callback();
    exit(0);
  }

}