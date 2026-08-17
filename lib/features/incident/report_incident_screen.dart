import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/sentinel_button.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Report Incident'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sentinelBlue),
            ),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.sentinelBlue,
                  ),
                ),
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 4) {
                      setState(() => _currentStep += 1);
                    } else {
                      // Submit
                      context.pop();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep -= 1);
                    } else {
                      context.pop();
                    }
                  },
                  controlsBuilder: (BuildContext context, ControlsDetails details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SentinelButton(
                              label: _currentStep == 4 ? 'Submit Report' : 'Continue',
                              onPressed: details.onStepContinue!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (_currentStep > 0)
                            Expanded(
                              child: SentinelButton(
                                label: 'Back',
                                isGhost: true,
                                onPressed: details.onStepCancel!,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('Location & Time'),
                      content: Column(
                        children: [
                          TextField(
                            decoration: const InputDecoration(labelText: 'Incident Location', prefixIcon: Icon(Icons.location_on)),
                            controller: TextEditingController(text: 'Current Location'),
                          ),
                          const SizedBox(height: 16),
                          const TextField(
                            decoration: InputDecoration(labelText: 'Time of Incident', prefixIcon: Icon(Icons.access_time)),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                    ),
                    Step(
                      title: const Text('Incident Details'),
                      content: Column(
                        children: const [
                          TextField(
                            decoration: InputDecoration(labelText: 'Category', suffixIcon: Icon(Icons.arrow_drop_down)),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(labelText: 'Description'),
                            maxLines: 4,
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 1,
                    ),
                    Step(
                      title: const Text('Evidence Upload'),
                      content: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.sentinelBlue, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.cloud_upload, size: 48, color: AppColors.sentinelBlue),
                              SizedBox(height: 8),
                              Text('Tap to upload photos or videos'),
                            ],
                          ),
                        ),
                      ),
                      isActive: _currentStep >= 2,
                    ),
                    Step(
                      title: const Text('AI Classification Preview'),
                      content: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: const Border(left: BorderSide(color: AppColors.aiHorizon, width: 4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AI Analysis Complete', style: TextStyle(color: AppColors.aiHorizon, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('Category: Suspicious Activity'),
                            const Text('Severity: Medium'),
                            const SizedBox(height: 8),
                            Text('AI recommendations are suggestions and are not verified facts.', 
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                          ],
                        ),
                      ),
                      isActive: _currentStep >= 3,
                    ),
                    Step(
                      title: const Text('Submit Confirmation'),
                      content: const Text('By submitting this report, you confirm that the information provided is accurate to the best of your knowledge. False reporting may result in account suspension.'),
                      isActive: _currentStep >= 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
