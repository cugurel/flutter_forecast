main(){
  DateTime now = DateTime.now();

  List<String> weekDays=['Pazartesi','Salı','Çarşamba','Perşembe','Cuma','Cumartesi','Pazar'];

  DateTime localTime=DateTime.parse('2021-10-31');

  print(weekDays[localTime.weekday-1]);
}