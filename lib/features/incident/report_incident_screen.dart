import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/sentinel_button.dart';
import '../../data/services/database_service.dart';
import '../../data/services/location_service.dart';
import '../../data/models/incident_model.dart';
import '../../data/models/incident_ai_analysis.dart';
import '../../data/services/ai_service.dart';

class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _isAnalyzingAI = false;
  IncidentAIAnalysis? _aiAnalysis;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Suspicious Activity';

  final List<String> _categories = [
    'Suspicious Activity',
    'Theft',
    'Harassment',
    'Road Accident',
    'Fire Hazard',
    'Missing Person',
    'Public Hazard',
    'Medical Emergency'
  ];

  @override
  void initState() {
    super.initState();
    // Ensure we have location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationServiceProvider.notifier).initializeAndGetLocation();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to report an incident.')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a title and description.')),
      );
      return;
    }

    final locationState = ref.read(locationServiceProvider);
    if (locationState.position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location is required.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final incident = IncidentModel(
        id: const Uuid().v4(),
        type: _selectedCategory.toLowerCase().replaceAll(' ', '_'),
        title: title,
        description: description,
        latitude: locationState.position!.latitude,
        longitude: locationState.position!.longitude,
        reportedBy: user.uid,
        severity: _aiAnalysis != null ? IncidentModel.parseSeverity(_aiAnalysis!.severity) : IncidentSeverity.medium,
        status: IncidentStatus.pending,
        verificationStatus: VerificationStatus.pending,
        timestamp: DateTime.now(),
        aiAnalysis: _aiAnalysis,
      );

      await ref.read(databaseServiceProvider).reportIncident(incident);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your incident has been submitted for verification.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationServiceProvider);
    
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
                  onStepContinue: () async {
                    if (_currentStep == 2) {
                      setState(() {
                        _currentStep += 1;
                        _isAnalyzingAI = true;
                      });
                      try {
                        final title = _titleController.text.trim();
                        final desc = _descriptionController.text.trim();
                        
                        List<IncidentModel>? existingIncidents;
                        try {
                          final dbService = ref.read(databaseServiceProvider);
                          final locationState = ref.read(locationServiceProvider);
                          if (locationState.position != null) {
                            existingIncidents = await dbService.getNearbyIncidents(
                              locationState.position!.latitude, 
                              locationState.position!.longitude, 
                              10.0 // 10km radius
                            ).first;
                          }
                        } catch (e) {
                          debugPrint('Could not fetch existing incidents for comparison: \$e');
                        }

                        _aiAnalysis = await ref.read(aiServiceProvider).analyzeIncident(title, desc, _selectedCategory, existingIncidents);
                      } catch (e) {
                        debugPrint('AI Analysis Failed: \$e');
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isAnalyzingAI = false;
                          });
                        }
                      }
                    } else if (_currentStep < 4) {
                      setState(() => _currentStep += 1);
                    } else {
                      _submitReport();
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
                              label: _isSubmitting ? 'Submitting...' : (_currentStep == 4 ? 'Submit Report' : 'Continue'),
                              onPressed: _isSubmitting ? () {} : details.onStepContinue!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (_currentStep > 0)
                            Expanded(
                              child: SentinelButton(
                                label: 'Back',
                                isGhost: true,
                                onPressed: _isSubmitting ? () {} : details.onStepCancel!,
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
                            controller: TextEditingController(
                              text: locationState.position != null 
                                  ? '\${locationState.position!.latitude.toStringAsFixed(4)}, \${locationState.position!.longitude.toStringAsFixed(4)}'
                                  : 'Locating...',
                            ),
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(labelText: 'Time of Incident', prefixIcon: Icon(Icons.access_time)),
                            controller: TextEditingController(text: 'Now'),
                            readOnly: true,
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                    ),
                    Step(
                      title: const Text('Incident Details'),
                      content: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: const InputDecoration(labelText: 'Category'),
                            items: _categories.map((String category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(labelText: 'Short Title'),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(labelText: 'Description'),
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
                        child: _isAnalyzingAI
                          ? const Center(child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ))
                          : _aiAnalysis != null ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AI Analysis Complete', style: TextStyle(color: AppColors.aiHorizon, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Category: \${_aiAnalysis!.category} (\${_aiAnalysis!.subCategory})'),
                            Text('Severity: \${_aiAnalysis!.severity.toUpperCase()}'),
                            Text('Priority: \${_aiAnalysis!.priority.toUpperCase()}'),
                            Text('Risk Level: \${_aiAnalysis!.riskLevel}'),
                            Text('Confidence: \${(_aiAnalysis!.confidence * 100).toStringAsFixed(1)}%'),
                            const SizedBox(height: 8),
                            const Text('AI Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(_aiAnalysis!.summary),
                            if (_aiAnalysis!.duplicateStatus == 'POSSIBLY_DUPLICATE' || _aiAnalysis!.duplicateStatus == 'LIKELY_DUPLICATE') ...[
                               const SizedBox(height: 12),
                               Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(
                                   color: Colors.orange.withValues(alpha: 0.2),
                                   borderRadius: BorderRadius.circular(8),
                                   border: Border.all(color: Colors.orange),
                                 ),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     const Text('SIMILAR INCIDENT DETECTED', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                     const SizedBox(height: 4),
                                     Text('Status: ' + _aiAnalysis!.duplicateStatus.replaceAll('_', ' ')),
                                     const SizedBox(height: 4),
                                     const Text('A very similar incident was recently reported. You may still submit this report, but it will be flagged for review.', style: TextStyle(fontSize: 12)),
                                   ]
                                 )
                               )
                            ],
                            const SizedBox(height: 12),
                            Text('AI recommendations are suggestions and are not verified facts.', 
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                          ],
                        ) : const Text('AI Analysis failed. You can still submit the report.'),
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
