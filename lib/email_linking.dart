import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'secret.dart' as secret;

class EmailLinker {

  static sendGroupInvite(String recipient, Map<String, dynamic> senderInfo) async {

    final person = senderInfo["name"] as String;
    final senderSub = senderInfo["sub"] as String;
    final receiverSub = "";
    final link = secret.apiEndpointUrl + "/account-linking/"+senderSub+"/"+receiverSub;
    final email = Email(
      recipients: [recipient],
      subject: person + " would like to share recipe books with you!",
      body: person + " would like to share their recipe book with you.\nTo accept please follow the link below.\n\t"+link+"Sincerely,\nThe Recipe App Team.",
    );
    await FlutterEmailSender.send(email);
  }

}