import 'package:flutter/material.dart';
import 'dart:convert'; // ضروري لتحويل القائمة إلى نص لحفظها
import 'package:shared_preferences/shared_preferences.dart';

void main() =>
    runApp(MaterialApp(home: TodoApp(), debugShowCheckedModeBanner: false));

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks(); // تحميل المهام عند فتح التطبيق
  }

  // وظيفة لحفظ المهام في ذاكرة الجهاز
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    // تحويل القائمة إلى صيغة JSON نصية ليتمكن النظام من حفظها
    List<String> taskListString = _tasks
        .map((task) => jsonEncode(task.toJson()))
        .toList();
    await prefs.setStringList('user_tasks', taskListString);
  }

  // وظيفة لتحميل المهام من الذاكرة
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? taskListString = prefs.getStringList('user_tasks');
    if (taskListString != null) {
      setState(() {
        _tasks = taskListString
            .map((item) => Task.fromJson(jsonDecode(item)))
            .toList();
      });
    }
  }

  void _addNewTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: _controller.text));
        _controller.clear();
      });
      _saveTasks(); // حفظ بعد الإضافة
    }
  }

  @override
  Widget build(BuildContext context) {
    // SafeArea تمنع تداخل الأزرار مع نظام التشغيل أسفل الشاشة
    return Scaffold(
      appBar: AppBar(
        title: Text('مهامي المستقلة'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'أضف مهمة جديدة...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.add_box, color: Colors.green, size: 45),
                    onPressed: _addNewTask,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: CheckboxListTile(
                      title: Text(
                        _tasks[index].title,
                        style: TextStyle(
                          decoration: _tasks[index].isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: _tasks[index].isDone,
                      onChanged: (bool? value) {
                        setState(() {
                          _tasks[index].isDone = value!;
                        });
                        _saveTasks(); // حفظ بعد تعديل الحالة
                      },
                      secondary: IconButton(
                        icon: Icon(Icons.delete_sweep, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            _tasks.removeAt(index);
                          });
                          _saveTasks(); // حفظ بعد الحذف
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// تعديل الكلاس ليدعم تحويل البيانات (Serialization)
class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});

  // تحويل الكائن إلى Map ليتم حفظه
  Map<String, dynamic> toJson() => {'title': title, 'isDone': isDone};

  // استعادة الكائن من Map
  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(title: json['title'], isDone: json['isDone']);
}
