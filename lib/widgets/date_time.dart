import 'package:flutter/material.dart';
/// Date:
String getDateHeader(DateTime? dateTime, bool isTime) {
  if (dateTime == null) return "";
  DateTime now = DateTime.now();
  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);
    return isTime? "${timeOfDay.hourOfPeriod}:${timeOfDay.minute.toString().padLeft(2, '0')} ${timeOfDay.period == DayPeriod.am ? 'AM' : 'PM'}":"Today";
  } else if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day - 1) {
    return "Yesterday";
  } else {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}
/// Time:
String formatTimestamp(DateTime dateTime) {
  TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);
  return "${timeOfDay.hourOfPeriod}:${timeOfDay.minute.toString().padLeft(2, '0')} ${timeOfDay.period == DayPeriod.am ? 'AM' : 'PM'}";
}