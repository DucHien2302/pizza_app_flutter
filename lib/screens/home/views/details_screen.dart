import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_app/components/micro.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width - (40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(3, 3),
                    blurRadius: 5
                  )
                ],
                image: DecorationImage(
                  image: AssetImage(
                    'assets/1.png'
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(3, 3),
                    blurRadius: 5
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Truffle Temptation Extravaganza',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$12.00',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary
                                  ),
                                ),
                                Text(
                                  '\$15.00',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12,),
                    Row(
                      children: [
                        MyMicroWidget(
                          title: 'Calories',
                          value: 267,
                          icon: FontAwesomeIcons.fire,
                        ),
                        SizedBox(width: 10,),
                        MyMicroWidget(
                          title: 'Protein',
                          value: 36,
                          icon: FontAwesomeIcons.dumbbell,
                        ),
                        SizedBox(width: 10),
                        MyMicroWidget(
                          title: 'Fat',
                          value: 21,
                          icon: FontAwesomeIcons.oilWell,
                        ),
                        SizedBox(width: 10),
                        MyMicroWidget(
                          title: 'Carbs',
                          value: 38,
                          icon: FontAwesomeIcons.breadSlice,
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          elevation: 3.0,
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ), 
                        child: Text(
                          'Buy Now',
                            style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}