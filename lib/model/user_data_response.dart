import 'package:agora_flutter_quickstart/model/user.dart';

class UserDataResponse {
  String? status;
  User? user;

  UserDataResponse({this.status, this.user});

  UserDataResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    user = json['response'] != null
        ? new User.fromJson(json['response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.user != null) {
      data['response'] = this.user!.toJson();
    }
    return data;
  }
}