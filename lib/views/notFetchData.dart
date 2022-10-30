import 'package:flutter/material.dart';

import 'package:app/tools/app/appMessages.dart';

class NotFetchData extends StatelessWidget {
  final VoidCallback? tryClick;

  const NotFetchData({
    this.tryClick,
    Key? key,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppMessages.serverNotRespondProperly,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          if(tryClick != null)
            TextButton(
                onPressed: (){
                  tryClick?.call();
                },
                child: Text(AppMessages.tryAgain)
            ),
        ],
      ),
    );
  }
}
