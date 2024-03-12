import 'package:currency_picker/currency_picker.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:fintracker/extension.dart';
import 'package:fintracker/helpers/db.helper.dart';
import 'package:fintracker/providers/app_provider.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:fintracker/widgets/dialog/confirm.modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);
    return Scaffold(
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.theme.primaryColor,
              ),
              height: MediaQuery.of(context).viewPadding.top + 60,
              padding: EdgeInsets.only(
                  top:MediaQuery.of(context).viewPadding.top,
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  IconButton(onPressed: Navigator.of(context).pop, icon: const Icon(IconsaxOutline.arrow_left_2,size: 26,),color: Colors.white,),
                  const SizedBox(width: 15,),
                  const Text("Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),)
                ],
              ),
            ),
            Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      title: const Text("Currency", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),),
                      visualDensity:const VisualDensity(
                        vertical: -2
                      ),
                      subtitle: Selector<AppProvider, String?>(
                          selector: (_, provider)=>provider.currency,
                          builder: (context, state, _) {
                            Currency? currency = CurrencyService().findByCode(state);
                            return Text(currency?.name ??"", style: context.theme.textTheme.bodySmall,);
                          }
                      ),
                      onTap: (){
                        showCurrencyPicker(context: context, onSelect: (Currency currency){
                          provider.updateCurrency(currency.code);
                        });
                      },
                    ),
                    ListTile(
                      onTap: (){
                        showDialog(context: context, builder: (context){
                          TextEditingController controller = TextEditingController(text: provider.username);
                          return AlertDialog(
                            title:  Text("Edit Profile", style: context.theme.textTheme.titleLarge!.apply(fontWeightDelta: 2),),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                            ),
                            content: SizedBox(
                              width: MediaQuery.of(context).size.width - 60 < 500 ? MediaQuery.of(context).size.width - 60 : 500,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                        label: const Text("What should we call you?"),
                                        hintText: "Enter your name",
                                        filled: true,
                                        border: UnderlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15)
                                    ),
                                  )
                                ],
                              ),
                            ),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                      child: AppButton(
                                        onPressed: (){
                                          if(controller.text.isEmpty){
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter name")));
                                          } else {
                                            provider.updateUsername(controller.text);
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        label: "Save my profile",
                                      )
                                  )
                                ],
                              )
                            ],
                          );
                        });
                      },
                      visualDensity:const VisualDensity( vertical: -2 ),
                      title: const Text("Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),),
                      subtitle: Selector<AppProvider, String?>(
                          selector: (_,provider)=>provider.username,
                          builder: (context, state, _) {
                            return Text(state??"", style: context.theme.textTheme.bodySmall,);
                          }
                      ),
                    ),
                    ListTile(
                      onTap: () async {
                        ConfirmModal.showConfirmDialog(
                            context, title: "Are you sure?",
                            content: const Text("After deleting data can't be recovered"),
                            onConfirm: ()async{
                              Navigator.of(context).popUntil((route) => route.isFirst);
                              await provider.reset();
                              await resetDatabase();
                            },
                            onCancel: (){
                              Navigator.of(context).pop();
                            }
                        );
                      },
                      visualDensity:const VisualDensity( vertical: -2 ),
                      title: const Text("Reset", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),),
                      subtitle:  Text("Delete all the data", style: context.theme.textTheme.bodySmall,),
                    ),
                  ],
                )
            )
          ],
        )
    );
  }
}
