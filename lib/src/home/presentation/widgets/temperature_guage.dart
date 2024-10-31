import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TempSettingPage extends StatefulWidget {
  @override
  _TempSettingPageState createState() => _TempSettingPageState();
}

class _TempSettingPageState extends State<TempSettingPage> {
  double _maxTemp = 20; // Default starting temperature

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Temperature Setting"),
      ),
      body: Center(
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 75,
              startAngle: 120,
              endAngle: 270,
             // showTicks: true,
              showLabels: true,
              radiusFactor: 0.7,
              interval: 10,
              labelFormat: "{value}°C",
              axisLineStyle: AxisLineStyle(
                //thickness: 30,
                cornerStyle: CornerStyle.bothCurve,
                color: Colors.grey.shade300,
              ),
              pointers: <GaugePointer>[
                RangePointer(
                  value: _maxTemp,
                  cornerStyle: CornerStyle.bothCurve,
                  width: 12,
                  sizeUnit: GaugeSizeUnit.logicalPixel,
                  color: Colors.amber,
                ),
                MarkerPointer(
                  value: _maxTemp,
                  enableDragging: true,
                  onValueChanged: (value) {
                    setState(() {
                      _maxTemp = value;
                    });
                  },
                  markerHeight: 30,
                  markerWidth: 30,
                  markerType: MarkerType.circle,
                  borderWidth: 2,
                  borderColor: Colors.white,
                ),
              ],
              annotations: [
                GaugeAnnotation(
                    angle: 90,
                    axisValue: 5,
                    positionFactor:0.1,
                    widget: Text(
                      "${_maxTemp.ceil().toString()}°C",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}