import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class messageWidget extends StatelessWidget {
  const messageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(child: Text('Messages'),),
    );
  }
}

class contactList extends StatelessWidget {
  const contactList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepOrangeAccent,child: Center(child: Text('contacts'),),
    );
  }
}
class anywidget extends StatelessWidget {
  const anywidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.green, child: Center(child: Text('Hey'),),);
  }
}

class ResponsiveUI extends StatelessWidget {
  const ResponsiveUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('This is a test screen'),
        backgroundColor: Colors.brown,
      ),
      body: LayoutBuilder(
        builder: (context, Constraints){
          if (Constraints.maxWidth < 600){
            return Column(
              children: [
                Expanded(child: messageWidget()),
                Expanded(child: contactList())
              ],
            );
          } else {return Row(
            children: [
              Expanded(child: contactList()
              ),
              VerticalDivider(width: 2,),
              Expanded(child: anywidget()),
              Expanded(child: messageWidget())
            ],
          );
          }
        }),
    );
  }
}