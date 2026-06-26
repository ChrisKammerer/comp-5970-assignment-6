import 'package:email_summarizer/models/email_summary_entry.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class EntryCard extends StatelessWidget {

  final EmailSummaryEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  
  const EntryCard({super.key, required this.entry, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MM-dd-yyyy hh:mm').format(entry.createdAt),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),

            SizedBox(height: 8,),

            Text(
              entry.title == '' ? 'Untitled Entry' : entry.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),

            SizedBox(height: 8,),

            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit),
                    label: Text("Edit"),
                  )
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onDelete, 
                    icon: Icon(Icons.delete_outline),
                    label: Text("Delete")),
                ),

              ],
            )

          ],
        ),),
    );
  }
}