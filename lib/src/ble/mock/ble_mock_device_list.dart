import 'package:flutter/material.dart';

class MockBleDevice {
  final String id;
  final String name;
  const MockBleDevice({required this.id, required this.name});
}

class BleMockDeviceList extends StatelessWidget {
  final List<MockBleDevice> devices;
  final void Function(MockBleDevice device) onConnect;

  const BleMockDeviceList({super.key, required this.devices, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: devices.isNotEmpty ? () => onConnect(devices.first) : null,
              label: const Text('Use Mock Device'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final m = devices[index];
              return ListTile(
                title: Text(m.name),
                subtitle: Text(m.id),
                trailing: const Icon(Icons.developer_mode),
                onTap: () => onConnect(m),
              );
            },
          ),
        ),
      ],
    );
  }
}


