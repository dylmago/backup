import 'package:flutter/material.dart';
import 'package:paiement_stripe/nav_section.dart';
import 'package:paiement_stripe/services/auth_service.dart';

class UserCompaniesPage extends StatefulWidget {
  @override
  _UserCompaniesPageState createState() => _UserCompaniesPageState();
}

class _UserCompaniesPageState extends State<UserCompaniesPage> {
  //final _authService = AuthService();
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
            child: Text("Vos compagnies: ", style: Theme.of(context).textTheme.headline4),
          ),
          Column(
            children: List.generate(
              userAssociations.length,
              (index) => Card(
                child: Container(
                  padding: EdgeInsets.only(left:10, top:10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("ID: ", style: TextStyle(fontSize: 20)),
                          Text(userAssociations[index].companyId)
                        ],
                      ),
                      Row(
                        children: [
                          Text("Nom: ", style: TextStyle(fontSize: 20)),
                          Text(userAssociations[index].companyName)
                        ],
                      ),
                      Row(
                        children: [
                          Text("Permission: ", style: TextStyle(fontSize: 20)),
                          Text(userAssociations[index].permission)
                        ],
                      ),
                      Row(
                        children: [
                          Text("Association: ", style: TextStyle(fontSize: 20)),
                          Text(userAssociations[index].association)
                        ],
                      ),
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
            child: Text("Vos compagnies: ", style: Theme.of(context).textTheme.headline3),
          ),
          Expanded(
            flex: 10,
            child: Container(
              padding: EdgeInsets.all(20),
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Company_id')),
                  DataColumn(label: Text('Company_name')),
                  DataColumn(label: Text('Permission')),
                  DataColumn(label: Text('Association')),
                ],
                rows: List.generate(
                  userAssociations.length, 
                  (index) => DataRow(
                    cells: [
                      DataCell(Text(userAssociations[index].companyId)),
                      DataCell(Text(userAssociations[index].companyName)),
                      DataCell(Text(userAssociations[index].permission)),
                      DataCell(Text(userAssociations[index].association)),
                    ]
                  )
                ),
              )
            )
          )
        ]
      );
    }
  }
}