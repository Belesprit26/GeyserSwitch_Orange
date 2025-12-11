import 'package:flutter/material.dart';
import 'package:gs_orange/src/profile/presentation/widgets/edit_profile_form_field.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';

@Deprecated('Use BLE provisioning: BleProvisioningService in lib/src/ble/provisioning/ble_provisioning_service.dart')
class WiFiConfigPage extends StatefulWidget {
  const WiFiConfigPage({Key? key}) : super(key: key);

  @override
  _WiFiConfigPageState createState() => _WiFiConfigPageState();
}

class _WiFiConfigPageState extends State<WiFiConfigPage> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _wifiPasswordController = TextEditingController(); // Wi-Fi Password
  final TextEditingController _emailController = TextEditingController(); // User's Email
  final TextEditingController _userPasswordController = TextEditingController(); // User's Password

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isConnected = false;
  String _statusMessage = "Attempting to connect to GeyserSwitch..."
      "\n\nRemember to select it under WiFi settings...";

  @override
  void initState() {
    super.initState();
    _checkConnection();

    // Autofill the email and user password from UserProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (user != null) {
        _emailController.text = user.email;
      }
    });
  }

  Future<void> _checkConnection() async {
    int retryCount = 0;
    const int maxRetries = 10;

    while (retryCount < maxRetries) {
      try {
        final response = await http.get(Uri.parse('http://192.168.4.1'));
        if (response.statusCode == 200) {
          setState(() {
            _isConnected = true;
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        // Handle error
      }
      await Future.delayed(const Duration(seconds: 1));
      retryCount++;
    }

    setState(() {
      _isLoading = false;
      _statusMessage = "Failed to connect. Please connect to the ESP32 Wi-Fi Access Point.";
    });
  }

  Future<void> _submitForm() async {
    if (_ssidController.text.isEmpty ||
        _wifiPasswordController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _userPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill in all fields"),
      ));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.4.1/setting'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'ssid': _ssidController.text,
          'pass': _wifiPasswordController.text,
          'email': _emailController.text,
          'pass2': _userPasswordController.text,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Successfully sent the data"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to send data. Response code: ${response.statusCode}"),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error sending data: $e"),
      ));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _wifiPasswordController.dispose();
    _emailController.dispose();
    _userPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background to white
      appBar: AppBar(
        title: const Text('GeyserSwitch Credentials'),
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _isConnected
          ? Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditProfileFormField(
                  fieldTitle: 'WI-FI SSID',
                  controller: _ssidController,
                  hintText: 'Enter Wi-Fi SSID',
                ),
                EditProfileFormField(
                  fieldTitle: 'WI-FI PASSWORD',
                  controller: _wifiPasswordController,
                  hintText: 'Enter Wi-Fi Password',
                  obscureText: true,
                ),
                EditProfileFormField(
                  fieldTitle: 'EMAIL',
                  controller: _emailController,
                  hintText: 'Enter Email',
                  readOnly: true, // Since it's autofilled
                ),
                EditProfileFormField(
                  fieldTitle: 'USER PASSWORD',
                  controller: _userPasswordController,
                  hintText: 'Enter User Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
          if (_isSubmitting) _buildSubmittingOverlay(),
        ],
      )
          : _buildStatusMessage(),
    );
  }

  // Loading indicator widget
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_statusMessage),
        ],
      ),
    );
  }

  // Submitting overlay widget
  Widget _buildSubmittingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Status message widget for when not connected
  Widget _buildStatusMessage() {
    return Center(
      child: Text(
        _statusMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}