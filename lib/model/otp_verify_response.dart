class OtpVerifiedResponse {
  String? status;
  String? message;
  Data? data;

  OtpVerifiedResponse({this.status, this.message, this.data});

  OtpVerifiedResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? accountStatus;
  String? sessionId='';

  Data({this.accountStatus, this.sessionId});

  Data.fromJson(Map<String, dynamic> json) {
    accountStatus = json['account_status'];
    if(json['session_id']!=null)
    sessionId = json['session_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_status'] = this.accountStatus;
    data['session_id'] = this.sessionId;
    return data;
  }
}
