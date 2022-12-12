library constants;

import 'dart:convert';

const String BASE_URL = "http://142.93.167.228/api/v1/";

// http client constants
var headers = <String, String>{
  "Accept": "application/x-www-form-urlencoded",
  'Content-Type': 'application/x-www-form-urlencoded',
  'X-API-Key': 'c8a54497b9ab1ed34e7b3a9cc8ea648c966fe3af'
};



var sessionDetails = jsonEncode(<String, String>{
  'session_id': "101",
  'session_token': "Sportixe_c962f2fbe7e7c1c5e5a51438db9b06c9"
});

// secure storage keys
const String CHECK_LOGIN_STATUS = "loginstatus";
const String CHECK_EMR_LOGIN_STATUS = "loginstatus";

const String SESSION_ID = "session_id";
const String SESSION_TOKEN = "session_token";
const String EMR_SESSION_TOKEN = "session_token";

const String LOGGED_IN_USER = "user";
const String LOGGED_IN_EMR_USER = "emruser";

// API fetch paths
const String SEND_OTP = BASE_URL + "user/auth/mobile";
const String VERIFY_OTP = BASE_URL + "user/auth/otp_verify";
const String CREATE_ACCOUNT = BASE_URL + "user/auth/register";
const String GET_USER_DATA = BASE_URL + "user/";


const String BRANCHES_FETCH_PATH = BASE_URL + "organization/branches";

const String ICON_FETCH_PATH = "http://apprant.com/port/api/icons/";
const String LOGIN_STRING_REQUEST = BASE_URL + "user/login";
const String FETCH_TIMELINE_PATH = BASE_URL + "schedule/timeline/";

const String NOTIFICATIONS_FETCH_PATH = BASE_URL + "user/notification/";
const String PURPOSES_FETCH_PATH =
    "http://apprant.com/port/api/schedule/purpose";
const String AVAILABLE_TIME_FETCH_PATH =
    "http://apprant.com/port/api/time/organization/user/purpose";
const String SCHEDULES_FETCH_PATH = BASE_URL + "user/schedule/";
const String USERS_FETCH_PATH = BASE_URL + "/organization/user";

// API post paths
const String CREATE_STUDENT_PROFILE = BASE_URL + "user/auth/register";
const String UPDATE_USER_PROFILE = BASE_URL + "user/update";

const String LOGIN_EMR_USER = BASE_URL + "emr/auth/login";

const String SCHEDULE_POST_PATH = BASE_URL + "schedule/create";
const String CALL_EMR = BASE_URL + "user/call_112";
