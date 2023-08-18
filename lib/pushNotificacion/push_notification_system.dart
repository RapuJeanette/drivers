import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'notificacion_dialog_box.dart';

class PushNotificationSystem{
  FirebaseMessaging messaging= FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async{
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage){
      if(remoteMessage!=null){
        readUserRideRequestInformation(remoteMessage.data["rideRequestId"],context);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
    });
  }
  readUserRideRequestInformation(String userRideRequestId, BuildContext context){
    FirebaseDatabase.instance.ref().child("Todos los viajes requeridos").child(userRideRequestId).child("driverId").onValue.listen((event) {
      if(event.snapshot.value=="esperando"|| event.snapshot.value== firebaseAuth.currentUser!.uid){
        FirebaseDatabase.instance.ref().child("Todos los viajes requeridos").child(userRideRequestId).once().then((snapData){
          if(snapData.snapshot.value!=null){
            audioPlayer.open(Audio("music/music_notification.mp3"));
            audioPlayer.play();

            double originLat=double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"]);
            double originLng=double.parse((snapData.snapshot.value! as Map)["origin"]["longitude"]);
            String originAddress=(snapData.snapshot.value! as Map)["originAddress"];

            double destinationLat=double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"]);
            double destinationLng=double.parse((snapData.snapshot.value! as Map)["destination"]["longitude"]);
            String destinationAddress=(snapData.snapshot.value! as Map)["destinationAddress"];

            String userName=(snapData.snapshot.value! as Map)["userName"];
            String userPhone=(snapData.snapshot.value! as Map)["userPhone"];

            String? rideRequestId = snapData.snapshot.key;

            UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();
            userRideRequestDetails.originLatLng=LatLng(originLat, originLng);
            userRideRequestDetails.originAddress= originAddress;
            userRideRequestDetails.destinationLatLng=LatLng(destinationLat, destinationLng);
            userRideRequestDetails.userName=userName;
            userRideRequestDetails.userPhone=userPhone;

            userRideRequestDetails.rideRequestId=rideRequestId;
            
            showDialog(context: context, 
                builder: (BuildContext context)=>NotificacionDialogBox(
                  userRideRequestDetails: userRideRequestDetails,
                ),
            );
          }
          else{
            Fluttertoast.showToast(msg: "Este ID de solicitud de viaje no existe");
          }
        });
      }
      else{
        Fluttertoast.showToast(msg: "Este ID de solicitud de viaje fue cancelado");
        Navigator.pop(context);
      }
    });
  }

  Future generateAndGetToken() async{
    String? registrationToken = await messaging.getToken();
    print("FCM registrar Token: ${registrationToken}");

    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("token").set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}