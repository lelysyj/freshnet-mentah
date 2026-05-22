import 'package:cloud_firestore/cloud_firestore.dart';

class InspectionModel {
  final String? id;
  final String fishName;
  final double confidence;
  final String freshnessLabel;
  final bool isFresh;
  final String partLabel;
  final String? eyeImagePath;
  final String? gillImagePath;
  final String inspectedAt;

  InspectionModel({
    this.id,
    required this.fishName,
    required this.confidence,
    required this.freshnessLabel,
    required this.isFresh,
    required this.partLabel,
    this.eyeImagePath,
    this.gillImagePath,
    required this.inspectedAt,
  });

  factory InspectionModel.fromJson(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return InspectionModel(
      id: documentId,
      fishName: json['fishName'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      freshnessLabel: json['freshnessLabel'] ?? '',
      isFresh: json['isFresh'] ?? false,
      partLabel: json['partLabel'] ?? '',
      eyeImagePath: json['eyeImagePath'],
      gillImagePath: json['gillImagePath'],
      inspectedAt: json['inspectedAt'] is Timestamp
          ? (json['inspectedAt'] as Timestamp).toDate().toIso8601String()
          : json['inspectedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fishName': fishName,
      'confidence': confidence,
      'freshnessLabel': freshnessLabel,
      'isFresh': isFresh,
      'partLabel': partLabel,
      'eyeImagePath': eyeImagePath,
      'gillImagePath': gillImagePath,
      'inspectedAt': inspectedAt,
    };
  }
}