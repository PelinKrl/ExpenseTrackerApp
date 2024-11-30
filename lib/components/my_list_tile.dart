import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String trailing;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;

  const MyListTile({
    super.key,
    required this.title,
    required this.trailing,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
         children: [
          //setting option
          SlidableAction(
            onPressed: onEditPressed ?? (_) {},
            icon: Icons.settings,
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),

          //delete option
          SlidableAction(
            onPressed: onDeletePressed ?? (_) {},
            icon: Icons.delete,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
         ]
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.purple.shade100,
          borderRadius: BorderRadius.circular(7),
          ) ,
          margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
        child: ListTile(
          title: Text(title),
          trailing: Text(trailing),
        ),
      ),
    );
  }
}