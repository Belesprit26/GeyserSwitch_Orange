import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  DatabaseReference databaseReference = FirebaseDatabase.instance
      .ref()
      .child("GeyserSwitch")
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child("ServiceInfo");

  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(
          {
              "type": "service_account",
              "project_id": "geyserswitch-bloc",
              "private_key_id": "4f8adfec94e6e24a025c015bcd3d674a6421b24c",
              "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDZVNMTUdONCQ5h\nNbEq7/XzMB0tXGLzQTV1/n1gbAOU6gPCxUkr9ELgdchltFa0K2HyWPquNn/5m+9Y\nd8lgKwfqeCAv2PuN+g8Kx6UsvJcy1B0KHEGIWUwropXGbI6eqRmsG8n154c8ExJl\npcLKGFSyZ7FNan8ijB55vSxq6iiGbop9dFiz6v1QSN9uMfvB35v6wf7w+9NhSs/Q\nu9odKZevzAGyFgg/c4LKFs29e4Us1hDOrHN8tZzfoo4wqQr5CU3iJQxdgZV1tPJv\ns3jPrCEg6nLDDsKLXPE+aX0UXVs43zOzf8350mzKBMJZWxusCKlJ+ripqSNFnduy\ngJyiJ1NJAgMBAAECggEAFf3fDLHCA3UqzwFnjR29DepiJB3uJrQEMeLE/cXQUvhJ\n1c1a4HzAwQU0zb3YQYuw8fIOY89ArJnFOCGJmhagoBmfFYMSaW/Sp9eYn5SchC3c\nm7z3kKbgmKXExtBjWitoXUxukliRtwLYYLrLoYxMExrVC9gT8gNVw3c2EGzjbul+\nwCJQl/0s9sGnzF1W1ZeOdj0jynIuIeaZM9RIckBgNmr+LxRLA/ZqSyglSd9RfpsD\nhxaWFiGc+M1JjQNUZ+09TJDqsYQSmRMl0iGudh/CQiOPAUT5LvglxfQPldlYV0az\npJcqmZE/Wpzb+FwGI6gdE1uvaJFFOR8lBquBsIlKtQKBgQD/6ZUx5+6Cyssh3IKI\n8rS50AS1SdnccZIQmPKTh9vM1h/aEfhVnRrvO0ojPhAZFpm6SCmb5D/EGcAV+VZv\nxO2NmkkfddBRFs4joI/S2zqX5ko6puT7gP9tyg0EN7gEBEUAzBhJJwk8CRtY/hIB\nvf6ANRHqurtut4GrqPzYz1DNiwKBgQDZZ9y0ULlWZ6Po9SwGQt7O82K80hKkitZq\nYORnGskv64ZToTRG1THfr5hD1vW7+LlARgO3g8fpfBreCdCTiZagpZqPox4Oz2zh\nAYWmgLeSf2JfRcpivXgH1QDB0wyiUK19jNmRypHF3kEiBfYFn9IoiTCZ/XfpMasT\nfcCj7Frk+wKBgQDBWE7aF6rBsklqWdldclFMmXcVKKiqvjtmwsdy4xATYCtMbIs8\n06eH2zmWCsvKyKJ4dRDKsNXkaLgRYgIGC7iWZVydojszKJGxpRtEaVGJdfna+kDC\nK6HP5vmSmC41Cqy/f3NRwWZer1q0D7C3FD51yqKwv0fgzE/xy4jMnUUlJQKBgQCA\nU4o29R8xHWPm8jDWUUprJca2ZdmTPlBp4l9vbKQsoP1dB95voRAbVO6vvIa4OYw/\noBQ5kpPCAftp7KktLR24HYgqGMJ5Q36lIdzd90RkOMS8L9nShrv/A3+66PSgKrb9\nUNJr+AIrpZEUoCgkEb5fJvuFKdRJ1YOBscyv9aeBWQKBgGxfzHK0/ouyK3HI7flj\nlNQ9k1E1FIIySirvHIYvpHDH856UjirNPfAFhT8YP6v2L+LL1sqxxRyyRYcrNF4Z\nayNRSPOJVrUpWoF/iJ0zWdQwkildYAgC2A79r4cR61XD6PEOAbqWlRluVPHVVyf2\nkGo90BCv5EsDy1wg79xb0RAf\n-----END PRIVATE KEY-----\n",
              "client_email": "firebase-adminsdk-9heqh@geyserswitch-bloc.iam.gserviceaccount.com",
              "client_id": "103068749202439739226",
              "auth_uri": "https://accounts.google.com/o/oauth2/auth",
              "token_uri": "https://oauth2.googleapis.com/token",
              "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
              "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-9heqh%40geyserswitch-bloc.iam.gserviceaccount.com",
              "universe_domain": "googleapis.com"
          },
      ),
      scopes,
    );
    final accessServerKey = client.credentials.accessToken.data;
    print("Service Key: $accessServerKey");

    await databaseReference.update({
      'serverToken': accessServerKey,
    });
    return accessServerKey;
  }
}