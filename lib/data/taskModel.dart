class Task {
  String? id;
  String? title;
  bool? completed;
  String? dateTime;

  Task({this.title, this.completed = false, this.dateTime,this.id});
  Task.from(Task other)
      : title = other.title,
        completed = other.completed,
        dateTime = other.dateTime,
        id = other.id;

  Task.fromMap(Map map)
      : this.title = map['title'],
        this.completed = map['completed'],
        this.dateTime = map['dateTime'],
        this.id = map['id']
        ;

  Map toMap() {
    return {
      'title': this.title,
      'completed': this.completed,
      'dateTime': this.dateTime,
      'id':this.id
    };
  }
}