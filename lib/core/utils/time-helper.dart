class TimeHelper {
  static String getTimeOfTheDay() {
    DateTime time = DateTime.now();
    if (time.hour >= 5 && time.hour < 12) return "Morning,";
    if (time.hour >= 12 && time.hour < 18) return "Afternoon,";
    if (time.hour >= 18 && time.hour < 00) return "Evening,";
    if (time.hour >= 00 && time.hour < 5) return "Day,";
    return "Day,";
  }
}

class TimeHelper2 {
  static String getTimeOfTheDay2() {
    DateTime time = DateTime.now();

    if (time.hour >= 18 && time.hour < 23) return "Night time";
    if (time.hour >= 6 && time.hour < 12) return "Morning";
    if (time.hour >= 12 && time.hour < 18) return "Afternoon";
    return "Early Morning";
  }
}
