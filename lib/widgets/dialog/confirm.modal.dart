import 'package:fintracker/theme/colors.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

class ConfirmModal extends StatelessWidget{
  final String title;
  final Widget content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const ConfirmModal({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600),),
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width - 60 < 500 ? MediaQuery.of(context).size.width - 60 : 500,
        child: content,
      ),
      actions: [
        Row(
          children: [
            Expanded(
                child: AppButton(
                    label: "No",
                    onPressed: onCancel,
                    color: Theme.of(context).colorScheme.primary,
                    type: AppButtonType.outlined,
                  borderRadius: BorderRadius.circular(100),
                )
            ),
            const SizedBox(width: 15,),
            Expanded(
                child: AppButton(
                  label: "Yes",
                  onPressed: onConfirm,
                  color: ThemeColors.error,
                  borderRadius: BorderRadius.circular(100),
                )
            ),
          ],
        )
      ],
    );
  }

  static showConfirmDialog(BuildContext context, {
    required String title,
    required Widget content,
    required VoidCallback onConfirm,
    required VoidCallback onCancel
  }
  ){
    showDialog(context: context, builder: (BuildContext context){
      return ConfirmModal(title: title, content: content, onConfirm: onConfirm, onCancel: onCancel);
    });
  }

}