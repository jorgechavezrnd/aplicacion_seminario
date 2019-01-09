import 'package:aplicacion_seminario/models/student_model.dart';
import 'package:flutter/material.dart';

class PresentStudentsPage extends StatelessWidget {
  List<StudentModel> presentStudents;

  PresentStudentsPage({ this.presentStudents });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: this.presentStudents.length,
      itemBuilder: (context, i) => Column(
        children: <Widget>[
          Divider(
            height: 10.0,
          ),
          ListTile(
            leading: CircleAvatar(
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(this.presentStudents[i].pictureUrl),
            ),
            title: Text(
              this.presentStudents[i].name,
              style: TextStyle(fontWeight: FontWeight.bold)
            )
          )
        ],
      ),
    );
  }
}