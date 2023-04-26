import 'package:flutter/material.dart';

import '../Assistants/request_assistant.dart';
import '../Global/map_key.dart';
import '../Models/predicted_places.dart';
import '../Widgets/place_prediction_tile.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {

  List<PredictedPlaces> placesPredictedList = [];

  void findPlaceAutoCompleteSearch(String inputText) async
  {
    if(inputText.length > 1){
      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:US";

      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if(responseAutoCompleteSearch == "Error Occured. Failed. No Response."){
        return;
      }

      //print("this is response/result: ");
      //print(responseAutoCompleteSearch);

      if(responseAutoCompleteSearch["status"] == "OK"){
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placePredictionsList = (placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

        setState(() {
          placesPredictedList = placePredictionsList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: darkTheme ? Colors.amber : Colors.blue,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: darkTheme ? Colors.black : Colors.white,),
        ),
        title: Text("Search & Set dropoff location", style: TextStyle(color: darkTheme ? Colors.black : Colors.white),),
        elevation: 0.0,
      ),
      body: Column(
        children: [
          //search place ui
          Container(
            decoration: BoxDecoration(
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              boxShadow: [
                BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    )
                )
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.adjust_sharp,
                        color: darkTheme ? Colors.black : Colors.white,
                      ),

                      const SizedBox(height: 18.0,),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (valueTyped){
                              findPlaceAutoCompleteSearch(valueTyped);
                            },
                            decoration: InputDecoration(
                              hintText: "search here...",
                              fillColor: darkTheme ? Colors.black : Colors.white54,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: 11.0,
                                top: 8.0,
                                bottom: 8.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),

          ),

          //display place predictions result
          (placesPredictedList.length > 0)
              ? Expanded(
              child: ListView.separated(
                itemCount: placesPredictedList.length,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index){
                  return PlacePredictionTileDesign(
                    predictedPlaces: placesPredictedList[index],
                  );
                },
                separatorBuilder: (BuildContext context, int index){
                  return Divider(
                    height: 0,
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    thickness: 0,
                  );
                },
              ),
          )
              : Container(),
        ],
      ),
    );
  }
}
