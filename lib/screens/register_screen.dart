import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../global/global.dart';
import 'car_info_screen.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}): super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nameTextEditingController = TextEditingController();
  final registerTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final numberTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmTextEditingController = TextEditingController();

  bool _passwordVisible=false;

  final _formKey=GlobalKey<FormState>();

  void _submit() async{
    if(_formKey.currentState!.validate()) {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
      ).then((auth) async {
        currentUser=auth.user;

        if(currentUser!=null){
          Map userMap={
            "id": currentUser!.uid,
            "name": nameTextEditingController.text.trim(),
            "email": emailTextEditingController.text.trim(),
            "number":numberTextEditingController.text.trim(),
          };

          DatabaseReference userRef= FirebaseDatabase.instance.ref().child("drivers");
          userRef.child(currentUser!.uid).set(userMap);
        }
        await Fluttertoast.showToast(msg: "Registro exitoso");
        Navigator.push(context, MaterialPageRoute(builder: (c)=>CarInfoScreen()));
      }).catchError((errorMessage){
        Fluttertoast.showToast(msg: "Error ocurrido:\n $errorMessage");
      });
    }
    else {
      Fluttertoast.showToast(msg: "No todos los campos son validos");
    }
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme=MediaQuery.of(context).platformBrightness==Brightness.dark;

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children:[
                Image.asset(darkTheme ? 'images/city.jpg': 'images/city_d.jpg'),
                SizedBox(height: 20,),
                Text('Registro de Usuario',
                  style: TextStyle(
                    color: darkTheme? Colors.amber.shade400: Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Padding(padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(key: _formKey, child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: "Nombre",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              )
                            ),
                            prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text==null || text.isEmpty){
                              return "Nombre no puede estar vacio";
                            }
                            if(text.length <2){
                              return "Porfavor ingresa un nombre valido";
                            }
                            if(text.length >49){
                              return "Nombre no puede tener mas de 50 caracteres";
                            }
                          },
                          onChanged: (text)=> setState(() {
                            nameTextEditingController.text=text;
                          }),
                        ),
                        SizedBox(height: 10),

                        TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(100)
                          ],
                          decoration: InputDecoration(
                            hintText: "Email",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45: Colors.grey.shade200,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )
                            ),
                            prefixIcon: Icon(Icons.email, color: darkTheme ? Colors.amber.shade400 : Colors.grey,) ,
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text==null || text.isEmpty){
                              return "Email no puede estar vacio";
                            }
                            if(EmailValidator.validate(text)==true){
                              return null;
                            }
                            if(text.length <2){
                              return "Porfavor ingresa un email valido";
                            }
                            if(text.length >99){
                              return "Email no puede tener mas de 100 caracteres";
                            }
                          },
                          onChanged: (text)=> setState(() {
                            emailTextEditingController.text=text;
                          }),
                        ),
                        SizedBox(height: 10),

                        IntlPhoneField(
                          showCountryFlag: false,
                          dropdownIcon: Icon(
                            Icons.arrow_drop_down,
                            color: darkTheme? Colors.amber.shade400: Colors.grey,
                          ),
                          decoration: InputDecoration(
                            hintText: "Phone",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45: Colors.grey.shade200,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )
                            ),
                          ),
                          initialCountryCode: 'BO',
                          onChanged: (text)=> setState(() {
                            numberTextEditingController.text=text.completeNumber;
                          }),
                        ),
                        SizedBox(height: 10),

                        TextFormField(
                          obscureText: !_passwordVisible,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: darkTheme ? Colors.black45: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  )
                              ),
                              prefixIcon: Icon(Icons.password, color: darkTheme ? Colors.amber.shade400 : Colors.grey,) ,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible? Icons.visibility: Icons.visibility_off,
                                  color: darkTheme? Colors.amber.shade400: Colors.grey,
                                ),
                                onPressed: (){
                                  setState(() {
                                    _passwordVisible=!_passwordVisible;
                                  });
                                },
                              )
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text==null || text.isEmpty){
                              return "Contraseña no puede estar vacio";
                            }
                            if(text.length <6){
                              return "Porfavor ingresa una contraseña valida";
                            }
                            if(text.length >49){
                              return "Contraseña no puede tener mas de 50 caracteres";
                            }
                            return null;
                          },
                          onChanged: (text)=>setState(() {
                            passwordTextEditingController.text=text;
                          }),
                        ),
                        SizedBox(height: 10),

                        TextFormField(
                          obscureText: !_passwordVisible,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                              hintText: "Confirm Password",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: darkTheme ? Colors.black45: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  )
                              ),
                              prefixIcon: Icon(Icons.password, color: darkTheme ? Colors.amber.shade400 : Colors.grey,) ,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible? Icons.visibility: Icons.visibility_off,
                                  color: darkTheme? Colors.amber.shade400: Colors.grey,
                                ),
                                onPressed: (){
                                  setState(() {
                                    _passwordVisible=!_passwordVisible;
                                  });
                                },
                              )
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text==null || text.isEmpty){
                              return "Contraseña Confirmada no puede estar vacio";
                            }
                            if(text!= passwordTextEditingController.text){
                              return "Contraseña no coincide";
                            }
                            if(text.length <6){
                              return "Porfavor ingresa una contraseña valida";
                            }
                            if(text.length >49){
                              return "Contraseña no puede tener mas de 50 caracteres";
                            }
                            return null;
                          },
                          onChanged: (text) => setState(() {
                            confirmTextEditingController.text=text;
                          }),
                        ),
                        SizedBox(height: 10),

                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: darkTheme? Colors.amber.shade400: Colors.blue,
                              onPrimary: darkTheme? Colors.black: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            onPressed: (){
                              _submit();
                            },
                            child: Text(
                              'Registrar',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            )
                        ),
                        SizedBox(height: 10),

                        GestureDetector(
                          onTap: (){},
                          child: Text(
                            'Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: darkTheme? Colors.amber.shade400: Colors.blue,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Ya tienes una cuenta?",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                            ),

                            SizedBox(width: 5,),

                            SizedBox(width: 5,),

                            GestureDetector(
                              onTap: (){
                              },
                              child: Text(
                                "Ingresar",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: darkTheme?Colors.amber.shade400: Colors.blue,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ))
                  ],
                ),)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
