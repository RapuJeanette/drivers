import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final emailTextEditingController = TextEditingController();

  final _formKey=GlobalKey<FormState>();

  void _submit(){
    firebaseAuth.sendPasswordResetEmail(email: emailTextEditingController.text.trim()
    ).then((value){
      Fluttertoast.showToast(msg: "Le hemos enviado un correo electronico para recuperar la contraseña, por favor revise su correo electronico");
    }).onError((error, stackTrace){
      Fluttertoast.showToast(msg: "Error ocurrido: \n ${error.toString()}");
    });
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
                Text('Recuperar Contraseña',
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

                          SizedBox(height: 20),

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
                                'Enviar enlace de restablecimiento de contraseña',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              )
                          ),
                          SizedBox(height: 20),

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
                                  Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()));
                                },
                                child: Text(
                                  "Iniciar Sesion",
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
