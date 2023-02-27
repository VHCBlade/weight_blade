enum DayOfTheWeek {
  mon("Monday", 1),
  tue("Tuesday", 2),
  wed("Wednesday", 3),
  thu("Thursday", 4),
  fri("Friday", 5),
  sat("Saturday", 6),
  sun("Sunday", 7),
  ;

  final String displayName;
  final int count;

  const DayOfTheWeek(this.displayName, this.count);
}
