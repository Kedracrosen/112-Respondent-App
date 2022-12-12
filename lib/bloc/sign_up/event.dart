import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchEvent extends SignUpEvent {
  String? lid;
  FetchEvent({@required this.lid});
  @override
  List<Object> get props => [];
}

class LoginEmrEvent extends SignUpEvent {

  String? id;
  String? password;
  LoginEmrEvent({this.id, this.password});
  @override
  List<Object> get props => [];
}


//postComment evennt
class SigningUpEvent extends SignUpEvent {

  String? email;
  String? firstname,lastname;
  String? password,phone;
  SigningUpEvent({  this.firstname,  this.lastname,this.email,this.password,this.phone});
  @override
  List<Object> get props => [];
}

class UpdateProfileEvent extends SignUpEvent {
  String? weight;
  String? height,dob;
  String? blood,allergies,image;
  UpdateProfileEvent({  this.weight,  this.height,this.dob,this.blood,this.allergies,this.image});
  @override
  List<Object> get props => [];
}

class SendOtpEvent extends SignUpEvent {

   String? phone;
   SendOtpEvent({  this.phone});
  @override
  List<Object> get props => [];
}

class VerifyOtpEvent extends SignUpEvent {
  String? otp,number;
  VerifyOtpEvent({  this.otp,this.number});
  @override
  List<Object> get props => [];
}

class FetchUserDataEvent extends SignUpEvent {
  @override
  List<Object> get props => [];
}

class CreateCallEvent extends SignUpEvent {
  String? emrId,emrLat,emrLong,emrAddress;
  String? long,lat;
  String? address,type,category;
  String? agentlong,agentlat,agentaddress;
  CreateCallEvent({  this.long,  this.lat,this.address,this.category,this.type, this.emrId,this.emrLat,this.emrLong,this.emrAddress});
  @override
  List<Object> get props => [];
}