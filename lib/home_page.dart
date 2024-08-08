import 'package:flutter/material.dart';
import 'shared_prefs.dart';
import 'todo.dart';
import 'user_profile_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<ToDo> _toDoList = [];
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final loginInfo = await SharedPrefs.getLoginInfo();
    if (loginInfo != null) {
      setState(() {
        username = loginInfo['username']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _sortToDoList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: Text(
          'To-Do',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserProfilePage(username: username)),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[100]!, Colors.teal[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedList(
          key: _listKey,
          initialItemCount: _toDoList.length,
          itemBuilder: (context, index, animation) {
            final toDo = _toDoList[index];
            return _buildToDoItem(toDo, animation, index);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[700],
        onPressed: () => _showAddEditToDoModal(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildToDoItem(ToDo toDo, Animation<double> animation, int index) {
    Color getPriorityColor(String priority) {
      switch (priority) {
        case 'High':
          return Colors.redAccent;
        case 'Normal':
          return Colors.orangeAccent;
        case 'Low':
          return Colors.yellowAccent;
        default:
          return Colors.grey[200]!;
      }
    }

    Duration remainingTime = toDo.dueDate.difference(DateTime.now());
    String remainingTimeText = "${remainingTime.inDays} days, "
        "${remainingTime.inHours % 24} hours and "
        "${remainingTime.inMinutes % 60} minutes remaining";

    return Padding(
      key: Key(toDo.title),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SizeTransition(
        sizeFactor: animation,
        child: GestureDetector(
          onTap: () => _showAddEditToDoModal(toDo: toDo, index: index),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: toDo.isCompleted
                ? Colors.grey[300]
                : getPriorityColor(toDo.priority),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toDo.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration:
                          toDo.isCompleted ? TextDecoration.lineThrough : null,
                      fontSize: 18,
                      color: toDo.isCompleted ? Colors.black54 : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    toDo.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        remainingTimeText,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              toDo.isCompleted ? Colors.black54 : Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: toDo.isCompleted,
                            onChanged: (bool? value) {
                              setState(() {
                                toDo.isCompleted = value!;
                                if (toDo.isCompleted) {
                                  _moveToDoToBottom(index);
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _removeToDoItem(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEditToDoModal({ToDo? toDo, int? index}) {
    final TextEditingController titleController =
        TextEditingController(text: toDo?.title ?? '');
    final TextEditingController descriptionController =
        TextEditingController(text: toDo?.description ?? '');
    String priority = toDo?.priority ?? 'Normal';
    DateTime dueDate = toDo?.dueDate ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.teal[700],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildTextField('Title', titleController),
                SizedBox(height: 16),
                _buildTextField('Description', descriptionController),
                SizedBox(height: 16),
                _buildPrioritySelection(priority, (value) {
                  setState(() {
                    priority = value!;
                  });
                }),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );

                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(dueDate),
                      );

                      if (pickedTime != null) {
                        setState(() {
                          dueDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Text('Select Due Date & Time'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[800],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (toDo == null) {
                      _addToDo(ToDo(
                        title: titleController.text,
                        description: descriptionController.text,
                        priority: priority,
                        dueDate: dueDate,
                        isCompleted: false,
                      ));
                    } else {
                      _editToDo(
                        index!,
                        ToDo(
                          title: titleController.text,
                          description: descriptionController.text,
                          priority: priority,
                          dueDate: dueDate,
                          isCompleted: toDo.isCompleted,
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[800],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[600]!),
        color: Colors.teal[600],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white70),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPrioritySelection(
      String currentPriority, ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[600]!),
        color: Colors.teal[600],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Radio(
            value: 'Low',
            groupValue: currentPriority,
            onChanged: onChanged,
            activeColor: Colors.yellowAccent,
          ),
          Text('Low', style: TextStyle(color: Colors.white)),
          Radio(
            value: 'Normal',
            groupValue: currentPriority,
            onChanged: onChanged,
            activeColor: Colors.orangeAccent,
          ),
          Text('Normal', style: TextStyle(color: Colors.white)),
          Radio(
            value: 'High',
            groupValue: currentPriority,
            onChanged: onChanged,
            activeColor: Colors.redAccent,
          ),
          Text('High', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _addToDo(ToDo toDo) {
    setState(() {
      _toDoList.add(toDo);
      _listKey.currentState?.insertItem(_toDoList.length - 1);
    });
  }

  void _editToDo(int index, ToDo updatedToDo) {
    setState(() {
      _toDoList[index] = updatedToDo;
    });
  }

  void _removeToDoItem(int index) {
    ToDo removedToDo = _toDoList.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildToDoItem(removedToDo, animation, index),
    );
  }

  void _moveToDoToBottom(int index) {
    ToDo movedToDo = _toDoList.removeAt(index);
    _toDoList.add(movedToDo);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildToDoItem(movedToDo, animation, index),
      duration: Duration(milliseconds: 300),
    );
    _listKey.currentState?.insertItem(_toDoList.length - 1);
  }

  void _sortToDoList() {
    _toDoList.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      return a.dueDate.compareTo(b.dueDate);
    });
  }
}
