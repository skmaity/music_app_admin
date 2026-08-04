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

    /// Parsed defensively: a PHP warning, an HTML error page, or a proxy 5xx can
    /// arrive without these keys or with the wrong type. Treat anything that is
    /// not an explicit `true` as a failure, and never throw on a missing message.
    factory ResponceMessage.fromJson(Map<String, dynamic> json) => ResponceMessage(
        success: json["success"] == true,
        message: '${json["message"] ?? ''}',
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
    };
}
