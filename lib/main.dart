import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _minutes = 25;
  int _seconds = 0;

  var f = NumberFormat("00");

  Timer _timer = Timer(const Duration(seconds: 1), () {});

  bool _isRunning = false;
  bool _isPaused = false;
   bool _isBreakTime = false;

  void _pauseTimer() {
    setState(() {
      _timer.cancel();
      _isPaused = true;
      _isRunning = false;
    });
  }

  void _continueTimer() {
    setState(() {
      _isPaused = false;
      _isRunning = true;
      _timer.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_seconds > 0) {
          _seconds--;
        } else if (_minutes > 0) {
          _minutes--;
          _seconds = 59;
        } else {
          _timer.cancel();
        }
        setState(() {});
      });
    });
  }
void _stopTimer(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      backgroundColor: Colors.grey[900],
      
      title: const Text("Stop Timer",
      style: TextStyle(
        color: Colors.white,
      ),),
      content: const Text("Are you sure you want to stop the timer?",
      style: TextStyle(
        color: Colors.white,
      ),)
      ,
      actions: [
        
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        
          child: const Text("No",
          style: TextStyle(
            color: Colors.red,

          ) ,),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _timer.cancel();
              _resetTimer(25);
            });
            Navigator.of(ctx).pop();
          },
          child: const Text("Yes",
            style: TextStyle(
            color: Colors.red,

          ) ,),
        ),
      ],
    ),
  );
}


void _startTimer() {
  setState(() {
    _isRunning = true;
    _isPaused = false;
    if (_timer != null) {
      _timer.cancel();
    }
    if (_minutes > 0) {
      _seconds = _minutes * 60;
    }
    if (_seconds > 60) {
      _minutes = (_seconds / 60).floor();
      _seconds -= (_minutes * 60);
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        _seconds--;
      } else if (_minutes > 0) {
        _minutes--;
        _seconds = 59;
      } else {
        _timer.cancel();
        if (!_isBreakTime) {
          _resetTimer(5);
          _isBreakTime=true;
        } else {
          _resetTimer(25);
        }
      }
      setState(() {});
    });
  });
}

void _startBreakTimer() {
  setState(() {
    _isBreakTime = true;
    _minutes = 5;
    _seconds = 0;
    _startTimer();
  });
}

void _resetTimer(_minute) {
  setState(() {
    _isBreakTime = false;
    _minutes = _minute;
    _seconds = 0;
    _isRunning = false;
    _isPaused = false;
  });
}
  void _addOneMinute() {
  setState(() {
    _minutes += 1;
  });
}

 // ...existing code...
List<Map<String, dynamic>> _tasks = [];

void _showAddTaskDialog() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[900],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.red, size: 30),
                        onPressed: () {
                          TextEditingController taskNameController = TextEditingController();
                          TextEditingController sessionCountController = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.blueGrey[900],
                                title: const Text(
                                  "Add Task",
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: taskNameController,
                                      decoration: const InputDecoration(
                                        hintText: "Task Name",
                                        hintStyle: TextStyle(color: Colors.white54),
                                      ),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    TextField(
                                      controller: sessionCountController,
                                      decoration: const InputDecoration(
                                        hintText: "Number of Focus Sessions",
                                        hintStyle: TextStyle(color: Colors.white54),
                                      ),
                                      style: const TextStyle(color: Colors.white),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _tasks.add({
                                          'taskName': taskNameController.text,
                                          'sessions': sessionCountController.text,
                                          'completed': false,
                                        });
                                      });
                                      setModalState(() {});
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      "Add",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  if (_tasks.isNotEmpty)
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return ListTile(
                            leading: Radio<bool>(
                              value: true,
                              groupValue: task['completed'] == true,
                              onChanged: (val) async {
                                // Play 'ding' and remove the task
                                // await _playDing();
                                setState(() {
                                  _tasks.removeAt(index);
                                });
                                setModalState(() {});
                              },
                            ),
                            title: Text(
                              task['taskName'] ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "Sessions: ${task['sessions']}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          );
                        },
                      ),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

  Widget _buildActionButtons(BuildContext context) {
    if (!_isRunning && !_isPaused) {
      return ElevatedButton(
        onPressed: _isBreakTime? _startBreakTimer:_startTimer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40.0)),
          ),
        ),
        child:  Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 3),
          child: Text(
          _isBreakTime ? 'Start Break' : 'Start Focus session',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
        ),
      );
    } else if (_isRunning && !_isPaused) {
      return ElevatedButton(
        onPressed: _pauseTimer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(40.0)),
              side: BorderSide(
                color: Colors.white,
              )),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Text(
            'Pause',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ),
      );
    } else {
      // Paused state: Continue & Stop
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _continueTimer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 4),
              child: Text(
                'Continue',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () => _stopTimer(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                side: BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Text(
                'Stop',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
// ...existing code...

  @override
  Widget build(BuildContext contex) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/backgroundImage.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
              Colors.black12,
              Colors.black38,
            ])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              GestureDetector(
                onTap: _showAddTaskDialog,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Text(
                    'Please select a task...',
                    style: TextStyle(color: Colors.white54, fontSize: 20),
                  ),
                ),
              ),
              const Row(
                children: [],
              ),
              const SizedBox(
                height: 175,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${f.format(_minutes)}:${f.format(_seconds)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 70,
                      fontWeight: FontWeight.w200,
                      
                        

                    ),
                  )
                ],
              ),
              SizedBox(height: 15),
                    if (_minutes < 5)
                ElevatedButton(
                  onPressed: _addOneMinute,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 1, horizontal: 3),
                    child: Text(
                      '+ 1 Minute',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                height: 250,
              ),
              _buildActionButtons(context),
              SizedBox(height: 100,)
            ],
          ),
        ),
      ),
    );
  }
}
