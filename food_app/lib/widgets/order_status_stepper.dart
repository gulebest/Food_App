import 'package:flutter/material.dart';

class OrderStatusStepper extends StatelessWidget {
  final String status;
  const OrderStatusStepper({super.key, required this.status});

  int get step {
    switch (status) {
      case "pending":
        return 0;
      case "preparing":
        return 1;
      case "on_the_way":
        return 2;
      case "delivered":
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
        Step(title: Text("Preparing"), content: SizedBox()),
        Step(title: Text("On the way"), content: SizedBox()),
        Step(title: Text("Delivered"), content: SizedBox()),
      ],
    );
  }
}
