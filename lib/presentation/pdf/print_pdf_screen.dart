import 'package:flutter/material.dart';

class PrintPdfScreen extends StatelessWidget {
  const PrintPdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController infoController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Print PDF',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invoice and Packing Slip Address/VAT/Tax Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: infoController,
                      maxLines: 10,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Enter information...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (infoController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter some information to save.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          print('Information saved: ${infoController.text}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Information saved successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE31741),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Save Information',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}