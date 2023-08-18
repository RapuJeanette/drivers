import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  
  DatabaseReference userRef= FirebaseDatabase.instance.ref().child("users");

  Future<void> showUserNameDialogAlert(BuildContext context, String name){

    nameTextEditingController.text = name;

    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Actualizar"),
            content: SingleChildScrollView(
             child: Column(
               children: [
                 TextFormField(
                   controller: nameTextEditingController,
                 )
               ],
             ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar", style: TextStyle(color: Colors.red),),
              ),
              TextButton(
                  onPressed: (){
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "name": nameTextEditingController.text.trim(),
                    }).then((value){
                      nameTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Actualizado con exito. \n Recarga la App para ver los cambios");
                    }).catchError((errorMessage){
                      Fluttertoast.showToast(msg: "Error ocurrido. \n $errorMessage");
                    });
                    Navigator.pop(context);
                  },
                  child: Text("OK", style: TextStyle(color: Colors.black),),
              )
            ],
          );
        }
    );
  }

  Future<void> showUserPhoneDialogAlert(BuildContext context, String phone){

    phoneTextEditingController.text = phone;

    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Actualizar"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: phoneTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Cancelar", style: TextStyle(color: Colors.red),),
              ),
              TextButton(
                onPressed: (){
                  userRef.child(firebaseAuth.currentUser!.uid).update({
                    "number": phoneTextEditingController.text.trim(),
                  }).then((value){
                    phoneTextEditingController.clear();
                    Fluttertoast.showToast(msg: "Actualizado con exito. \n Recarga la App para ver los cambios");
                  }).catchError((errorMessage){
                    Fluttertoast.showToast(msg: "Error ocurrido. \n $errorMessage");
                  });
                  Navigator.pop(context);
                },
                child: Text("OK", style: TextStyle(color: Colors.black),),
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
          ),
          title: Text("Perfil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Center(
          child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.white,),
                ),

                SizedBox(height: 30,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${userModelCurrentInfo!.name!}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton(
                        onPressed: (){
                          showUserNameDialogAlert(context, userModelCurrentInfo!.name!);
                        },
                        icon: Icon(
                          Icons.edit,
                        )
                    )
                  ],
                ),

                Divider(
                  thickness: 1,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${userModelCurrentInfo!.number!}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton(
                        onPressed: (){
                          showUserPhoneDialogAlert(context, userModelCurrentInfo!.number!);
                        },
                        icon: Icon(
                          Icons.edit,
                        )
                    )
                  ],
                ),

                Divider(
                  thickness: 1,
                ),

                Text("${userModelCurrentInfo!.email!}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

