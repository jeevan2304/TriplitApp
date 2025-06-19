import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

class TravelModelService {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    final model = await FirebaseModelDownloader.instance.getModel(
      'travel_model', // name you gave in Firebase ML
      FirebaseModelDownloadType.latestModel,
    );

    final modelPath = model.file.path;

    _interpreter = await Interpreter.fromFile(File(modelPath));
  }

  Future<double> predict(List<double> input) async {
    if (_interpreter == null) throw Exception("Model not loaded");

    var inputTensor = [input];
    var output = List.filled(1, 0).reshape([1, 1]);

    _interpreter!.run(inputTensor, output);

    return output[0][0].toDouble(); // Assuming output is a single value
  }
}
