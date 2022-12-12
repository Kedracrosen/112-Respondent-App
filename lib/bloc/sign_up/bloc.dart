import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:agora_flutter_quickstart/model/emr_login_response.dart';
import 'package:agora_flutter_quickstart/model/generic_response.dart';
import 'package:agora_flutter_quickstart/model/otp_verify_response.dart';
import 'package:agora_flutter_quickstart/model/signup_success.dart';
import 'package:agora_flutter_quickstart/model/status_response.dart';
import 'package:agora_flutter_quickstart/model/user.dart';
import 'package:agora_flutter_quickstart/model/user_data_response.dart';
import '../../repository/user_repository.dart';
import 'event.dart';
import 'state.dart';

class SignUpBloc extends Bloc<SignUpEvent,SignUpState>{
  UserRepository? repository;
SignUpBloc({ this.repository}):super (InitialState());

@override
SignUpState get initialState => InitialState();

@override
Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
  if (event is SigningUpEvent) {
    yield PostingState();
    try{
      print('attemt to signup');
      String jsonResponse = await repository!.signUp(event.firstname,event.lastname,event.email,event.phone);
      var data = json.decode(jsonResponse);
      StatusResponse statusResponse =  StatusResponse.fromJson(data);

      if(statusResponse.status=='success'){
        SignUpSuccessResponse signUpSuccessResponse = SignUpSuccessResponse.fromJson(data);


        String jsonResponse = await repository!.fetchUserData(signUpSuccessResponse.data!.id!.toString());
        var userData = json.decode(jsonResponse);
        StatusResponse statusResponse =  StatusResponse.fromJson(userData);
        repository!.loginUser(signUpSuccessResponse.data!);
        yield PostedSuccess();

      }else
        {
          yield PostingError(error: 'could not sign up at this time');
        }
    }catch(e){
      yield PostingError(error: e.toString());
      print(e.toString());
    }
  }
  if (event is UpdateProfileEvent) {
    yield PostingState();
    try{
      print('attemt to signup');
      String jsonResponse = await repository!.updateProfile(event.dob,event.height,event.weight,event.blood,event.allergies);
      var data = json.decode(jsonResponse);
      StatusResponse statusResponse =  StatusResponse.fromJson(data);

      if(statusResponse.status=='success'){
        SignUpSuccessResponse signUpSuccessResponse = SignUpSuccessResponse.fromJson(data);
        signUpSuccessResponse.data!.image=event.image;
        repository!.loginUser(signUpSuccessResponse.data!);
        yield PostedSuccess();

      }else
      {
        yield PostingError(error: 'could not sign up at this time');
      }
    }catch(e){
      yield PostingError(error: e.toString());
      print(e.toString());
    }
  }
  if (event is SendOtpEvent) {
    yield PostingState();
    try{
      print('attemt to post');
      GenericResponse response = await repository!.sendOtp(event.phone);
      if(response.status=='success'){
        yield PostedSuccess();
      }else
      {
        yield PostingError(error: response.message!);

      }
    }catch(e){
      yield PostingError(error: e.toString());
    }
  }
  if (event is VerifyOtpEvent) {
    yield PostingState();
    try{
      print('attemt to post');

      String jsonResponse = await repository!.verifyOtp(event.otp,event.number);
      print('jsonResponse '+jsonResponse);
      var data = json.decode(jsonResponse);


      StatusResponse statusResponse =  StatusResponse.fromJson(data);

      if(statusResponse.status=='success'){
        OtpVerifiedResponse otpVerifiedResponse = OtpVerifiedResponse.fromJson(data);
       /// repository!.setUserSession(otpVerifiedResponse.status!);

        if(otpVerifiedResponse.data!.accountStatus!='unregistered'){
        repository!.setUserSession(otpVerifiedResponse.data!.sessionId!);
        yield PostedSuccess(isRegistered: true);
        }else{
         // repository!.setUserSession(otpVerifiedResponse.data!.sessionId!);
          yield PostedSuccess(isRegistered: false);

        }
      }else
      {
        GenericResponse genericResponse = GenericResponse.fromJson(data);
        yield PostingError(error: genericResponse.message!);

      }
    }catch(e){
      print('attemt to post fake success');
      yield PostingError(error: 'Invalid otp'+e.toString());
    }
  }


  if (event is FetchUserDataEvent) {
    yield PostingState();
    try{

      User currentUser = await repository!.getCurrentUser();
      if(currentUser!=null){
        yield PostedSuccess(user: currentUser);
      }
//      String jsonResponse = await repository!.fetchUserData();
//      var data = json.decode(jsonResponse);
//
//      StatusResponse statusResponse =  StatusResponse.fromJson(data);
//
//      if(statusResponse.status=='success'){
//        UserDataResponse userDataResponse = UserDataResponse.fromJson(data);
//        repository!.loginUser(userDataResponse.user!);
//        yield PostedSuccess(user:userDataResponse.user! );
//
//      }else
//      {
//        yield PostingError(error: 'could not sign up at this time');
//      }
    }catch(e){
      yield PostingError(error: e.toString());
      print(e.toString());
    }
  }
  if (event is LoginEmrEvent) {
    yield PostingState();
    try{


      String jsonResponse = await repository!.loginEmrUser(event.id, event.password);
      var data = json.decode(jsonResponse);

      StatusResponse statusResponse =  StatusResponse.fromJson(data);

      if(statusResponse.status=='success'){
        EmrLoginResponse response = EmrLoginResponse.fromJson(data);
        OneSignal.shared.setExternalUserId(response.emrUser!.appId!);



        repository!.loginUserEmr(response.emrUser!);
        yield PostedSuccess(emrUser:response.emrUser! );

      }else
      {
        yield PostingError(error: 'could not sign up at this time');
      }
    }catch(e){
      yield PostingError(error: e.toString());
      print(e.toString());
    }
  }
  if (event is CreateCallEvent) {
    yield PostingState();
    try{


      String jsonResponse = await repository!.createCall(
          event.lat, event.long,event.address,event.type,event.category,event.emrId,event.emrLat,event.emrLong,event.emrAddress
      );
      var data = json.decode(jsonResponse);

      StatusResponse statusResponse =  StatusResponse.fromJson(data);

      if(statusResponse.status=='success'){
        EmrLoginResponse response = EmrLoginResponse.fromJson(data);
        OneSignal.shared.setExternalUserId(response.emrUser!.appId!);
        repository!.loginUserEmr(response.emrUser!);
        yield PostedSuccess(emrUser:response.emrUser! );

      }else
      {
        yield PostingError(error: 'could not sign up at this time');
      }
    }catch(e){
      yield PostingError(error: e.toString());
      print(e.toString());
    }
  }



}

}