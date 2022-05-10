
import 'package:province_list/api/api_util.dart';

class MyResponse<T>{

  bool success=false;
  late T data;
  List<dynamic> errors=[];
  String errorText="";
  int responseCode;


  MyResponse(this.responseCode);

  setError(Map<String,dynamic> jsonObject){
    String? error = jsonObject['error'];
    if(error!=null){
      this.errors = [error];
      errorText = getFormattedError(this.errors);
      return;
    }
    List<dynamic>? errors = jsonObject['errors'];
    if(errors!=null){
      this.errors = errors;
      errorText = getFormattedError(errors);
      return;
    }
    errorText="Something wrong. please try again";

  }

  static String getFormattedError(List<dynamic> errors){
    String errorText = "";
    for(int i=0;i<errors.length;i++){
      errorText += "- " + errors[i] + (i+1<errors.length ? "\n" : "" );
    }
    return errorText;
  }


  static MyResponse<T> makeInternetConnectionError<T>(){
    MyResponse<T> myResponse = MyResponse(ApiUtil.INTERNET_NOT_AVAILABLE_CODE);
    myResponse.errorText = "Please turn on internet";
    return myResponse;
  }

  static MyResponse<T> makeServerProblemError<T>(){
    MyResponse<T> myResponse = MyResponse(ApiUtil.SERVER_ERROR_CODE);
    myResponse.errorText = "Server Problem! Please try again later";
    return myResponse;
  }
}