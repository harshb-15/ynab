import 'dart:io';
import 'package:fintracker/dao/account_dao.dart';
import 'package:fintracker/dao/category_dao.dart';
import 'package:fintracker/dao/payment_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/model/category.model.dart';
import 'package:fintracker/model/payment.model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_gemini/google_gemini.dart';
import 'dart:core';

class OCRPage extends StatefulWidget {
  @override
  _OCRPageState createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> {
  String _analysisResult = 'Capture or select an image to analyze.';
  late GoogleGemini gemini;

  @override
  void initState() {
    super.initState();
    // Initialize Gemini with your API key
    gemini = GoogleGemini(apiKey: "AIzaSyBju4Jr4r1tfDu_b39HWTWzLjzFviK75sw");
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      final inputImage = InputImage.fromFilePath(pickedImage.path);
      final textDetector = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText =
          await textDetector.processImage(inputImage);
      await textDetector.close();

      // After extracting text with OCR, perform Gemini analysis
      _analyzeTextWithGemini(recognizedText.text);
    }
  }

  String totalamount = "";
  String _title = "";
  String _desc = "";
  void _analyzeTextWithGemini(String text) {
    // Construct your query for Gemini
    String inputText =
        '''Objective: Your task is to analyze a bill and extract the following information to format it as specified. Read through the entire bill to locate these details.

    Title (Shop Name): Look for the establishment's name that issued the bill. It's often at the top or mentioned alongside "billed by". Write down this name as it appears.

    Type (Income/Expense): Since this is a bill, assume it is an 'Expense' unless stated otherwise, such as being a refund or credit note. In that case, classify it as 'Income'.

    Account: Determine the payment method used. If a bank name or account is mentioned, note it down as the account used. If no specific bank is mentioned, assume the payment was made in "CASH".

    Category: Decide the category based on the nature of the transaction. For example, if it involves food, label it as "food"; if it's a utility bill, consider "utilities", etc. Use your judgment based on the contents of the bill.

    Description: Compile a brief description based on the bill's details. Include any available contact information for the service provider (phone number, email, etc.). This might require summarizing the bill's purpose and any additional relevant information.

    Total Amount: Locate the final amount to be paid or that was paid. This is typically after any taxes, discounts, or additional charges have been applied. It is often labeled as "Total", "Amount Due", or similar.

    Formatting Your Response:

    Once you have all the necessary information, format your response as follows:

    Title: [Extracted Shop Name]
    Type: [Income/Expense]
    Account: [Bank Name or CASH]
    Category: [Appropriate Category]
    Description: [Your compiled description, including contact information]
    Total Amount: [\$XX.XX] $text''';

    // Perform Gemini analysis
    gemini.generateFromText(inputText).then((value) {
      setState(() {
        // Display the Gemini analysis result
        _analysisResult = value.text;
        // Assuming the result is in the structured format mentioned above
        // Parse the result to extract individual pieces of information
        final lines = _analysisResult.split('\n');
        String title = lines
            .firstWhere((line) => line.startsWith('Title:'))
            .split(': ')[1];
        String type =
            lines.firstWhere((line) => line.startsWith('Type:')).split(': ')[1];
        String account = lines
            .firstWhere((line) => line.startsWith('Account:'))
            .split(': ')[1];
        String category = lines
            .firstWhere((line) => line.startsWith('Category:'))
            .split(': ')[1];
        // For description, find its start and end indices
        // Extracting the description which might include multiple lines
        final descriptionPattern =
            RegExp(r'Description:(.*?)Total Amount:', dotAll: true);
        String totalAmount = lines
            .firstWhere((line) => line.startsWith('Total Amount:'))
            .split(': ')[1];

        // Now you have the five variables extracted
        // Here you can use these variables as needed
        // For example, just printing them for now
        final descriptionMatch =
            descriptionPattern.firstMatch(_analysisResult)?.group(1)?.trim() ??
                "N/A";
        print('Title: $title');
        print('Type: $type');
        print('Account: $account');
        print('Category: $category');
        print('description: $descriptionMatch');
        print('Total Amount: $totalAmount');
        for (int i = 0; i < totalAmount.length; i++) {
          if (totalAmount[i] == '1' ||
              totalAmount[i] == '2' ||
              totalAmount[i] == '3' ||
              totalAmount[i] == '4' ||
              totalAmount[i] == '5' ||
              totalAmount[i] == '6' ||
              totalAmount[i] == '7' ||
              totalAmount[i] == '8' ||
              totalAmount[i] == '9' ||
              totalAmount[i] == '0' ||
              totalAmount[i] == '.') {
            totalamount += totalAmount[i];
          }
        }
        _title = title;
        _desc = descriptionMatch;
      });
    }).catchError((error) {
      setState(() {
        _analysisResult = 'Error analyzing text: $error';
      });
    });
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a picture'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final PaymentDao _paymentDao = PaymentDao();
  final AccountDao _accountDao = AccountDao();
  final CategoryDao _categoryDao = CategoryDao();
  List<Account> _accounts = [];
  List<Category> _categories = [];
  loadAccounts() {
    _accountDao.find().then((value) {
      setState(() {
        _accounts = value;
      });
    });
  }

  loadCategories() {
    _categoryDao.find().then((value) {
      setState(() {
        _categories = value;
      });
    });
  }

  void handleSaveTransaction(context) async {
    Payment payment = Payment(
        // id: _id,
        account: _accounts[0],
        category: _categories[2],
        amount: double.parse(totalamount),
        type: PaymentType.debit,
        datetime: DateTime.now(),
        title: _title,
        description: _desc);
    await _paymentDao.upsert(payment);
    // if (widget.onClose != null) {
    //   widget.onClose!(payment);
    // }
    Navigator.of(context).pop();
    globalEvent.emit("payment_update");
  }

  @override
  Widget build(BuildContext context) {
    loadAccounts();
    loadCategories();
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _showImageSourceActionSheet(context),
              child: Text('Start OCR'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      _analysisResult,
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                      onPressed: () => handleSaveTransaction(context),
                      child: Text('Generate Transaction'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
