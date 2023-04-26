import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users/Widgets/progress_dialog.dart';
import 'package:users/assistants/request_assistant.dart';
import 'package:users/Global/global.dart';
import 'package:users/InfoHandler/app_info.dart';
import 'package:users/Models/directions.dart';
import 'package:users/Models/predicted_places.dart';

import '../Global/map_key.dart';

class PlacePredictionTileDesign extends StatefulWidget {
  
  final PredictedPlaces? predictedPlaces;
  
  PlacePredictionTileDesign({this.predictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() => _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
          message: "Setting up Drop-off. Please wait....",
        ),
    );

    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);

    if(responseApi == "Error Occured. Failed. No Response."){
      return;
    }

    if(responseApi["status"] == "OK"){
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];

      print("Directions: " + directions.locationLatitude.toString());
      print("Directions: " + directions.locationLongitude.toString());

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);

      setState((){
        userDropOffAddress = directions.locationName!;
        //print("User DropOff Address: " + userDropOffAddress);
      });

      Navigator.pop(context, "obtainedDropoff");

      // print("location name = " + directions.locationName!);
      // print("\nlocation lat = " + directions.locationLatitude!.toString());
      // print("\nlocation lng = " + directions.locationLongitude!.toString());
    }
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return ElevatedButton(
        onPressed: (){
          getPlaceDirectionDetails(widget.predictedPlaces!.place_id, context);
        },
        style: ElevatedButton.styleFrom(
          primary: darkTheme ? Colors.black : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.add_location,
                color:  darkTheme ? Colors.amber : Colors.blue,
              ),

              const SizedBox(width: 10.0,),

              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.predictedPlaces!.main_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: darkTheme ? Colors.amber : Colors.blue,
                        ),
                      ),


                      Text(
                        widget.predictedPlaces!.secondary_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: darkTheme ? Colors.amber.shade100 : Colors.blue.shade400,
                        ),
                      ),

                    ],
                  ),
              ),
            ],
          ),
        ),
    );
  }
}
