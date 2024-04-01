import 'dart:async';

import 'package:ficonsax/ficonsax.dart';
import 'package:fintracker/extension.dart';
import 'package:fintracker/providers/app_provider.dart';
import 'package:fintracker/screens/accounts/accounts.screen.dart';
import 'package:fintracker/screens/categories/categories.screen.dart';
import 'package:fintracker/screens/home/home.screen.dart';
import 'package:fintracker/screens/onboard/onboard_screen.dart';
import 'package:fintracker/screens/payments/payments_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selected = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List navigation = [
      {
        "icon": IconsaxOutline.home,
        "iconSelected": IconsaxBold.home,
        "label": "Home"
      },
      {
        "icon": IconsaxOutline.book,
        "iconSelected": IconsaxBold.book,
        "label": "Payments"
      },
      {
        "icon": IconsaxOutline.wallet,
        "iconSelected": IconsaxBold.wallet,
        "label": "Accounts"
      },
      {
        "icon": IconsaxOutline.category,
        "iconSelected": IconsaxBold.category,
        "label": "Categories"
      },
    ];
    // int comp(SmsMessage a, SmsMessage b) {
    //   return a.date! < b.date!;
    // }

    // Future<List<SmsMessage>> test() async {
      
    // }

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.currency == null || provider.username == null) {
          return OnboardScreen();
        }
        return Scaffold(
          body: Column(children: [
            Expanded(
                child: IndexedStack(
              index: _selected,
              children: const [
                HomeScreen(),
                PaymentsScreen(),
                AccountsScreen(),
                CategoriesScreen(),
              ],
            )),
            Container(
              height: 65,
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          width: 1, color: Colors.grey.withAlpha(40))),
                  color: Colors.grey.withAlpha(20)),
              child: Row(
                children: [
                  for (int x = 0; x < navigation.length; x++)
                    Expanded(
                        child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() {
                                _selected = x;
                                // test();
                              }),
                              child: Container(
                                height: 65,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selected == x
                                          ? navigation[x]["iconSelected"] ??
                                              navigation[x]["icon"]
                                          : navigation[x]["icon"],
                                      color: _selected == x
                                          ? context
                                              .theme.colorScheme.inversePrimary
                                          : context.theme.dividerColor,
                                      size: 22,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      navigation[x]["label"],
                                      style: context.theme.textTheme.labelSmall
                                          ?.apply(
                                              fontWeightDelta:
                                                  _selected == x ? 2 : 0,
                                              color: _selected == x
                                                  ? context.theme.colorScheme
                                                      .inversePrimary
                                                  : context.theme.dividerColor),
                                    ),
                                  ],
                                ),
                              ),
                            )))
                ],
              ),
            )
          ]),
        );
      },
    );
  }
}
