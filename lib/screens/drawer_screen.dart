import 'package:drivers/screens/profile_screen.dart';
import 'package:flutter/material.dart';


import '../global/global.dart';
import '../splashScreen/splash_screen.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {

    bool darkTheme=MediaQuery.of(context).platformBrightness==Brightness.dark;

    return Container(
      width: 220,
      child: Drawer(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 50, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 20,),

                  Text(
                   userModelCurrentInfo!.name!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,

                    ),
                  ),

                  SizedBox(height: 10,),

                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (c)=>ProfileScreen()));
                    } ,
                    child: Text(
                      "Editar Perfil",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  SizedBox(height: 30,),

                  Text("Tus viajes", style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: 15,),

                  Text("Pagos", style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: 15,),

                  Text("Notificacion", style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: 15,),

                  Text("Ayuda", style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: 15,),
                ],
              ),

              GestureDetector(
                onTap: (){
                  firebaseAuth.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>SplashScreen()));
                },
                child: Text(
                  "Cerrar Sesion",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
