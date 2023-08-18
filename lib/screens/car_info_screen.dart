import 'package:drivers/global/global.dart';
import 'package:drivers/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {

  final carModelTextEditingController = TextEditingController();
  final carNumberTextEditingController = TextEditingController();
  final carColorTextEditingController = TextEditingController();
  final carAnhoTextEditingController= TextEditingController();
  final carCapacidadTextEditingController= TextEditingController();
  final carEspecialTextEditingController= TextEditingController();

  final _formKey = GlobalKey<FormState>();

  _submit(){
    if(_formKey.currentState!.validate()){
      Map driverCarInfoMap={
        "car_model" : carModelTextEditingController.text.trim(),
        "car_number": carNumberTextEditingController.text.trim(),
        "car_color" : carColorTextEditingController.text.trim(),
        "car_anho"  : carAnhoTextEditingController.text.trim(),
        "car_capacidad": carCapacidadTextEditingController.text.trim(),
        "car_especial": carEspecialTextEditingController.text.trim(),
      };

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");
      userRef.child(currentUser!.uid).child("car_details").set(driverCarInfoMap);

      Fluttertoast.showToast(msg: "Los detalles del auto se guardó correctamente");
      Navigator.push(context, MaterialPageRoute(builder: (c)=>SplashScreen()));
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
              children: [
                  Image.asset(darkTheme? "images/city.jpg" : "images/city_d.jpg"),

                SizedBox(height: 20,),

                Text("Agregar detalles del Auto",
                  style: TextStyle(
                    color: darkTheme? Colors.amber.shade300 : Colors.blue,
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
                              hintText: "Modelo del Auto",
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
                                return "Modelo no puede estar vacio";
                              }
                              if(text.length <2){
                                return "Porfavor ingresa un Modelo valido";
                              }
                              if(text.length >49){
                                return "Modelo no puede tener mas de 50 caracteres";
                              }
                            },
                            onChanged: (text)=> setState(() {
                              carModelTextEditingController.text=text;
                            }),
                          ),

                          SizedBox(height: 10),

                          TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50)
                            ],
                            decoration: InputDecoration(
                              hintText: "Placa del Auto",
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
                              prefixIcon: Icon(Icons.confirmation_number_outlined, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text){
                              if(text==null || text.isEmpty){
                                return "Placa no puede estar vacio";
                              }
                              if(text.length <2){
                                return "Porfavor ingresa una Placa valida";
                              }
                              if(text.length >49){
                                return "Placa no puede tener mas de 50 caracteres";
                              }
                            },
                            onChanged: (text)=> setState(() {
                              carNumberTextEditingController.text=text;
                            }),
                          ),

                          SizedBox(height: 10),

                          TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50)
                            ],
                            decoration: InputDecoration(
                              hintText: "Color del Auto",
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
                              prefixIcon: Icon(Icons.color_lens, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text){
                              if(text==null || text.isEmpty){
                                return "Color no puede estar vacio";
                              }
                              if(text.length <2){
                                return "Porfavor ingresa un color valido";
                              }
                              if(text.length >49){
                                return "Color no puede tener mas de 50 caracteres";
                              }
                            },
                            onChanged: (text)=> setState(() {
                              carColorTextEditingController.text=text;
                            }),
                          ),

                          SizedBox(height: 10,),

                          TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50)
                            ],
                            decoration: InputDecoration(
                              hintText: "Año del Auto",
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
                              prefixIcon: Icon(Icons.numbers, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text){
                              if(text==null || text.isEmpty){
                                return "Año no puede estar vacio";
                              }
                              if(text.length <2){
                                return "Porfavor ingresa un año valido";
                              }
                              if(text.length >4){
                                return "Año no puede tener mas de 4 caracteres";
                              }
                            },
                            onChanged: (text)=> setState(() {
                              carAnhoTextEditingController.text=text;
                            }),
                          ),

                          SizedBox(height: 10,),

                          TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50)
                            ],
                            decoration: InputDecoration(
                              hintText: "Capacidad del Auto",
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
                              prefixIcon: Icon(Icons.person_4, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text){
                              if(text==null || text.isEmpty){
                                return "Capacidad no puede estar vacio";
                              }
                              if(text.length <2){
                                return "Porfavor ingresa una capacidad valida";
                              }
                              if(text.length >49){
                                return "Capacidad no puede tener mas de 50 caracteres";
                              }
                            },
                            onChanged: (text)=> setState(() {
                              carCapacidadTextEditingController.text=text;
                            }),
                          ),

                          SizedBox(height: 10,),

                          TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50)
                            ],
                            decoration: InputDecoration(
                              hintText: "Caracteristicas Especiales del Auto",
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
                              prefixIcon: Icon(Icons.queue_rounded, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text){
                              if(text==null || text.isEmpty){
                                return "Caracteristicas no puede estar vacio";
                              }
                              if(text.length <2){
                                return "Porfavor ingresa una caracteristica valida";
                              }
                              if(text.length >49){
                                return "Caracteristica no puede tener mas de 50 caracteres";
                              }
                            },
                            onChanged: (text)=> setState(() {
                              carEspecialTextEditingController.text=text;
                            }),
                          ),

                          SizedBox(height: 10,),

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
                                'Confirmar',
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
                              Text("Ya tiene una cuenta?",
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
            )
          ],
        ),
      ),
    );
  }
}
