import 'package:flutter/material.dart';

class OrderStatusStepper extends StatelessWidget {
  final String status;
  const OrderStatusStepper({super.key, required this.status});

  int get step {
    switch (status) {
      case "Pending":
        return 0;
      case "Processing":
        return 1;
      case "Shipped":
        return 2;
      case "Delivered":
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: step,
      controlsBuilder: (_, __) => const SizedBox(),
      steps: const [
        Step(title: Text("Pending"), content: SizedBox()),
        Step(title: Text("Processing"), content: SizedBox()),
        Step(title: Text("Shipped"), content: SizedBox()),
        Step(title: Text("Delivered"), content: SizedBox()),
      ],
    );
  }
}
