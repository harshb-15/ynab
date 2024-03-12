import 'package:ficonsax/ficonsax.dart';
import 'package:fintracker/helpers/color.helper.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget{
  final VoidCallback onGetStarted;
  const LandingPage({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: ListView(
                    children: [
                      Text("Fintracker", style: theme.textTheme.headlineLarge!.merge(TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),),
                      const SizedBox(height: 15,),
                      Text("Easy method to manage your savings", style: theme.textTheme.headlineSmall!.merge(TextStyle(color: ColorHelper.lighten(theme.colorScheme.primary, 0.1), fontWeight: FontWeight.w500)),),
                      const SizedBox(height: 25,),
                      for(String item in ["Using our app, manage your finances.", "Simple expense monitoring for more accurate budgeting", "Keep track of your spending whenever and wherever you are."])
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(IconsaxOutline.tick_circle,  color: theme.colorScheme.primary,),
                              const SizedBox(width: 15,),
                              Expanded(child: Text(item))
                            ],
                          ),
                        ),
                    ],
                  )
              ),
              const Text("*Since this application is currently in beta, be prepared for UI changes and unexpected behaviours."),
              const SizedBox(height: 20,),
              Container(
                alignment: Alignment.bottomRight,
                child: AppButton(
                  color: theme.colorScheme.primary,
                  isFullWidth: true,
                  onPressed: onGetStarted,
                  size: AppButtonSize.large,
                  label: "Get Started",
                  borderRadius: BorderRadius.circular(100),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

}