import 'dart:convert';

import 'package:province_list/api/Network.dart';
import 'package:province_list/api/api_util.dart';
import 'package:province_list/api/my_response.dart';
import 'package:province_list/models/list_model.dart';
import 'package:province_list/utils/internet_utils.dart';

class ListController{
  static Future<MyResponse<List<ListModel>>> getList() async {

    String url = ApiUtil.MAIN_API_URL +  'scty.php';
    Map<String, String> headers = ApiUtil.getHeader(requestType: RequestType.Get);

    //Check Internet
    // bool isConnected = await InternetUtils.checkConnection();
    // if (!isConnected) {
    //   return MyResponse.makeInternetConnectionError();
    // }

    try {

      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<List<ListModel>> myResponse = MyResponse(response.statusCode);

      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        myResponse.data = ListModel.listFromJson(json.decode(response.body)) ;
      } else {
        myResponse.success = false;
        myResponse.setError(json.decode(response.body));
      }
      return myResponse;
    }catch(e){
      print('error getList : ${e.toString()}');
      return MyResponse.makeServerProblemError<List<ListModel>>();
    }
  }

}