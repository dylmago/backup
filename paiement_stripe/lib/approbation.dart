import 'package:flutter/material.dart';
import 'package:paiement_stripe/services/auth_service.dart';
//import 'package:paiement_stripe/models/User.dart';
import 'package:paiement_stripe/models/Obj.dart';
import 'package:paiement_stripe/nav_section.dart';

class UserApprobationPage extends StatefulWidget {
  @override
  _UserApprobationPageState createState() => _UserApprobationPageState();
}

class _UserApprobationPageState extends State<UserApprobationPage> {
  final _authService = AuthService();
  final navSection = NavSection();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(   
        iconTheme: IconThemeData(color: Colors.black),                
        title: navSection,
        backgroundColor: Colors.white,
      ),
      body: contentSection()
    );
  }

  Widget contentSection() {
    if(isSmallScreen(context)) {
      return ListView(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text("User Approbation: ", style: Theme.of(context).textTheme.headline4),
          ),
          Column(
            children: List.generate(
              compUsers.length,
              (index) => Card(
                child: Container(
                  //padding: EdgeInsets.all(10),
                  padding: EdgeInsets.only(left:10, top:10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("Nom: ", style: TextStyle(fontSize: 20)),
                          Text(compUsers[index].lastname)
                        ],
                      ),
                      Row(
                        children: [
                          Text("Prénom: ", style: TextStyle(fontSize: 20)),
                          Text(compUsers[index].firstname)
                        ],
                      ),
                      Row(
                        children: [
                          Text("Email: ", style: TextStyle(fontSize: 20)),
                          Text(compUsers[index].email)
                        ],
                      ),
                      Row(
                        children: [
                          Text("Permission: ", style: TextStyle(fontSize: 20)),
                          Text(compUsers[index].permission)
                        ],
                      ),
                      Row(
                        children: [
                          Text("Association: ", style: TextStyle(fontSize: 20)),
                          Text(compUsers[index].association)
                        ],
                      ),
                      TextButton(
                        onPressed: () async {
                          await _authService.getPermissions();
                          await _authService.getAssoc();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => UserEditPage(index: index)));
                        },
                        child: Text("edit")
                      )
                    ]
                  )
                ) 
              )
            )
          )
        ],
      );
    }
    else {
      return ListView(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text("User Approbation: ", style: Theme.of(context).textTheme.headline3),
          ),
          Expanded(
            flex: 10,
            child: Container(
              padding: EdgeInsets.all(20),
              child: DataTable(
                //rowsPerPage: 10,
                columns: [
                  DataColumn(label: Text('Nom')),
                  DataColumn(label: Text('Prénom')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Permission')),
                  DataColumn(label: Text('Association')),
                  DataColumn(label: Text('')),
                ],
                rows: List.generate(
                  compUsers.length, 
                  (index) => DataRow(
                    cells: [
                      DataCell(Text(compUsers[index].lastname)),
                      DataCell(Text(compUsers[index].firstname)),
                      DataCell(Text(compUsers[index].email)),
                      DataCell(Text(compUsers[index].permission)),
                      DataCell(Text(compUsers[index].association)),
                      DataCell(
                        TextButton(
                          onPressed: () async {
                            await _authService.getPermissions();
                            await _authService.getAssoc();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => UserEditPage(index: index)));
                          },
                          child: Text("edit")
                        )
                      )
                    ]
                  )
                ),
                //source: _DataSource(context)
              )
              /*child: Table(
                //defaultColumnWidth: FixedColumnWidth(120.0),  
                border: TableBorder.all(  
                  color: Colors.black,  
                  style: BorderStyle.solid,  
                  width: 2
                ),
                children: List.generate(
                  compUsers.length, 
                  (index) => TableRow(
                    children: [
                      TableCell(child: Text(compUsers[index].lastname, style: TextStyle(fontSize: 20.0))),
                      TableCell(child: Text(compUsers[index].firstname, style: TextStyle(fontSize: 20.0))),
                      TableCell(child: Text(compUsers[index].email, style: TextStyle(fontSize: 20.0))),
                      TableCell(child: Text(compUsers[index].association, style: TextStyle(fontSize: 20.0))),
                    ]
                  )
                ),
                /*children: [
                  TableRow(
                    children: [  
                      Column(children:[Text('Nom', style: TextStyle(fontSize: 20.0))]),  
                      Column(children:[Text('Prénom', style: TextStyle(fontSize: 20.0))]),  
                      Column(children:[Text('Mail', style: TextStyle(fontSize: 20.0))]),
                      Column(children:[Text('Status', style: TextStyle(fontSize: 20.0))]),
                      /*TableCell(child: Text('Website', style: TextStyle(fontSize: 20.0))),
                      TableCell(child: Text('Website', style: TextStyle(fontSize: 20.0))),
                      TableCell(child: Text('Website', style: TextStyle(fontSize: 20.0)))*/
                    ]
                  ),
                  //afficher tous les utilisateurs de la compagnie
                  List.generate(
                    compUsers.length, 
                    (index) => TableRow(
                      children: [
                        TableCell(child: Text(compUsers[index].lastname, style: TextStyle(fontSize: 20.0))),
                        TableCell(child: Text(compUsers[index].firstname, style: TextStyle(fontSize: 20.0))),
                        TableCell(child: Text(compUsers[index].email, style: TextStyle(fontSize: 20.0))),
                        TableCell(child: Text(compUsers[index].association, style: TextStyle(fontSize: 20.0))),
                      ]
                    )
                  ),
                  //
                  TableRow( children: [  
                    Column(children:[Text('Javatpoint')]),  
                    Column(children:[Text('Flutter')]),  
                    Column(children:[Text('5*')]),  
                    Column(children:[Text('5*')]),  
                  ]),  
                ],*/
              )*/
            )
          )
        ]
      );
    }
  }
}

//--------------------------------------------------------------------------------------------------
class UserEditPage extends StatefulWidget {
  final int index;

  UserEditPage({Key key, this.index}) : super(key: key);

  @override
  _UserEditPageState createState() => _UserEditPageState(index);
}

class _UserEditPageState extends State<UserEditPage> {
  int index;
  final _authService = AuthService();
  String assoc;
  String permit;
  bool disabled;

  _UserEditPageState(int i) {
    index = i;
  }

  @override
  void initState() {
    super.initState();
    assoc = compUsers[index].association;
    permit = compUsers[index].permission;
    disabled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Text("User Edit", style: Theme.of(context).textTheme.headline4),
            Container(
              //alignment: Alignment.bottomLeft,
              child: Text("User Edit", style: Theme.of(context).textTheme.headline4),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text("Nom: ", style: TextStyle(fontSize: 20)),
                Text(compUsers[this.index].lastname),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text("Prénom: ", style: TextStyle(fontSize: 20)),
                Text(compUsers[this.index].firstname),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text("Email: ", style: TextStyle(fontSize: 20)),
                Text(compUsers[this.index].email),
              ],
            ),
            SizedBox(height: 6),
            dropDownPermission(),
            SizedBox(height: 6),
            dropDownStatus(),
            SizedBox(height: 10),
            SizedBox(
              height: 40,
              width: 100,
              child: buttonValidate(),
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("retour à la liste des utilisateurs")
              )
            )
          ] 
        )
      )
      
    );
  }

  Widget buttonValidate() {
    return TextButton(
      onPressed: disabled ? null : () async {
        int permissionID;
        for(int i = 0; i < permissions.length; i++) {
          if(permissions[i].title == permit) permissionID = permissions[i].id;
        }
        int assocID;
        for(int i = 0; i < associations.length; i++) {
          if(associations[i].title == assoc) assocID = associations[i].id;
        }
        compUsers[index].association = assoc;
        compUsers[index].permission = permit;
        //await _authService.postCompUsers(permissionID, compUsers[index].email, index);
        await _authService.postCompUsers(permissionID, compUsers[index].email, assocID);
        await _authService.getCompUsers();
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserApprobationPage()));
      },
      child: Text("Valider"),
      style: ButtonStyle(
        foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.disabled) ? null : Colors.white;
        }),
        backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.disabled) ? Colors.grey : Colors.blue;
        }),
      )
    );
  }

  Widget dropDownStatus() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text("Status: ", style: TextStyle(fontSize: 20)),
        ),
        DropdownButton<String>(
          value: assoc,
          icon: Icon(Icons.arrow_downward),
          iconSize: 20,
          elevation: 16,
          style: TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String newValue) {
            setState(() {
              assoc = newValue;
              disabled = false;
            });
          },
          //items: <String>['Approved', 'Waiting for approval', 'Rejected']
          items: associations
          .map<DropdownMenuItem<String>>((Objet value) {
            return DropdownMenuItem<String>(
              value: value.title,
              child: Text(value.title),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget dropDownPermission() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text("Permission: ", style: TextStyle(fontSize: 20)),
        ),
        DropdownButton<String>(
          value: permit,
          icon: Icon(Icons.arrow_downward),
          iconSize: 20,
          elevation: 16,
          style: TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String newValue) {
            setState(() {
              permit = newValue;
              disabled = false;
            });
          },
          items: permissions
          .map<DropdownMenuItem<String>>((Objet value) {
            return DropdownMenuItem<String>(
              value: value.title,
              child: Text(value.title),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/*class _DataSource extends DataTableSource {

  _DataSource(this.context) {
    _rows = compUsers;
  }

  final BuildContext context;
  List<Utilisateur> _rows;

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _rows.length) return null;
    final row = _rows[index];
    return DataRow.byIndex(
      index: index,
      //selected: row.selected,
      /*onSelectChanged: (value) {
        if (row.selected != value) {
          _selectedCount += value ? 1 : -1;
          assert(_selectedCount >= 0);
          row.selected = value;
          notifyListeners();
        }
      },*/
      cells: [
        DataCell(Text(row.lastname)),
        DataCell(Text(row.firstname)),
        DataCell(Text(row.email)),
        DataCell(Text(row.association)),
      ],
    );
  }

  @override
  int get rowCount => _rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}*/