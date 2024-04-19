

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
   int _type = 1;

  void _handleGooglePay(Object? e) {
    setState(() {
      _type = e as int;
      if (_type == 1) {
        _launchGooglePay();
      }
    });
  }

  void _handlePhonePe(Object? e) {
    setState(() {
      _type = e as int;
      if (_type == 2) {
        _launchPhonePe();
      }
    });
  }

  void _launchGooglePay() async {
    const url = 'https://pay.google.com/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchPhonePe() async {
    const url = 'https://www.phonepe.com/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        title: const Text(
          "Payment Method",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 30),
              // Google Pay Container
              GestureDetector(
                onTap: () {
                  _handleGooglePay(1); // Set the value to 5 for Google Pay
                },
                child: Container(
                  width: size.width,
                  height: 55,
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: _type == 1
                        ? Border.all(width: 2, color: Color.fromARGB(255, 31, 12, 11))
                        : Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Radio(
                                value: 1, // Set the value to 5 for Google Pay
                                groupValue: _type,
                                   onChanged: _handleGooglePay,

                                activeColor: Color.fromARGB(255, 141, 48, 41),
                              ),
                              Text("Google Pay",
                                style: _type == 1 ? TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey) : TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Image.asset(
                            "images/g_pay.png",
                            width: 110,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            //..
                GestureDetector(
                onTap: () {
                  _handlePhonePe(2); // Set the value to 2 for Phone Pay
                },
                child: Container(
                  width: size.width,
                  height: 55,
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: _type == 2
                        ? Border.all(width: 2, color: Color.fromARGB(255, 31, 12, 11))
                        : Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Radio(
                                value: 2, // Set the value to 2 for Phone Pay
                                groupValue: _type,
                               onChanged: _handlePhonePe,
                                activeColor: Color.fromARGB(255, 141, 48, 41),
                              ),
                              Text(
                                "Phone Pay",
                                style: _type == 2
                                    ? TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey)
                                    : TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                              ),
                            ],
                          ),
                          Image.asset(
                            "images/phone_pay.png",
                            width: 80,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
               SizedBox(height: 15),
            // Container(
            //   width: size.width,
            // height: 55,
            // margin:EdgeInsets.only(right: 20,left: 20,top: 10,bottom: 10),
            // decoration: BoxDecoration(
            //   border: _type == 4? Border.all(width: 2,color: Color.fromARGB(255, 31, 12, 11)):Border.all(width: 1,color:Colors.grey),
            //   borderRadius: BorderRadius.all(Radius.circular(6)),
            //   color: Colors.transparent,
            // ),
            
            //   child: Center(
            //     child: Padding(
            //       padding: const EdgeInsets.only(right:20),
            //       child: Row(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            //         children: [
            //       Row(
            //            crossAxisAlignment: CrossAxisAlignment.center,
            //         children: [
            //         Radio(
            //         value: 4,
            //          groupValue: _type,
            //           onChanged: _handleRadio,
            //       activeColor:Color.fromARGB(255, 141, 48, 41) ,
            //       ),
            //         Text("Cash on Delivery",
            //         style: _type==4?TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Colors.grey) :TextStyle(
            //           fontSize: 15,
            //           fontWeight: FontWeight.w500,
            //           color:Colors.grey),
            //         ),
                   
            //       ],
            //       ),
            //        Image.asset("images/Cash.png",
            //         width: 80,
            //         height: 70,
            //         fit: BoxFit.cover,)
                    
            //                     ],
            //                     ),
            //     ),
            //   ),

            
            // ),
            //.....
            SizedBox(height: 30),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SUB-TOTAL",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color:Colors.grey,
                      ),
                    ),
                    Text(
                      "\₹",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color:Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              //..
                   Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Shipping-Fees",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color:Colors.grey,
                      ),
                    ),
                    Text(
                      "\₹",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color:Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 30,
              color: Colors.black,),
              //..
                SizedBox(height: 5),
                     Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Pyment",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color:Colors.grey,
                      ),
                    ),
                    Text(
                      "\₹",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color:Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
                
               
          ],
          ),
          ),
          ),
    );
  }
}

