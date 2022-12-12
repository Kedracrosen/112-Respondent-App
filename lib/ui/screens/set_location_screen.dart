import 'dart:math';

import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
class SetLocationScreen extends StatefulWidget {
  @override
  _SetLocationScreenState createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  GooglePlace? googlePlace;
  List<AutocompletePrediction>? predictions = [];
  String apiKey='AIzaSyAwwrkJziaO69a2nAXSo18fEn8z-Gofw80';
  TextEditingController _locationController= TextEditingController();

  @override
  void initState() {
    super.initState ();


    googlePlace = GooglePlace(apiKey);
  }

  void autoCompleteSearch(String value) async {
    print('autoCompletcalled');

    var result = await googlePlace!.autocomplete.get(value);
    print('result' + result!.status.toString());
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result!.predictions!;
      });
    }
  }

  void getCordFromLocation(query,place_id) async{
    // From a query
    print("${query} : some query");
    googlePlace!.details!.get(place_id);
    var addresses = await Geocoder.local.findAddressesFromQuery(query);
    var first = addresses.first;
    print("${first.featureName} : ${first.coordinates}");
    Navigator.of(context).pop({'address': first.addressLine,'long':first.coordinates.longitude,'lat':first.coordinates.latitude});
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold (
        backgroundColor: Colors.white,
        appBar: AppBar (
          backgroundColor: Colors.white,
          elevation: 10,
          centerTitle: false,
          title: Text ( "Enter your location",
              style: TextStyle ( fontSize: 18,
                  color: Colors.black38,
                  fontWeight: FontWeight.bold ) ),
          leading: InkWell (
            onTap: (
                ) {
              Navigator.pop ( context );
            },
            child: Container (
              alignment: Alignment.center,
              child: Icon(Icons.arrow_back_ios,color: Colors.black38,)),
          ),
          bottom:PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(

              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:8.0),
                    child: Icon(Icons.add_location,color:AppColors.red,size:40),
                  ),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),

                        color: Colors.grey[100],

                      ),
                      margin: EdgeInsets.only(right: 20,bottom: 5),
                      padding: EdgeInsets.only(left: 20),

                      child: TextField (
                        controller: _locationController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration (
                            counterText: "",
                            border: InputBorder.none,
                            suffixIcon: Icon ( Icons.search, size: 20,color: Colors.grey, ),
                            hintText: 'Search here',
                            hintStyle: TextStyle (
                                color: Colors.grey, fontSize: 17 )
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            autoCompleteSearch(value);
                          } else {
                            if (predictions!.isNotEmpty && mounted) {
                              setState(() {
                                predictions = [];
                              });
                            }
                          }
                        },

                      ),
                    ),
                  ),
                ],
              ),
            ),
          ) ,
        ),
        body:
        Padding (
          padding: const EdgeInsets.fromLTRB( 10.0, 25.0, 25.0, 10.0 ),
          child: Column (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: predictions!.length,
                  itemBuilder: (context, index) {
                    return       InkWell(
                      onTap: (){
                        getCordFromLocation(predictions![index].description,predictions![index].placeId);
                      },
                      child: Column(
                        children: [
                          Row (
                            children: [
                              Icon(Icons.add_location,color:Colors.grey[100],size:30),
                              SizedBox ( width: 20 ),
                              Container (
                                child: Column (
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text (predictions![index].structuredFormatting!.mainText!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle (
                                          color: Colors.black54, fontSize: 18, fontWeight: FontWeight.bold ), ),
                                    Text (predictions![index].structuredFormatting!.secondaryText!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle (
                                        color: Colors.grey[700], fontSize: 15, ), )
                                  ],
                                ),
                              ),
                              Spacer ( ),

                              Transform.rotate(
                                angle: 200 * pi / 180,
                                child: Icon(Icons.send,color:Colors.black38,size:25),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical:8.0,horizontal: 20),
                            child: Divider(),
                          )

                        ],
                      ),
                    );

                  },
                ),
              ),

            ],
          ),

        )
    );

  }
}
