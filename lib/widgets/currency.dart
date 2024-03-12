import 'package:currency_picker/currency_picker.dart';
import 'package:fintracker/helpers/currency.helper.dart';
import 'package:fintracker/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrencyText extends StatelessWidget{
  final double? amount;
  final TextStyle? style;
  final TextOverflow? overflow;
  final bool? isCompact;
  final CurrencyService currencyService = CurrencyService();

  CurrencyText(this.amount, {super.key , this.style, this. overflow, this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Selector<AppProvider, String?>(
        builder: (context, state, _){
          Currency? currency = currencyService.findByCode(state);
          if(isCompact??false){
            return Text(amount==null? "${currency!.symbol} " : CurrencyHelper.formatCompact(amount!, name: currency?.code, symbol: currency?.symbol), style: style, overflow: overflow,);
          }
          return Text(amount==null? "${currency!.symbol} " : CurrencyHelper.format(amount!, name: currency?.code, symbol: currency?.symbol), style: style, overflow: overflow,);
        },
        selector: (_, provider)=>provider.currency
    );
  }
}

