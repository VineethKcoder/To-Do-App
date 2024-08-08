import 'package:flutter/material.dart';
import 'shared_prefs.dart';
import 'login_screen.dart';

class UserProfilePage extends StatelessWidget {
  final String username;

  UserProfilePage({required this.username});

  @override
  Widget build(BuildContext context) {
    Colors.grey;
    return Scaffold(
      appBar: AppBar(
        title: Text('User'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'abcd $username',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () async {
              await SharedPrefs.saveLoginInfo('', ''); // Clear login info
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text('Log Out'),
          ),
        ),
      ),
    );
  }
}
