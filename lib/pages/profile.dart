import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import 'package:progress_dialog/progress_dialog.dart';

import 'package:sskcovid19/cslib/authenFileProcess.dart';
import 'package:sskcovid19/cslib/profileFileProcess.dart';
import 'package:sskcovid19/pages/operations.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  //Read config file
  AuthenFileProcess authenFileProcess = new AuthenFileProcess();
  ProfileFileProcess profileFileProcess = new ProfileFileProcess();

  //Progress Dialog
  ProgressDialog pr;

  String token;
  Profile profile;
  String profileDisplayName;
  int currentUID;
  bool loadCheck = false;
  String genderValue = "ชาย";

  //Controller
  TextEditingController genderController = new TextEditingController();
  TextEditingController ageController = new TextEditingController();

  TextEditingController nationalityController = new TextEditingController();
  TextEditingController occupationController = new TextEditingController();

  TextEditingController officeAddressController = new TextEditingController();
  TextEditingController officeSubDistrictController = new TextEditingController();
  TextEditingController officeDistrictController = new TextEditingController();
  TextEditingController officeProvinceController = new TextEditingController();
  TextEditingController officePhoneController = new TextEditingController();

  TextEditingController homeAddressController = new TextEditingController();
  TextEditingController homeSubDistrictController = new TextEditingController();
  TextEditingController homeDistrictController = new TextEditingController();
  TextEditingController homeProvinceController = new TextEditingController();
  TextEditingController mobilePhoneController = new TextEditingController();

  initState() {
    super.initState();
  }
  
  Future<String> _getProfile() async {
    //Get user authentication token form auth file
    if (token == null) {
      profileFileProcess.readProfile().then((profileFile){
        final profileJson = json.decode(profileFile);
        print(profileJson);
        setState(() {
          profileDisplayName = profileJson['results'][0]['first_name']+" "+profileJson['results'][0]['last_name'];
          currentUID = profileJson['results'][0]['id'];
        });
      });

      authenFileProcess.readToken().then((val) {
        final jsonToken = json.decode(val);
        setState(() {
          token = jsonToken['token'];
        });
      });
    }

    // If already get Token then get profile from API
    if (token != null && currentUID != null && loadCheck == false) {
      setState(() {
        loadCheck = true;
      });

      var url = "https://ssk-covid19.herokuapp.com/get/myprofile";
      await Http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: "Token $token"},
      ).then((response) {
        final body = utf8.decode(response.bodyBytes);
        final pro = json.decode(body);
        if (pro['count'] != 0) {
          setState(() {
            profile = new Profile(
                currentUID,
                pro['results'][0]['gender'],
                pro['results'][0]['age'],
                pro['results'][0]['nationality'],
                pro['results'][0]['occupation'],
                pro['results'][0]['office_address'],
                pro['results'][0]['office_subdistrict'],
                pro['results'][0]['office_district'],
                pro['results'][0]['office_province'],
                pro['results'][0]['office_phone'],
                pro['results'][0]['home_address'],
                pro['results'][0]['home_subdistrict'],
                pro['results'][0]['home_district'],
                pro['results'][0]['home_province'],
                pro['results'][0]['mobile_phone']
            );

            genderValue = pro['results'][0]['gender'];

          });
        }
        else {
          profile = new Profile(currentUID, "ชาย", 35, "", "", "", "", "", "", "", "", "", "", "", "");
        }
      });
    }

    return token;
  }

  @override
  Widget build(BuildContext context) {

    Color hexToColor(String code) {
      return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    }

    final nationalityField = TextField(
      controller: nationalityController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'สัญญชาติ *',
          hintText: "สัญชาติ",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.nationality = text;
        });
      },
    );

    final occupationField = TextField(
      controller: occupationController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'อาชีพ *',
          hintText: "อาชีพ",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.occupation = text;
        });
      },
    );

    final officeAddressField = TextField(
      controller: officeAddressController,
      obscureText: false,
      style: style,
      maxLines:2,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'ที่อยู่ (ที่ทำงาน) *',
          hintText: "ที่อยู่ (ที่ทำงาน)",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.officeAddress = text;
        });
      },
    );

    final officeSubDistrictField = TextField(
      controller: officeSubDistrictController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'ตำบล (ที่ทำงาน) *',
          hintText: "ตำบล (ที่ทำงาน)",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.officeSubDistrict = text;
        });
      },
    );

    final officeDistrictField = TextField(
      controller: officeDistrictController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'อำเภอ (ที่ทำงาน) *',
          hintText: "อำเภอ (ที่ทำงาน)",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.officeDistrict = text;
        });
      },
    );

    final officeProvinceField = TextField(
      controller: officeProvinceController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'จังหวัด (ที่ทำงาน) *',
          hintText: "จังหวัด (ที่ทำงาน)",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.officeProvince = text;
        });
      },
    );

    final officePhoneField = TextField(
      controller: officePhoneController,
      obscureText: false,
      style: style,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'เบอร์โทร (ที่ทำงาน) *',
          hintText: "เบอร์โทร (ที่ทำงาน)",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.officePhone = text;
        });
      },
    );

    final homeAddressField = TextField(
      controller: homeAddressController,
      obscureText: false,
      style: style,
      maxLines:2,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'ที่อยู่ (บ้าน) *',
          hintText: "ที่อยู่ (บ้าน)",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.homeAddress = text;
        });
      },
    );

    final homeSubDistrictField = TextField(
      controller: homeSubDistrictController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'ตำบล (บ้าน) *',
          hintText: "ตำบล (บ้าน)",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.homeSubDistrict = text;
        });
      },
    );

    final homeDistrictField = TextField(
      controller: homeDistrictController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'อำเภอ (บ้าน) *',
          hintText: "อำเภอ (บ้าน)",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.homeDistrict = text;
        });
      },
    );

    final homeProvinceField = TextField(
      controller: homeProvinceController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'จังหวัด (บ้าน) *',
          hintText: "จังหวัด (บ้าน)",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.homeProvince = text;
        });
      },
    );

    final mobilePhoneField = TextField(
      controller: mobilePhoneController,
      obscureText: false,
      style: style,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'เบอร์โทรศัพย์มือถือ*',
          hintText: "เบอร์โทรศัพย์มือถือ",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.mobilePhone = text;
        });
      },
    );

    final ageField = TextField(
      controller: ageController,
      obscureText: false,
      style: style,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'อายุ*',
          hintText: "อายุ",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (text){
        setState(() {
          profile.age = int.parse(text);
        });
      },
    );

    final genderField = DropdownButton<String>(
      value: genderValue,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          genderValue = newValue;
          profile.gender = newValue;
        });
      },
      items: <String>['ชาย', 'หญิง']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

    final submitButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          submitProfile();
        },
        child: Text("แก้ไขประวัติ",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แก้ไขประวัติสมาชิก',
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: new FutureBuilder(
          future: _getProfile(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              //Set textField initial value
              ageController.text = profile.age.toString();
              genderController.text = profile.gender;

              nationalityController.text = profile.nationality;
              occupationController.text = profile.occupation;

              officeAddressController.text = profile.officeAddress;
              officeSubDistrictController.text = profile.officeSubDistrict;
              officeDistrictController.text = profile.officeDistrict;
              officeProvinceController.text = profile.officeProvince;
              officePhoneController.text = profile.officePhone;

              homeAddressController.text = profile.homeAddress;
              homeSubDistrictController.text = profile.homeSubDistrict;
              homeDistrictController.text = profile.homeDistrict;
              homeProvinceController.text = profile.homeProvince;
              mobilePhoneController.text = profile.mobilePhone;

              return Center(
                child: SingleChildScrollView (
                  padding: const EdgeInsets.all(36.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(profileDisplayName,
                        style: new TextStyle(color: hexToColor("#3371ff"), fontSize: 25.0),),
                      SizedBox(height: 25.0),
                      Text("เพศ"),
                      genderField,
                      SizedBox(height: 25.0),
                      ageField,
                      SizedBox(height: 25.0),
                      nationalityField,
                      SizedBox(height: 25.0),
                      occupationField,

                      SizedBox(height: 25.0),
                      officeAddressField,
                      SizedBox(height: 25.0),
                      officeSubDistrictField,
                      SizedBox(height: 25.0),
                      officeDistrictField,
                      SizedBox(height: 25.0),
                      officeProvinceField,
                      SizedBox(height: 25.0),
                      officePhoneField,

                      SizedBox(height: 25.0),
                      homeAddressField,
                      SizedBox(height: 25.0),
                      homeSubDistrictField,
                      SizedBox(height: 25.0),
                      homeDistrictField,
                      SizedBox(height: 25.0),
                      homeProvinceField,
                      SizedBox(height: 25.0),
                      mobilePhoneField,
                      SizedBox(height: 25.0),
                      submitButton,
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  void submitProfile() {
    pr = new ProgressDialog(context);
    pr.style(
      message: '  Sending Data...',
      progressWidget: CircularProgressIndicator(),
    );

    Map<String, String> data = {
      'account': profile.uid.toString(),
      'gender': profile.gender,
      'age': profile.age.toString(),
      'nationality': profile.nationality,
      'occupation': profile.occupation,
      'office_address': profile.officeAddress,
      'office_subdistrict': profile.officeSubDistrict,
      'office_district': profile.officeDistrict,
      'office_province': profile.officeProvince,
      'office_phone': profile.officePhone,
      'home_address': profile.homeAddress,
      'home_subdistrict': profile.homeSubDistrict,
      'home_district': profile.homeDistrict,
      'home_province': profile.homeProvince,
      'mobile_phone': profile.mobilePhone,
    };

    final test = json.encode(data);
    print(test);

    //Sending Location to API
    pr.show();

    Http.post(
      "https://ssk-covid19.herokuapp.com/post/profile",
      body: data,
      headers: {HttpHeaders.authorizationHeader: "Token $token"},
    ).then((response) {
      final body = utf8.decode(response.bodyBytes);
      final resJson = json.decode(body);
      print(resJson);
      pr.hide();

      if (resJson['status'] == 'success') {
        _showAlertUpdateSuccessed(context);
      } else {
        _showAlertUpdateFail(context);
      }

    });
  }

  void _showAlertUpdateSuccessed(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("แก้ไขข้อมูลแล้ว"),
          content: Text("ประวัติสามาชิกของท่านได้ถูกปรับปรุงให้เป็นปัจจุบันแล้ว"),
          actions: <Widget>[
            FlatButton(
              child: Text('รับทราบ'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OperationPage()),
                );
              },
            )
          ],
        )
    );
  }

  void _showAlertUpdateFail(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("เกิดความผิดพลาด"),
          content: Text("ข้อมูลของคุณถูกยังไม่ถูกบันทึกเข้าระบบ !!"),
          actions: <Widget>[
            FlatButton(
              child: Text('ลองอีกครั้ง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }
}

class Profile {
  final int uid;
  String gender;
  int age;
  String nationality;
  String occupation;
  String officeAddress;
  String officeSubDistrict;
  String officeDistrict;
  String officeProvince;
  String officePhone;
  String homeAddress;
  String homeSubDistrict;
  String homeDistrict;
  String homeProvince;
  String mobilePhone;

  Profile(this.uid, this.gender, this.age, this.nationality, this.occupation, this.officeAddress, this.officeSubDistrict, this.officeDistrict, this.officeProvince, this.officePhone, this.homeAddress, this.homeSubDistrict, this.homeDistrict, this.homeProvince, this.mobilePhone);

}