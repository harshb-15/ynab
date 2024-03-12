import 'package:events_emitter/events_emitter.dart';
import 'package:fintracker/dao/payment_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/payment.model.dart';
import 'package:fintracker/screens/home/widgets/payment_list_item.dart';
import 'package:fintracker/screens/payments/payment_form.screen.dart';
import 'package:flutter/material.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final PaymentDao _paymentDao = PaymentDao();
  EventListener? _paymentEventListener;
  List<Payment> _payments = [];
  int _count = 0;
  final int limit = 20;



  void loadMore() async {
    if(_count > _payments.length || _payments.isEmpty) {
      List<Payment> payments = await _paymentDao.find(
          limit: 20, offset: _payments.length);
      int count = await _paymentDao.count();
      setState(() {
        _count = count;
        _payments.addAll(payments);
      });
    } else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No more transactions"), duration: Duration(seconds: 1),));
    }
  }

  @override
  void initState() {
    loadMore();
    _paymentEventListener = globalEvent.on("payment_update", (data) async {
      List<Payment> payments = await _paymentDao.find(
          limit: _payments.length > limit ? _payments.length: limit,
          offset: 0
      );
      int count = await _paymentDao.count();
      setState(() {
        _count = count;
        _payments = payments;
      });
      debugPrint("payments are changed");
    });
    super.initState();
  }

  @override
  void dispose() {
    _paymentEventListener?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Payments", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
        ),
        body: RefreshIndicator(
          onRefresh: ()async{
            setState(() {
              _count = 0;
              _payments = [];
            });
            return loadMore();
          },
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            itemCount: _payments.length,
            itemBuilder: (BuildContext context, index){
              return PaymentListItem(payment: _payments[index], onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>PaymentForm(type: _payments[index].type, payment: _payments[index],)));
              });

            },
            separatorBuilder: (BuildContext context, int index){
              return Container(
                width: double.infinity,
                color: Colors.grey.withAlpha(25),
                height: 1,
                margin: const EdgeInsets.only(left: 75, right: 20),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "payment-hero-fab",
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>const PaymentForm(type: PaymentType.credit)));
          },
          child: const Icon(Icons.add),
        )
    );
  }
}
