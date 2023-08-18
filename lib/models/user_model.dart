import 'package:firebase_database/firebase_database.dart';

class UserModel{
  String? number;
  String? name;
  String? id;
  String? email;

  UserModel({
    this.name,
    this.number,
    this.email,
    this.id,
  });

  UserModel.fromSnapshot(DataSnapshot snap){
    number = (snap.value as dynamic)["number"];
    name = (snap.value as dynamic)["name"];
    id= snap.key;
    email = (snap.value as dynamic)["email"];
  }
}