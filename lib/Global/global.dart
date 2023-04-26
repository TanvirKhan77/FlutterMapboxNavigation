import 'package:firebase_auth/firebase_auth.dart';

import '../Models/direction_details_info.dart';
import '../Models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentInfo;

List dList = []; //online/active drivers Info List
String? choosendriverId = "";

DirectionDetailsInfo? tripDirectionDetailsInfo;
String cloudMessagingServerToken = "key=AAAA8zjuj_I:APA91bGihi35jQlLh_QjO-7VqCFRJg-icRZwV9My3n5l4rxD28RF7T-gM6Xwe7DMq5mKmMBs8jzfrsMsBZYSTBti52YI5-SuJojwT1ooeZ8j9IxytooV_oqPcRoQSpGhBW4sl-au9L4I";
String userDropOffAddress = "";
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";

double countRatingStars = 0.0;
String titleStarsRating = "";