import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shopzone/api_key.dart';

class CartMethods {
  Future<void> addItemToCart(
      String itemId, int itemCounter, String userID) async {
    const String apiUrl = API.addToCart;

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        "userId": userID,
        "itemId": itemId,
        "itemCounter": itemCounter.toString(),
      },
    );
    // print(userID);
    // print(itemId);
    // print(itemCounter);
    print(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey("message")) {
        Fluttertoast.showToast(
          msg: responseData["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );

        print(responseData[
            "message"]); // You can replace this print with a toast message or any other method to notify the user.
      } else {
        print("Unexpected response from the server");
      }
    } else {
      print(
          "Failed to process the request. Status code: ${response.statusCode}");
    }
  }

  separateOrderItemIDs(productIDs) {
    //2367121:5
    List<String>? userCartList = List<String>.from(productIDs);

    List<String> itemsIDsList = [];
    for (int i = 1; i < userCartList.length; i++) {
      //2367121:5
      String item = userCartList[i].toString();
      var lastCharacterPositionOfItemBeforeColon = item.lastIndexOf(":");

      //2367121
      String getItemID =
          item.substring(0, lastCharacterPositionOfItemBeforeColon);
      itemsIDsList.add(getItemID);
    }

    return itemsIDsList;
  }

  separateOrderItemsQuantities(productIDs) {
    //2367121:5
    List<String>? userCartList = List<String>.from(productIDs);
    print("userCartList = ");
    print(userCartList);

    List<String> itemsQuantitiesList = [];
    for (int i = 1; i < userCartList.length; i++) {
      //2367121:5
      String item = userCartList[i].toString();
      // 0=[:] 1=[5]
      var colonAndAfterCharactersList = item.split(":").toList(); // 0=[:] 1=[5]
      //'5'
      var quantityNumber = int.parse(colonAndAfterCharactersList[1].toString());
      itemsQuantitiesList.add(quantityNumber.toString());
    }

    print("itemsQuantitiesList = ");
    print(itemsQuantitiesList);
    return itemsQuantitiesList;
  }
}
