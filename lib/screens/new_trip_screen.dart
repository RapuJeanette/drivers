import 'dart:async';

import 'package:drivers/Assistants/assistant_methods.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/models/user_ride_request_information.dart';
import 'package:drivers/splashScreen/splash_screen.dart';
import 'package:drivers/widgets/fare_amount_collection_dialog.dart';
import 'package:drivers/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewTripScreen extends StatefulWidget {

  UserRideRequestInformation? userRideRequestDetails;
  NewTripScreen({
    this.userRideRequestDetails,
  });

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newTripGoogleMap;

  static const CameraPosition _santaCruz = CameraPosition(
    target: LatLng(-17.7864704, -63.193088),
    zoom: 14.0,
  );

  String? buttonTitle="Llegó";
  Color? buttonColor= Colors.green;

  Set<Marker> setOfMarkers= Set<Marker>();
  Set<Circle> setOfCircle= Set<Circle>();
  Set<Polyline> setOfPolyline= Set<Polyline>();
  List<LatLng> pLineCoordinatedList=[];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding=0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus="aceptar";

  String durationFromOriginToDestination="";

  bool isRequestDirectionDetails=false;

  Future<void> drawPolyLineFromOriginToDestination(LatLng originLatLng, LatLng destinationLatLng, bool darkTheme) async{
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Espere por favor...",),
    );

    var directionDetailsInfo= await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList= pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoordinatedList.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty){
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatedList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline= Polyline(
        color: darkTheme? Colors.amber.shade300 : Colors.blue,
          polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMap!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker= Marker(
      markerId: MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker= Marker(
      markerId: MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle=Circle(circleId: CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle=Circle(circleId: CircleId("destinationID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    saveAssignedDriverDetailsToUserRideRequest();
  }

  getDriverLocationUpdatesAtRealTime(){

    LatLng oldLatLng= LatLng(0, 0);

    streamSubscriptionDriverLivePosition = Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;
      
      LatLng latLngLiveDriverPosition = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);

      Marker animatingMarker= Marker(markerId: MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: InfoWindow(title: "Esta es su posición"),
      );
      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: latLngLiveDriverPosition, zoom: 18);
        newTripGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere((element) => element.markerId.value=="AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng= latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();
    });
    
    Map driverLatLngDataMap={
      "latitude": onlineDriverCurrentPosition!.latitude.toString(),
      "longitufe": onlineDriverCurrentPosition!.longitude.toString(),
    };
    FirebaseDatabase.instance.ref().child("Todo lo requerido").child(widget.userRideRequestDetails!.rideRequestId!).child("driverLocation").set(driverLatLngDataMap);
  }

  updateDurationTimeAtRealTime() async{
    if(isRequestDirectionDetails == false){
      isRequestDirectionDetails=true;

      if(onlineDriverCurrentPosition==null){
        return;
      }

      var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);

      var destinationLatLng;

      if(rideRequestStatus=="aceptado"){
        destinationLatLng= widget.userRideRequestDetails!.originLatLng;
      }
      else {
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng;
      }

      var directionInformation= await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

      if(directionInformation!=null){
        setState(() {
          durationFromOriginToDestination= directionInformation.duration_text!;
        });
      }
      isRequestDirectionDetails=false;
    }

  }

  createDriverIconMarker(){
    if(iconAnimatedMarker==null){
      ImageConfiguration imageConfiguration= createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/").then((value){
        iconAnimatedMarker=value;
      });
    }
  }

  saveAssignedDriverDetailsToUserRideRequest(){
    DatabaseReference databaseReference= FirebaseDatabase.instance.ref().child("Todos los viajes").child(widget.userRideRequestDetails!.rideRequestId!);
    Map driverLocationDataMap={
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };
    if(databaseReference.child("driverId")!="esperando"){
      databaseReference.child("driverLocation").set(driverLocationDataMap);
      databaseReference.child("status").set("aceptado");
      databaseReference.child("driverId").set(onlineDriverData.id);
      databaseReference.child("driverName").set(onlineDriverData.name);
      databaseReference.child("driverPhone").set(onlineDriverData.phone);
      databaseReference.child("raitings").set(onlineDriverData.ratings);
      databaseReference.child("car_details").set(onlineDriverData.car_model.toString()+" "+ onlineDriverData.car_number.toString()+ "(" + onlineDriverData.car_color.toString()+")");
      
      saveRideRequestIdToDriverHistory();
    }
    else {
      Fluttertoast.showToast(msg: "Este viaje ya fue aceptado por otro conductor. \n Recargar la App");
      Navigator.push(context, MaterialPageRoute(builder: (c)=>SplashScreen()));
    }
  }

  saveRideRequestIdToDriverHistory(){
    DatabaseReference tripsHistoryRef = FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("tripsHistory");
    tripsHistoryRef.child(widget.userRideRequestDetails!.rideRequestId!).set(true);
  }

  endTripNow() async{
    showDialog(context: context, 
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(message: "Por favor espere...",)
    );
    
    var currentDriverPositionLatLng= LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
    
    var tripDirectionDetails= await AssistantMethods.obtainOriginToDestinationDirectionDetails(currentDriverPositionLatLng, widget.userRideRequestDetails!.originLatLng!);
    
    double totalFareAmount= AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails);
    
    FirebaseDatabase.instance.ref().child("Todos los viajes requeridos").child(widget.userRideRequestDetails!.rideRequestId!).child("fareAmount").set(totalFareAmount.toString());

    FirebaseDatabase.instance.ref().child("Todos los viajes requeridos").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set("ended");

    Navigator.pop(context);

    showDialog(context: context,
        builder: (BuildContext context)=> FareAmountCollectionDialog(
          totalFareAmount: totalFareAmount,
        )
    );
    saveFareAmountToDriverEarnings(totalFareAmount);
  }

  saveFareAmountToDriverEarnings(double totalFareAmount){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid!).child("earnings").once().then((snap){
      if(snap.snapshot.value!=null){
        double oldEarning = double.parse(snap.snapshot.value.toString());
        double driverTotalEarning= totalFareAmount + oldEarning;

        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid!).child("earnings").set(driverTotalEarning.toString());
      } else {
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid!).child("earnings").set(totalFareAmount.toString());
        }
    });
  }
  
  @override
  Widget build(BuildContext context) {

    createDriverIconMarker();

    bool darkTheme = MediaQuery.of(context).platformBrightness==Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _santaCruz,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newTripGoogleMap= controller;

              setState(() {
                mapPadding=350;
              });

              var driverCurrentLatLng= LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

              var userPickUpLatLng= widget.userRideRequestDetails!.originLatLng;

              drawPolyLineFromOriginToDestination(driverCurrentLatLng,userPickUpLatLng!,darkTheme);

              getDriverLocationUpdatesAtRealTime();
            },
          ),

          Positioned(
            bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                  padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: darkTheme? Colors.black :  Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 18,
                        spreadRadius: 0.5,
                        offset: Offset(0.6, 0.6),
                      )
                    ]
                  ),
                  child: Padding(padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(durationFromOriginToDestination,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                              color: darkTheme? Colors.amber.shade300 :  Colors.black,
                          ),
                        ),

                        SizedBox(height: 10,),

                        Divider(thickness: 1, color: darkTheme? Colors.amber.shade300 :  Colors.grey,),

                        SizedBox(height: 10,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.userRideRequestDetails!.userName!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: darkTheme? Colors.amber.shade300 :  Colors.black,
                              ),
                            ),

                            IconButton(
                                onPressed: (){},
                                icon: Icon(Icons.phone,
                                  color: darkTheme? Colors.amber.shade300 :  Colors.black,
                                ),
                            )
                          ],
                        ),

                        SizedBox(height: 10,),

                        Row(
                          children: [
                            Image.asset("images/",
                              width: 30,
                              height: 30,
                            ),

                            SizedBox(width: 10,),

                            Expanded(child:
                                Container(
                                  child: Text(
                                    widget.userRideRequestDetails!.originAddress!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: darkTheme? Colors.amber.shade300 :  Colors.black,
                                    ),
                                  ),
                                )
                            )
                          ],
                        ),

                        SizedBox(height: 10,),

                        Row(
                          children: [
                            Image.asset("images/",
                              width: 30,
                              height: 30,
                            ),

                            SizedBox(width: 10,),

                            Expanded(child:
                            Container(
                              child: Text(
                                widget.userRideRequestDetails!.destinationAddress!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: darkTheme? Colors.amber.shade300 :  Colors.black,
                                ),
                              ),
                            )
                            )
                          ],
                        ),

                        SizedBox(height: 10,),

                        Divider(thickness: 1, color: darkTheme? Colors.amber.shade300 :  Colors.grey,),

                        SizedBox(height: 10,),

                        ElevatedButton.icon(
                            onPressed:() async {
                              if(rideRequestStatus=="aceptado"){
                                rideRequestStatus="llegó";
                                
                                FirebaseDatabase.instance.ref().child("Todos los viajes requerido").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set(rideRequestStatus);

                                setState(() {
                                  buttonTitle="En marcha";
                                  buttonColor=Colors.lightGreen;
                                });

                                showDialog(context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context)=>ProgressDialog(message: "Cargando...",)
                                );

                                await drawPolyLineFromOriginToDestination(
                                widget.userRideRequestDetails!.originLatLng!,
                                widget.userRideRequestDetails!.destinationLatLng!,
                                darkTheme
                                );

                                Navigator.pop(context);
                              }

                              else if (rideRequestStatus=="llegó"){
                                rideRequestStatus=="viaje terminado";
                                FirebaseDatabase.instance.ref().child("Todos los viajes requerido").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set(rideRequestStatus);

                                setState(() {
                                  buttonTitle="Viaje Terminado";
                                  buttonColor=Colors.red;
                                });
                              }

                              else if(rideRequestStatus=="en marcha"){
                                endTripNow();
                              }
                            } ,
                            icon: Icon(Icons.directions_car,color: darkTheme? Colors.amber.shade300 :  Colors.black,),
                            label: Text(
                              buttonTitle!,
                              style: TextStyle(
                                color: darkTheme? Colors.black :  Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                ),
              )
          )
        ],
      ),
    );
  }
}
