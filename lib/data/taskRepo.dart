  
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/data/taskModel.dart';
import 'package:uuid/uuid.dart';

class TaskData {
  SharedPreferences? prefs;
  
  //For having unique id to every item
  Uuid uuid = new Uuid();
  
 //Load data from SharedPrefs
  Future<List<Task>> loadData() async {
    prefs = await SharedPreferences.getInstance();
    List<String>? listString = prefs!.getStringList('list');
    if (listString != null) {
      List<Task> list =
      listString.map((item) => Task.fromMap(json.decode(item))).toList();
      return list;
    } else {
      return [];
    }
  }

  //Save Data to Shared prefs
  Future<bool> saveData(List<Task> list) async {
    prefs = await SharedPreferences.getInstance();
    List<String> stringList =
        list.map((item) => json.encode(item.toMap())).toList();
    return prefs!.setStringList('list', stringList);
  }
}