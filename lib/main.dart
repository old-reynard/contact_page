import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:simple_permissions/simple_permissions.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Contact Page',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: new MyHomePage(title: 'Contacts Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //returned by Navigator
  Contact _contact;
  //returned by simple_permissions
  Iterable<Contact> _contacts;

  @override
  void initState() {
    super.initState();
    getContactsPermissions();
  }

  void getContactsPermissions() {
    SimplePermissions.requestPermission(Permission.ReadContacts).then((value) {
      refreshContacts();
    });
  }


  refreshContacts() async {
    var contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
      _sortContacts();
    });
  }

  _sortContacts() {
    if (_contacts != null) {
      var temp = _contacts.toList();
      temp.sort((a,b) => a.displayName.compareTo(b.displayName));
      _contacts = temp;
    }
  }

  Future _navigateToContacts() async {
    Map results = await Navigator.of(context).push(MaterialPageRoute<Map>(
        builder: (BuildContext context) {
          return ContactListPage(contacts: _contacts,);
        },
    ));
    if (results != null && results.containsKey('contact')) {
      setState(() {
        _contact = results['contact'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = _contact == null ? "" : _contact.displayName;
    var phones = _contact == null ? null : _contact.phones.toList();
    String phoneNumbers = "";
    if (phones != null) {
      int len = phones.length;
      for (int i = 0; i < len; i++) {
        phoneNumbers += phones[i].value + (i == len - 1 ? "" : ", ");
      }
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(name),
            Text(phoneNumbers),
            RaisedButton(onPressed: _contacts == null ? null :_navigateToContacts,
              child: Text('Select Contact'),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactListPage extends StatefulWidget {
  ContactListPage({this.contacts});

  final Iterable<Contact> contacts;
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),

      body: SafeArea(
        child: widget.contacts != null
            ? ListView.builder(
          itemCount: widget.contacts?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            Contact c = widget.contacts?.elementAt(index);
            return ListTile(
              onTap: () {
                Navigator.of(context).pop({'contact':c});

              },
              leading: (c.avatar != null && c.avatar.length > 0)
                  ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                  : CircleAvatar(
                  child: Text(c.displayName.length > 1
                      ? c.displayName?.substring(0, 2)
                      : "")),
              title: Text(c.displayName ?? ""),
            );
          },
        )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

