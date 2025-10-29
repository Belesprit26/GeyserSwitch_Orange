class DeviceInfoRecordModel {
  DeviceInfoRecordModel({
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
    required this.deviceBrand,
    required this.appVersion,
    required this.buildNumber,
    this.fcmToken,
  });

  final String platform;
  final String osVersion;
  final String deviceModel;
  final String deviceBrand;
  final String appVersion;
  final String buildNumber;
  final String? fcmToken;

  Map<String, Object?> toMap() => {
        'platform': platform,
        'osVersion': osVersion,
        'deviceModel': deviceModel,
        'deviceBrand': deviceBrand,
        // aliases for convenience/consumers expecting generic keys
        'model': deviceModel,
        'brand': deviceBrand,
        'appVersion': appVersion,
        'buildNumber': buildNumber,
        if (fcmToken != null) 'fcmToken': fcmToken,
      };
}


