import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class MyStream {
  DateTime scheduleTime = DateTime.now();
  StreamController dateTimeController = new StreamController<DateTime>.broadcast();
  Stream get dateStream  => dateTimeController.stream.transform(dateTranformer);

  var dateTranformer = StreamTransformer<DateTime, DateTime>.fromHandlers(handleData: (data, sink) {

    sink.add(data);
  });

  void setNewData(BuildContext context){
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onChanged: (date) => scheduleTime = date,
      onConfirm: (date) {
        dateTimeController.sink.add(date);
        scheduleTime = date;
      },

    );

  }


  void dispose() {
    dateTimeController.close();
  }
}