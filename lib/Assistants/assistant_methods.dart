import 'package:drivers/Assistants/request_assistant.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/direction_details_info.dart';
import '../models/directions.dart';
import '../models/user_model.dart';

class AssistantMethods{
  static void readCurrentOnlineUserInfo() async {
    currentUser= firebaseAuth.currentUser;
    DatabaseReference userRef= FirebaseDatabase.instance
    .ref()
    .child("users")
    .child(currentUser!.uid);

    userRef.once().then((snap){
      if(snap.snapshot.value!=null){
        userModelCurrentInfo= UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async {

    String apiUrl= "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress="";

    var requestReponse= await RequestAssistant.receiveRequest(apiUrl);

    if(requestReponse!="Error Ocurrido. Fallo! No responde"){
      humanReadableAddress=requestReponse["results"][0]["formatted_address"];

      Directions userPickUpAddress= Directions();
      userPickUpAddress.locationLatitude=position.latitude;
      userPickUpAddress.locationLongitude=position.longitude;
      userPickUpAddress.locationName=humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async{

    String urlOriginToDestinationDirectionDetails= "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi= await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

   // if(responseDirectionApi == "Error ocurrido.  No responde"){
     // return ;
  //  }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points= responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text= responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value= responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text= responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value= responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];


    return directionDetailsInfo;
  }

  static pauseLiveLocationUpdates(){
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){
    double timeTravelledFareAmountPerMinute= (directionDetailsInfo.duration_value!/100)*0.1;
    double distanceTravelledFareAmountPerKilometer=(directionDetailsInfo.duration_value!/1000)*0.1;

    double totalFareAmount= timeTravelledFareAmountPerMinute + distanceTravelledFareAmountPerKilometer;
    double localCurrencyTotalFare= totalFareAmount*107;

    if(driverCurrentPosition=="Car"){
      double resultFareAmount=((localCurrencyTotalFare.truncate())*2);
      resultFareAmount;
    } else {
      return localCurrencyTotalFare.truncate().toDouble();
    }
    return localCurrencyTotalFare.truncate().toDouble();
  }
}