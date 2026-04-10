import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsApp(String phone, String message) async {
  final whatsappUri = Uri.parse("whatsapp://send?phone=$phone&text=$message");
  final fallbackUri = Uri.parse("https://wa.me/$phone?text=$message");
  print("WHATSAPP -------------${whatsappUri} -------- ${fallbackUri}");

  if (await canLaunchUrl(whatsappUri)) {
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  } else {
    await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
  }
}

void extractAndOpenWhatsApp(String fullUrl) {
  final uri = Uri.parse(fullUrl);
  final phone = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
  final message = uri.queryParameters['text'] ?? '';

  openWhatsApp(phone, message);
}
