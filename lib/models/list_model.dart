import 'package:hive/hive.dart';
part 'HiveDatabase.g.dart';

@HiveType(typeId : 1, adapterName:' HiveDatabaseAdapter')
class ListModel{
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String provinceId;
  @HiveField(2)
  late String name;
  @HiveField(3)
  late bool selected;

  ListModel({required this.id,required this.provinceId,required this.name,required this.selected});

  ListModel.fromJson(Map json){
      id = json['id'];
      provinceId = json['province_id'];
      name = json['name'];
      selected = false;
  }

  static List<ListModel> listFromJson(List jsonList){
    List<ListModel> res = [];
    for (Map json in jsonList) {
      ListModel x = ListModel.fromJson(json);
      res.add(x);
    }
    return res;
  }

}