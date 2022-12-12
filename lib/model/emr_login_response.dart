class EmrLoginResponse {
  String? status;
  String? message;
  EmrUser? emrUser;

  EmrLoginResponse({this.status, this.message, this.emrUser});

  EmrLoginResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    emrUser = json['data'] != null ? new EmrUser.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.emrUser != null) {
      data['data'] = this.emrUser!.toJson();
    }
    return data;
  }
}

class EmrUser {
  String? id;
  String? firstname;
  String? lastname;
  String? email;
  String? mobile;
  String? sessionId;
  String? appId;

  EmrUser(
      {this.id,
        this.firstname,
        this.lastname,
        this.email,
        this.mobile,
        this.sessionId,
        this.appId});

  EmrUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    email = json['email'];
    mobile = json['mobile'];
    sessionId = json['session_id'];
    appId = json['app_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstname'] = this.firstname;
    data['lastname'] = this.lastname;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['session_id'] = this.sessionId;
    data['app_id'] = this.appId;
    return data;
  }
}
