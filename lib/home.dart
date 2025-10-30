import 'package:flutter/material.dart';

class TripFuel extends StatefulWidget {
  const TripFuel({super.key});

  @override
  State<TripFuel> createState() => _TripFuelState();
}

class _TripFuelState extends State<TripFuel> {
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController literController = TextEditingController();

  String fuel = 'Diesel';
  double fuelResult = 0;
  bool isProcessing = false; // disable buttons while running

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TripFuel App'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            // It's safer to avoid hard-coded height so layout adapts and doesn't overflow.
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            width:
                320, // small fixed width is OK for a centered card; increase if you wish
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Distance
                Row(
                  children: [
                    const SizedBox(width: 90, child: Text('Distance : ')),
                    Expanded(
                      child: TextField(
                        controller: distanceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          hintText: ' ... km',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Fuel type
                Row(
                  children: [
                    const SizedBox(width: 90, child: Text('Type Of Fuel :')),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: fuel,
                        items: <String>['Petrol', 'Diesel'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          // safe setState
                          if (newValue == null) return;
                          setState(() {
                            fuel = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Price
                Row(
                  children: [
                    const SizedBox(width: 90, child: Text('Price :')),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Petrol 2, Diesel 4',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Rm'),
                  ],
                ),

                const SizedBox(height: 10),

                // Liter
                Row(
                  children: [
                    const SizedBox(width: 90, child: Text('Liter :')),
                    Expanded(
                      child: TextField(
                        controller: literController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          hintText: ' ... liters',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('liters'),
                  ],
                ),

                const SizedBox(height: 16),

                // Buttons row (prevents overflow)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : calculateFuel,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Calculate The Fuel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : resetAll,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'The total cost is: Rm ${fuelResult.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> calculateFuel() async {
    // disable buttons while computing
    setState(() {
      isProcessing = true;
    });

    try {
      // trim input and use tryParse to avoid exceptions
      final String dText = distanceController.text.trim();
      final String lText = literController.text.trim();

      final double? distance = double.tryParse(dText);
      final double? liter = double.tryParse(lText);

      if (distance == null || liter == null) {
        // user input invalid => show dialog and return
        await _showMessage(
          title: 'Invalid input',
          message: 'Please enter valid numbers for distance and liter.',
        );
        return;
      }

      // Example: use price if provided, else use default multipliers
      double multiplier;
      if (fuel == 'Petrol') {
        multiplier = 2.0;
      } else {
        multiplier = 4.0;
      }

      // If user entered price, you could compute differently; for now: multiplier * liter * distance
      final double result = multiplier * liter * distance;

      // update UI with result
      setState(() {
        fuelResult = result;
      });
    } catch (e, st) {
      // Unexpected error: show friendly message instead of crashing
      await _showMessage(
        title: 'Something went wrong',
        message:
            'An unexpected error occurred. Please try again.\n\nError: ${e.toString()}',
      );
      debugPrint('calculateFuel error: $e\n$st');
    } finally {
      // re-enable buttons
      setState(() {
        isProcessing = false;
      });
    }
  }

  void resetAll() {
    distanceController.clear();
    priceController.clear();
    literController.clear();
    setState(() {
      fuel = 'Diesel';
      fuelResult = 0;
    });
  }

  Future<void> _showMessage({required String title, required String message}) {
    // show dialog (keeps user in app and explains issue)
    return showDialog<void>(
      context: context,
      builder: (BuildContext c) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    distanceController.dispose();
    priceController.dispose();
    literController.dispose();
    super.dispose();
  }
}
