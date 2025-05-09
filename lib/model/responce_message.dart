// To parse this JSON data, do
//
//     final responceMessage = responceMessageFromJson(jsonString);
import 'dart:convert';

ResponceMessage responceMessageFromJson(String str) => ResponceMessage.fromJson(json.decode(str));

String responceMessageToJson(ResponceMessage data) => json.encode(data.toJson());

class ResponceMessage {
    final bool success;
    final String message;

    ResponceMessage({
        required this.success,
        required this.message,
    });

    ResponceMessage copyWith({
        bool? success,
        String? message,
    }) => 
        ResponceMessage(
            success: success ?? this.success,
            message: message ?? this.message,
        );

    factory ResponceMessage.fromJson(Map<String, dynamic> json) => ResponceMessage(
        success: json["success"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
    };
}
