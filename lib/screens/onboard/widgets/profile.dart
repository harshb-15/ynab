import 'package:currency_picker/currency_picker.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:fintracker/helpers/color.helper.dart';
import 'package:fintracker/helpers/db.helper.dart';
import 'package:fintracker/providers/app_provider.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileWidget extends StatefulWidget{
  const ProfileWidget({super.key});

  @override
  State<StatefulWidget> createState() =>_ProfileWidget();
}

class _ProfileWidget extends State<ProfileWidget>{
  final CurrencyService currencyService = CurrencyService();
  String _username = "";
  Currency? _currency;
  @override
  void initState() {
    setState(() {
      _currency = currencyService.findByCode("INR");
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppProvider provider = Provider.of<AppProvider>(context);
    return Scaffold(
      body: SafeArea(
        child:  Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: ListView(
                        children: [
                          Text("Hi! \nwelcome to Fintracker", style: theme.textTheme.headlineMedium!.apply(color: theme.colorScheme.primary, fontWeightDelta: 2),),
                          const SizedBox(height: 15,),
                          Text("Please enter all details to continue.", style: theme.textTheme.bodyLarge!.apply(color: ColorHelper.darken(theme.textTheme.bodyLarge!.color!), fontWeightDelta: 1),),
                          const SizedBox(height: 30,),
                          TextFormField(
                            onChanged: (String username)=>setState(() {
                              _username  = username;
                            }),
                            decoration: InputDecoration(
                                filled: true,
                                border: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                prefixIcon:  const Icon(IconsaxOutline.profile_circle),
                                hintText: "Enter your name",
                                label: const Text("What should we call you?")
                            ),
                          ),
                          const SizedBox(height: 40,),
                          Autocomplete<Currency>(
                            initialValue: TextEditingValue(text: _currency!=null ? "(${_currency?.code}) ${_currency?.name}":""),
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<Currency>.empty();
                              }
                              return currencyService.getAll().where((Currency option) {
                                String keyword= textEditingValue.text.toLowerCase();
                                return option.name.toLowerCase().contains(keyword) || option.code.toLowerCase().contains(keyword);
                              });
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted){
                              return TextField(controller: controller, focusNode: focusNode, decoration:  InputDecoration(
                                  filled: true,
                                  border: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  prefixIcon: const Icon(IconsaxOutline.dollar_circle),
                                  hintText: "Select you currency",
                                  label: const Text("What will be your default currency?")
                              ),
                              );
                            },
                            displayStringForOption: (selection)=>"(${selection.code}) ${selection.name}",
                            onSelected: (Currency selection) {
                              setState(() {
                                _currency = selection;
                              });
                            },
                          ),
                        ],
                      )
                  ),
                  AppButton(
                    borderRadius: BorderRadius.circular(100),
                    label: "Continue",
                    color: theme.colorScheme.primary,
                    isFullWidth: true,
                    size: AppButtonSize.large,
                    onPressed: () async {
                      if(_username.isEmpty || _currency == null){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all the details")));
                      } else {
                        await resetDatabase();
                        await provider.reset();
                        provider.update(username: _username, currency: _currency!.code).then((value){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Setup completed")));
                        });
                      }
                    },
                  )
                ]
            )
        ),
      ),
    );
  }
}