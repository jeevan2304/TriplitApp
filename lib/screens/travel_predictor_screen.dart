import 'package:flutter/material.dart';
import 'travel_model_service.dart';

class TravelPredictorScreen extends StatefulWidget {
  const TravelPredictorScreen({super.key});

  @override
  State<TravelPredictorScreen> createState() => _TravelPredictorScreenState();
}

class _TravelPredictorScreenState extends State<TravelPredictorScreen> {
  final _service = TravelModelService();

  final TextEditingController _seasonController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _companionController = TextEditingController();

  String _predictionResult = "Prediction will appear here.";

  @override
  void initState() {
    super.initState();
    _service.loadModel();
  }

  void _predict() async {
    final input = [
      double.tryParse(_seasonController.text) ?? 0.0,
      double.tryParse(_typeController.text) ?? 0.0,
      double.tryParse(_companionController.text) ?? 0.0,
    ];

    final result = await _service.predict(input);

    // Convert index to destination name (you can customize this)
    final destinations = ["Goa", "Manali", "Ladakh", "Hampi"];
    final predicted = result.round();
    final destination = (predicted >= 0 && predicted < destinations.length)
        ? destinations[predicted]
        : "Unknown";

    setState(() {
      _predictionResult = "Recommended destination: $destination";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Travel Recommender")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _seasonController,
              decoration: const InputDecoration(labelText: "Season (e.g., 0 = Winter)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: "Travel Type (e.g., 1 = Beach)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _companionController,
              decoration: const InputDecoration(labelText: "Companion Type (e.g., 2 = Solo)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _predict,
              child: const Text("Predict Destination"),
            ),
            const SizedBox(height: 20),
            Text(_predictionResult),
          ],
        ),
      ),
    );
  }
}
