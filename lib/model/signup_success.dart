import 'user.dart';

class SignUpSuccessResponse {
  String? status;
  String? message;
  User? data;

  SignUpSuccessResponse({this.status, this.message, this.data});

  SignUpSuccessResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new User.fromJson(json['data']) : null;
  }

  Map<String?, dynamic> toJson() {
    final Map<String?, dynamic> data = new Map<String?, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

