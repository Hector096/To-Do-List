import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todolist/data/notification.dart';
import 'package:todolist/data/taskModel.dart';
import 'package:todolist/data/taskRepo.dart';
import 'package:todolist/utils/sizeConfig.dart';
import 'package:todolist/utils/snackBar.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TaskData data = TaskData();
  DateTime? selectedDate;
  TextEditingController _controller = TextEditingController();
  List<Task> taskList = [];
  Uuid uuid = new Uuid();
  var length = 0;

  @override
  void initState() {
    //initialize Notification provider
    Provider.of<NotificationService>(context, listen: false).initialize();
    getData();
    super.initState();
    //Load Data to tasklist
    getData();
  }

  //getting data from sharedprefs
  void getData() async {
    taskList = await data.loadData();
    //sorting task list in not completed tasks
    taskList.sort((a, b) {
      if (a.completed!) {
        return 1;
      }
      return -1;
    });
    //getting length of completed task
    length = taskList.where((item) => item.completed == false).length;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notifier, _) => Scaffold(
        appBar: AppBar(
          toolbarHeight: SizeConfig.heightMultiplier * 2,
          backgroundColor: Colors.black,
          title: Text(
            "Personal List",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.black,
        body: taskList.isEmpty
            ? emptyList()
            : Padding(
                padding: const EdgeInsets.only(top: 20),
                child: buildListView(notifier),
              ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        backgroundColor: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        title: Center(
                          child: Text(
                            "Add Task",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              controller: _controller,
                              autofocus: true,
                              style: TextStyle(
                                  fontSize: SizeConfig.textMultiplier * 1.5,
                                  color: Colors.white),
                              decoration: InputDecoration(
                                  labelText: "Task",
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 8,
                              ),
                              child: TextButton(
                                  onPressed: () {
                                    _selectDate(context);
                                  },
                                  child: selectedDate != null
                                      ? Text(
                                          "${DateFormat('EEEE').format(selectedDate!)} at ${DateFormat('h:mm a').format(selectedDate!)}")
                                      : Text("Add Remainder")),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_controller.text.isNotEmpty) {
                                        if (selectedDate != null) {
                                          Task t = Task(
                                              title: _controller.text.trim(),
                                              completed: false,
                                              id: uuid.v1(),
                                              dateTime:
                                                  selectedDate.toString());
                                          taskList.add(t);
                                          await data.saveData(taskList);
                                          notifier.sheduledNotification(
                                              _controller.text, selectedDate!);
                                          Navigator.pop(context);
                                          setState(() {
                                            _controller.clear();
                                            selectedDate = null;
                                            getData();
                                          });
                                        } else {
                                          Task t = Task(
                                              title: _controller.text.trim(),
                                              completed: false,
                                              id: uuid.v1(),
                                              dateTime: "");
                                          taskList.add(t);
                                          await data.saveData(taskList);
                                          Navigator.pop(context);
                                          setState(() {
                                            _controller.clear();
                                            selectedDate = null;
                                            getData();
                                          });
                                        }
                                      }
                                    },
                                    child: Text("ADD",
                                        style: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 1.5,
                                        )),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  });
            },
            child: Icon(
              Icons.add,
              color: Colors.orange,
              size: SizeConfig.imageSizeMultiplier * 10,
            ),
            backgroundColor: Colors.transparent),
      ),
    );
  }

  Widget emptyList() {
    return Center(
        child: Text(
      'No items',
      style: TextStyle(color: Colors.white),
    ));
  }

  Widget buildListView(NotificationService notificationService) {
    //reorderable list to enable reorder to complete task functionality in the task list. this fuctionality only work when there are more then 3 task in the list.
    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) => setState(() {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        if (newIndex >= length) {
          setState(() {
            taskList[oldIndex].completed = true;
            notificationService.cancelNotification();
            data.saveData(taskList);
          });
        }
        final task = taskList.removeAt(oldIndex);
        taskList.insert(newIndex, task);
      }),
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        final item = taskList[index];
        //enable swiping design from startToend and endTostart
        return taskList[index].completed!
            ? Dismissible(
                key: ValueKey(taskList[index].id),
                background: Container(),
                direction: DismissDirection.endToStart,
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child:
                      Icon(Icons.delete_forever, color: Colors.red, size: 32),
                ),
                child: buildListTile(item),
                onDismissed: (direction) =>
                    dismissItem(context, index, direction, notificationService),
              )
            : Dismissible(
                key: ValueKey(taskList[index].id),
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.done, color: Colors.green, size: 32),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child:
                      Icon(Icons.delete_forever, color: Colors.red, size: 32),
                ),
                child: buildListTile(item),
                onDismissed: (direction) =>
                    dismissItem(context, index, direction, notificationService),
              );
      },
    );
  }

//Date Picker for getting date and time to set remainder
  Future<void> _selectDate(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Center(
        child: CupertinoActionSheet(
          actions: [
            SizedBox(
              height: SizeConfig.heightMultiplier * 30,
              child: CupertinoDatePicker(
                initialDateTime: DateTime.now(),
                mode: CupertinoDatePickerMode.dateAndTime,
                minimumDate: DateTime(DateTime.now().year, 2, 1),
                use24hFormat: true,
                onDateTimeChanged: (dateTime) =>
                    setState(() => this.selectedDate = dateTime),
              ),
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Done'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

//enable swipe functionality from startToend and endTo start
  void dismissItem(BuildContext context, int index, DismissDirection direction,
      NotificationService notificationService) {
    switch (direction) {
      case DismissDirection.endToStart:
        notificationService.cancelNotification();
        setState(() {
          taskList.removeAt(index);
        });
        data.saveData(taskList);

        Utils.showSnackBar(context, 'Task has been deleted');
        break;
      case DismissDirection.startToEnd:
        if (taskList[index].completed != true) {
          notificationService.cancelNotification();
          taskList[index].completed = true;
          var item = taskList.removeAt(index);
          item.id = uuid.v1();
          taskList.insert(index, Task.from(item));
          data.saveData(taskList);
          getData();
          Utils.showSnackBar(context, 'Task has been Completed');
          break;
        }
        break;
      default:
        break;
    }
  }

//ListTile Design with gradient background
  Widget buildListTile(Task item) => item.completed!
      ? Container(
          decoration: BoxDecoration(color: Colors.black),
          child: ListTile(
            key: ValueKey(item.title),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.textMultiplier * 2.5,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  item.dateTime!.isNotEmpty
                      ? Text(
                          "${DateFormat('EEEE').format(DateTime.parse(item.dateTime!))} at ${DateFormat('h:mm a').format(DateTime.parse(item.dateTime!))}")
                      : Center()
                ],
              ),
            ),
            onTap: () {},
          ),
        )
      : Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: [Colors.red, Colors.orange],
            stops: [0, 5],
          )),
          child: ListTile(
            key: ValueKey(item.title),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.textMultiplier * 2.5),
                ),
                const SizedBox(height: 4),
                item.dateTime!.isNotEmpty
                    ? Text(
                        "${DateFormat('EEEE').format(DateTime.parse(item.dateTime!))} at ${DateFormat('h:mm a').format(DateTime.parse(item.dateTime!))}")
                    : Center()
              ],
            ),
            onTap: () {},
          ),
        );
}
