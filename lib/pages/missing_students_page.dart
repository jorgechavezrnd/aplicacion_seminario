import 'package:aplicacion_seminario/models/student_model.dart';
import 'package:flutter/material.dart';

class MissingStudentsPage extends StatelessWidget {
  List<StudentModel> missingStudents;

  MissingStudentsPage({ this.missingStudents });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: this.missingStudents.length,
      itemBuilder: (context, i) => Column(
        children: <Widget>[
          Divider(
            height: 10.0,
          ),
          ListTile(
            leading: CircleAvatar(
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(this.missingStudents[i].pictureUrl),
            ),
            title: Text(
              this.missingStudents[i].name,
              style: TextStyle(fontWeight: FontWeight.bold)
            )
          )
        ],
      ),
    );
  }
}
