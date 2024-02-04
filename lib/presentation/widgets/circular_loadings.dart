import 'package:flutter/material.dart';

Widget circularloadingWhiteSmall() {
  return SizedBox(
    height: 17,
    width: 17,
    child: CircularProgressIndicator(
      strokeWidth: 3,
      valueColor: AlwaysStoppedAnimation(Colors.grey.shade50),
    ),
  );
}

Widget circularloadingRedSmall() {
  return const SizedBox(
    height: 17,
    width: 17,
    child: CircularProgressIndicator(
      strokeWidth: 3,
    ),
  );
}

Widget circularloadingRedSmallInfinitySize() {
  return const SizedBox(
    height: double.infinity,
    width: double.infinity,
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: 3,
      ),
    ),
  );
}

showLoaderDialog(BuildContext context){
  AlertDialog alert=AlertDialog(
    content: Row(
      children: [
        circularloadingRedSmall(),
       // Container(margin: const EdgeInsets.only(left: 7),child:Text("Loading..." )),
      ],),
  );
  showDialog(barrierDismissible: false,
    context:context,
    builder:(BuildContext context){
      return alert;
    },
  );
}
