import 'package:province_list/api/my_response.dart';
import 'package:province_list/controllers/list_controller.dart';
import 'package:province_list/models/list_model.dart';
import 'package:province_list/utils/notification_service.dart';
import 'package:province_list/utils/show_message.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<ListModel> myList;
  List<ListModel> items = [];
  bool isLoading = false;
  late Position position;
  String lat = 'Not Set';
  String long = 'Not Set';
  late Box<ListModel> box;
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    getListFromServer();
    getSavedPosition();
    tz.initializeTimeZones();
    super.initState();
  }
  getListFromServer() async{
    setState(() {isLoading = true; });
    box = await Hive.openBox('myData1');
    if(box.isEmpty){
      MyResponse<List<ListModel>> myResponse = await ListController.getList();
      if(myResponse.success){
        myList = myResponse.data;
        for(ListModel element in myList){
          box.add( element);
        }
      }
      else{
        myList = [];
        showMessage(message: 'Error in receiving data',myContext: context,error: true);
      }
    }
    else{
      myList = [];
      for (ListModel element in box.values) {
        myList.add(element);
      }
    }

    items.addAll(myList);
    setState(() {isLoading = false; });
  }
  getSavedPosition() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('lat')){
      lat = prefs.getString('lat')!;
      long = prefs.getString('long')!;
    }
    else{
      lat = long = 'Not Set';
    }
  }
  getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showMessage(message: 'Error: Location services are disabled.',myContext: context,error: true);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showMessage(message: 'Location permissions are denied',myContext: context,error: true);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showMessage(message: 'Location permissions are permanently denied, we cannot request permissions.',myContext: context,error: true);
    }
    else{
      position = await Geolocator.getCurrentPosition();
      lat = position.latitude.toString();
      long = position.longitude.toString();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('lat', position.latitude.toString());
      prefs.setString('long', position.longitude.toString());
      showMessage(myContext: context,message: 'Location Saved',error: false);
    }

    setState(() {
      isLoading = false;
    });
  }
  void filterSearchResults(String query) {
    if(query.isNotEmpty) {
      List<ListModel> dummyListData = [];
      for (var item in myList) {
        if(item.name.contains(query)) {
          dummyListData.add(item);
        }
      }
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    }
    else {
      setState(() {
        items.clear();
        items.addAll(myList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('$lat \n $long'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          getCurrentLocation();
        },
        child: const Icon(Icons.my_location),
      ),
      body: isLoading ?
        const Center(child: CircularProgressIndicator(),):
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.white,
                child: TextField(
                  onChanged: (value) {
                    filterSearchResults( value);
                  },
                  controller: editingController,
                  decoration: const InputDecoration(
                      labelText: "Search",
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0),
                          ),
                      )
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context,int index){
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListTile(
                      onTap: (){
                        ListModel newVal = items[index];
                        newVal.selected = !newVal.selected;
                        box.putAt(index, newVal);
                        setState(() { });
                        NotificationService().showNotification(
                            index,
                            "Province ID : ${items[index].provinceId}",
                            "Province Name : ${items[index].name}",
                            10
                        );
                      },
                      title: Text(items[index].name,style: Theme.of(context).textTheme.bodyText1,),
                      subtitle: Text('آیدی استان : ${items[index].provinceId}'),
                      tileColor: Colors.grey.shade200,
                      selected: items[index].selected,
                      selectedTileColor:Colors.black26 ,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  );
                }
              ),
            ),
          ],
        )
    );
  }



}
