import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/database_service.dart';
import '../../data/models/trusted_contact_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class TrustedContactsScreen extends ConsumerStatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  ConsumerState<TrustedContactsScreen> createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends ConsumerState<TrustedContactsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _relationship = 'Family';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showAddContactDialog() {
    _nameController.clear();
    _phoneController.clear();
    _relationship = 'Family';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Trusted Contact',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _relationship,
                  items: ['Family', 'Friend', 'Colleague', 'Other']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _relationship = val);
                  },
                  decoration: const InputDecoration(labelText: 'Relationship'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      final contact = TrustedContactModel(
                        id: const Uuid().v4(),
                        ownerId: user.uid,
                        name: _nameController.text.trim(),
                        phone: _phoneController.text.trim(),
                        relationship: _relationship,
                        isEmergencyDefault: false,
                      );

                      await ref.read(databaseServiceProvider).addTrustedContact(contact);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('SAVE CONTACT'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(trustedContactsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        backgroundColor: AppColors.sentinelBlue,
        child: const Icon(Icons.person_add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Manage contacts who receive your safety check-ins and emergency alerts.'),
            ),
            Expanded(
              child: contactsAsync.when(
                data: (contacts) {
                  if (contacts.isEmpty) {
                    return const Center(
                      child: Text('No trusted contacts added yet.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Dismissible(
                          key: Key(contact.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            ref.read(databaseServiceProvider).deleteTrustedContact(contact.id);
                          },
                          child: SwitchListTile(
                            secondary: CircleAvatar(
                              child: Text(
                                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                              ),
                            ),
                            title: Text(contact.name),
                            subtitle: Text('${contact.relationship} • ${contact.phone}'),
                            value: contact.isEmergencyDefault,
                            onChanged: (val) {
                              ref.read(databaseServiceProvider).updateTrustedContact(
                                contact.copyWith(isEmergencyDefault: val),
                              );
                            },
                            activeThumbColor: AppColors.sentinelBlue,
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error loading contacts: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

