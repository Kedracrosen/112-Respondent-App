import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:agora_flutter_quickstart/model/emr_login_response.dart';
import 'package:agora_flutter_quickstart/model/user.dart';
import 'api_client.dart';
import 'package:agora_flutter_quickstart/utility/constants.dart' as Constants;
import '../ui/config/agora.config.dart' as config;


import '../model/generic_response.dart';

abstract class UserService {
//  Future<User> getCurrentUser();
//  Future<void> signOut();
//  Future<bool> isLoggedIn();
//  Future<User> getUserDetails(String sessionId, String sessionToken);
//  Future<void> LoginUser(User user,String sessionId, String sessionToken);
//  Future<List<NotificationModel>> listNotification();
//  Future<String> getSessionValue(String key);
//  Future<List<BasicUserDetails>> searchUsers(String searchQuery);
//  Future<List<BasicUserDetails>> follow(String userId);
//  Future<List<BasicUserDetails>> listFollowersOrFollowing(String type);
//  Future<List<BasicUserDetails>> getRetixers( String post_id);
//  Future<List<BasicUserDetails>> getPostCarders(String post_id, String type);
//  Future<GenericResponse> updatePassword (String password);
}

class UserRepository extends UserService {
  final ApiClient _apiClient = ApiClient();
  SharedPreferences? prefs ;

  Future<void> openCache() async {
    prefs = await SharedPreferences.getInstance();
  }


  @override
  Future<String> signUp(firstname,lastname,email,phone) async {
    //User user = await getCurrentUser();
    print('attempt to sign up actually');
    var body = <String, dynamic>{
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'mobile': phone,
      'password': '00000000',
      'confirm_password': '00000000',
    };

    String response =
        await _apiClient.postForm(Constants.CREATE_STUDENT_PROFILE, body);
    print("signUpResponse : " + response);
    return response;
  }

  @override
  Future<String> updateProfile(date,height,weight,blood,allergies) async {
    User user = await getCurrentUser();
    print('attempt to update actually');
    var body = <String, dynamic>{
      'id':user.id.toString(),
      'email':user.email,
      'mobile':user.mobile,
      'firstname':user.firstname,
      'lastname':user.lastname,
      'height': height,
      'weight': weight,
      'blood_type': blood,
      'allergies': allergies,
      'dob': date,
    };

    String response =
    await _apiClient.put(Constants.UPDATE_USER_PROFILE, body);
    print("updateResponse : " + response);
    return response;
  }

  @override
  Future<String> createCall(lat,long,address,type,category,emrId,emrLat,emrLong,emrAddress) async {
    User user = await getCurrentUser();
   Random random = new Random.secure();
    String channelId = config.channelId+random.nextInt(100).toString();

    var body = <String, dynamic>{
      'user_id': user.id,
      'user_lat': lat.toString(),
      'user_long': long.toString(),
      'emr_id':emrId,
      'emr_lat':emrLat,
      'emr_long':emrLong,
      'emr_address':emrAddress,
      'category': "1",
      'user_address': address,
      'type': type,
      'channel_id':channelId,
      'user_fullname':user.firstname! +" " + user.lastname!
    };

    String response =
    await _apiClient.postForm(Constants.CALL_EMR, body);
    print("calllEmrResponse : " + response);
    return response;
  }

  @override
  Future<String> loginEmrUser(id,password) async {
    //User user = await getCurrentUser();
    var body = <String, dynamic>{
      'email': id,
      'password': password,
    };

    String response =
    await _apiClient.postForm(Constants.LOGIN_EMR_USER, body);
    print("signUpResponse : " + response);
    return response;
  }

  @override
  Future<GenericResponse> sendOtp(phone) async {
    //User user = await getCurrentUser();
    print('attempt to hit out');
    var body = <String, dynamic>{
      'mobile': phone,
    };
    var response =
    await _apiClient.postForm(Constants.SEND_OTP, body);
    print("sendOtp : " + response);
    var data = json.decode(response);
    return GenericResponse.fromJson(data);
  }

  @override
  Future<String> verifyOtp(otp,mobile) async {
    //User user = await getCurrentUser();
    print('attempt to hit out');
    var body = <String, dynamic>{
      'mobile': mobile,
      'otp': otp,
    };
   // var response = "{\"status\": \"success\",\"message\": \"OTP Verification successful\",\"data\": { \"account_status\": \"registered\", \"session_id\": \"b6d023dfefb26c8115af672385518242\"}}";
    var response =  await _apiClient.postForm(Constants.VERIFY_OTP, body);
    print("sendOtp : " + response);

    return response;
  }

  @override
  Future<String> fetchUserData(id) async {
   // await openCache();

   // User user = await getCurrentUser();
    print('attempt fetch user data');

    var response =
    await _apiClient.get(Constants.GET_USER_DATA+id);
    print("fetchingUserDataResponse : " + response);
    return response;
  }




  /*
  * sets user login status to true
  */
  Future<void> loginUser(User user) async {
     await openCache();
    prefs!.setBool(Constants.CHECK_LOGIN_STATUS, true);
    bool? loginStatus = prefs!.getBool(Constants.CHECK_LOGIN_STATUS);
    print("login status:" + loginStatus.toString());
    prefs!.setString(Constants.LOGGED_IN_USER, json.encode(user));
    print("login cached:" + json.encode(user));
  }

  /*
  * sets user login status to true
  */
  Future<void> loginUserEmr(EmrUser user) async {
     await openCache();
    prefs!.setBool(Constants.CHECK_LOGIN_STATUS, true);
    bool? loginStatus = prefs!.getBool(Constants.CHECK_EMR_LOGIN_STATUS);
    print("emr login status:" + loginStatus.toString());
    prefs!.setString(Constants.LOGGED_IN_USER, json.encode(user));
    print("emr login cached:" + json.encode(user));
  }

  /*
  * set session Id
  */
  Future<void> setUserSession(String session) async {
     await openCache();
    prefs!.setString(Constants.SESSION_TOKEN, json.encode(session));
  }

  /*
  * set session Id
  */
  Future<void> setEmrUserSession(String session) async {
     await openCache();
    await prefs!.setString(Constants.EMR_SESSION_TOKEN, json.encode(session));
  }

  /*
  * returns the users login status
  */
  @override
  Future<bool> isLoggedIn() async {
      await openCache();
    // check if the key even exists
    bool? checkValue = prefs!.containsKey(Constants.CHECK_LOGIN_STATUS);

    if (checkValue) {
      var loginStatus = prefs!.getBool(Constants.CHECK_LOGIN_STATUS);
      print("isLoggedIn:" + loginStatus.toString());
      return loginStatus!;
    } else {
      return false;
    }
  }

  /*
  * returns the users login status
  */
  @override
  Future<bool> isEmrLoggedIn() async {
     await openCache();
    // check if the key even exists
    bool checkValue = prefs!.containsKey(Constants.CHECK_EMR_LOGIN_STATUS);

    if (checkValue) {
      bool? loginStatus = prefs!.getBool(Constants.CHECK_EMR_LOGIN_STATUS);
      print("isLoggedIn:" + loginStatus.toString());
      return loginStatus!;
    } else {
      return false;
    }
  }
  // checks shared preferences and fetches the user data saved there
  @override
  Future<String> getSessionValue(String key) async {
     await openCache();
    String? value = prefs!.getString(key);
    //print("session status get:" + value);
    return value!;
  }

  // checks shared preferences and fetches the user data saved there
  @override
  Future<User> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(Constants.LOGGED_IN_USER);
    var data = json.decode(userJson!);
    print("getCurrentUser:" + userJson);
    User user = User.fromJson(data);
    return user;
  }

  @override
  Future<bool> signOut() async {
     await openCache();
    prefs!.clear();
    return (prefs!.containsKey(Constants.LOGGED_IN_USER) || prefs!.containsKey(Constants.CHECK_LOGIN_STATUS));
  }
}
