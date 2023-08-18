import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers/Assistants/assistant_methods.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screens/new_trip_screen.dart';

class NotificacionDialogBox extends StatefulWidget {

  UserRideRequestInformation? userRideRequestDetails;

  NotificacionDialogBox({this.userRideRequestDetails});

  @override
  State<NotificacionDialogBox> createState() => _NotificacionDialogBoxState();
}

class _NotificacionDialogBoxState extends State<NotificacionDialogBox> {
  @override
  Widget build(BuildContext context) {

    bool darkTheme=MediaQuery.of(context).platformBrightness==Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: darkTheme? Colors.black : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              onlineDriverData.car_type=="Car"? "images/Car.png" :
              onlineDriverData.car_type=="CNG"? "images/Car.png" :
              "images/Car.png",
            ),

            SizedBox(height: 20,),
            
            Text("Nueva solicitud de viaje",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: darkTheme? Colors.amber.shade300 : Colors.blue,
              ),
            ),

            SizedBox(height: 20,),
            
            Divider(
              height: 2,
              thickness: 2,
              color: darkTheme? Colors.amber.shade300 : Colors.blue ,
            ),
            
            Padding(padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset("images/gps.png",
                        width: 30,
                        height: 30,
                      ),

                      SizedBox(height: 10,),

                      Expanded(child: Container(
                        child: Text(
                          widget.userRideRequestDetails!.originAddress!,
                          style: TextStyle(
                            fontSize: 16,
                            color: darkTheme? Colors.amber.shade300 : Colors.blue,
                          ),
                        ),
                       ),
                      )
                    ],
                  ),

                  SizedBox(height: 20,),

                  Row(
                    children: [
                      Image.asset("",
                        width: 30,
                        height: 30,
                      ),

                      SizedBox(height: 10,),

                      Expanded(child: Container(
                        child: Text(
                          widget.userRideRequestDetails!.destinationAddress!,
                          style: TextStyle(
                            fontSize: 16,
                            color: darkTheme? Colors.amber.shade300 : Colors.blue,
                          ),
                        ),
                      ),
                      )
                    ],
                  )
                ],
              ),
            ),

            Divider(
              height: 2,
              thickness: 2,
              color: darkTheme? Colors.amber.shade300 : Colors.blue,
            ),

            Padding(padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: (){
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer=AssetsAudioPlayer();

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      child: Text(
                        "Cancel".toUpperCase(),
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      )
                  ),

                  SizedBox(height: 20,),

                  ElevatedButton(
                      onPressed: (){
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer=AssetsAudioPlayer();

                        acceptRideRequest(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                      child: Text(
                        "Aceptado".toUpperCase(),
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      )
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("newRideStatus").once().then((snap){
      if(snap.snapshot.value=="idle"){
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("newRideStatus").set("aceptado");
        AssistantMethods.pauseLiveLocationUpdates();

        Navigator.push(context, MaterialPageRoute(builder: (c)=>NewTripScreen(
          userRideRequestDetails: widget.userRideRequestDetails,
        )));
      }
      else{
        Fluttertoast.showToast(msg: "Esta solicitud de viaje no existe");
      //  Navigator.pop(context);
      }
    });
  }
}
