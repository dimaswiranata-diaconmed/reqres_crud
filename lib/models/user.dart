class User {
  int? id;
  String? name;
  String? firstName;
  String? lastName;
  String? email;
  User({this.id, this.name, this.email, this.firstName, this.lastName});
}

class Device {
  List? cameras = [];
  Device({this.cameras});
}

class Schedule {
  String? day;
  List<String>? times;
  Schedule({this.day, this.times});
}
