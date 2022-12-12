
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:agora_flutter_quickstart/model/emr_login_response.dart';
import 'package:agora_flutter_quickstart/model/user.dart';


abstract class SignUpState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialState extends SignUpState {
  @override
  List<Object> get props => [];
}

class LoadingState extends SignUpState {

  @override
  List<Object> get props => [];
}

class EmptyState extends SignUpState {

  @override
  List<Object> get props => [];
}


class PostingState extends SignUpState {

  @override
  List<Object> get props => [];
}

class PostingError extends SignUpState {
  final String? error;

  PostingError({@required this.error});

  @override
  List<Object> get props => [error!];
}


class RefreshingState extends SignUpState {
  @override
  List<Object> get props => [];
}

class LoadedState extends SignUpState {
  //final List<LoanSchedule> data;
 // LoadedState({@required this.data});
  @override
  List<Object> get props => [];
}

class LoadFailureState extends SignUpState {
  final String? error;

  LoadFailureState({@required this.error});

  @override
  List<Object> get props => [error!];
}

class PostedSuccess extends SignUpState {
  bool? isRegistered;
String? message;
User? user;
EmrUser? emrUser;

PostedSuccess({@required this.message,this.user,this.emrUser,this.isRegistered});
  @override
  List<Object> get props => [];
}
