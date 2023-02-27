enum DayOfTheWeek {
  sun("Sunday", 7),
  mon("Monday", 1),
  tue("Tuesday", 2),
  wed("Wednesday", 3),
  thu("Thursday", 4),
  fri("Friday", 5),
  sat("Saturday", 6),
  ;

  final String name;
  final int count;

  const DayOfTheWeek(this.name, this.count);
}
