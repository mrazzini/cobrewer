import 'package:flutter/material.dart';

import '../api/client.dart';
import '../models/models.dart';
import '../theme.dart';

const _equipmentTypes = ['brewer', 'grinder', 'kettle', 'scale', 'other'];

class ProfileScreen extends StatefulWidget {
  final ApiClient api;

  const ProfileScreen({super.key, required this.api});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  List<Equipment> _equipment = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await widget.api.getMe();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.ok) {
        _profile = res.data;
        _equipment = List.of(res.data!.equipment);
      } else {
        _error = res.error;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final res = await widget.api.updateEquipment(_equipment);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (res.ok) _equipment = List.of(res.data!);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res.ok
            ? 'Equipment saved.'
            : (res.error ?? 'Could not save equipment.')),
      ),
    );
  }

  Future<void> _editEquipment({Equipment? existing, int? index}) async {
    final result = await showModalBottomSheet<Equipment>(
      context: context,
      backgroundColor: CobraColors.surfaceRaised,
      isScrollControlled: true,
      builder: (context) => _EquipmentSheet(existing: existing),
    );
    if (result == null) return;
    setState(() {
      if (index != null) {
        _equipment[index] = result;
      } else {
        _equipment.add(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: CobraColors.green));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: CobraColors.textMuted)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _fetch, child: const Text('Retry')),
          ],
        ),
      );
    }
    final profile = _profile!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: CobraColors.greenDeep,
              child: Icon(Icons.person, color: CobraColors.text),
            ),
            title: Text(
              profile.displayName ?? profile.clerkId,
              style: const TextStyle(
                  color: CobraColors.text, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'AI extractions: ${profile.aiCredits.remaining} of '
              '${profile.aiCredits.extractionsLimit} left',
              style: const TextStyle(color: CobraColors.textMuted, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'MY EQUIPMENT',
                style: TextStyle(
                  color: CobraColors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _editEquipment(),
              icon: const Icon(Icons.add, size: 18, color: CobraColors.green),
              label:
                  const Text('Add', style: TextStyle(color: CobraColors.green)),
            ),
          ],
        ),
        if (_equipment.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No equipment yet. Add your brewer and grinder so dial-in can use them.',
              style: TextStyle(color: CobraColors.textMuted, fontSize: 13),
            ),
          ),
        for (var i = 0; i < _equipment.length; i++) ...[
          Card(
            child: ListTile(
              title: Text(
                [
                  if (_equipment[i].brand?.isNotEmpty ?? false)
                    _equipment[i].brand!,
                  if (_equipment[i].model?.isNotEmpty ?? false)
                    _equipment[i].model!,
                ].join(' '),
                style: const TextStyle(color: CobraColors.text, fontSize: 14),
              ),
              subtitle: Text(
                [
                  _equipment[i].equipmentType,
                  if (_equipment[i].burrType?.isNotEmpty ?? false)
                    '${_equipment[i].burrType} burrs',
                ].join(' · '),
                style: const TextStyle(
                    color: CobraColors.textMuted, fontSize: 12),
              ),
              onTap: () => _editEquipment(existing: _equipment[i], index: i),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: CobraColors.textMuted),
                onPressed: () => setState(() => _equipment.removeAt(i)),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving…' : 'Save equipment'),
        ),
      ],
    );
  }
}

class _EquipmentSheet extends StatefulWidget {
  final Equipment? existing;

  const _EquipmentSheet({this.existing});

  @override
  State<_EquipmentSheet> createState() => _EquipmentSheetState();
}

class _EquipmentSheetState extends State<_EquipmentSheet> {
  late String _type = widget.existing?.equipmentType ?? 'brewer';
  late final _brandController =
      TextEditingController(text: widget.existing?.brand ?? '');
  late final _modelController =
      TextEditingController(text: widget.existing?.model ?? '');
  late final _burrController =
      TextEditingController(text: widget.existing?.burrType ?? '');

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _burrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null ? 'Add equipment' : 'Edit equipment',
            style: const TextStyle(
                color: CobraColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 16),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            dropdownColor: CobraColors.surfaceRaised,
            items: [
              for (final t in _equipmentTypes)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _brandController,
            decoration: const InputDecoration(labelText: 'Brand'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _modelController,
            decoration: const InputDecoration(labelText: 'Model'),
          ),
          if (_type == 'grinder') ...[
            const SizedBox(height: 10),
            TextField(
              controller: _burrController,
              decoration:
                  const InputDecoration(labelText: 'Burr type (conical/flat)'),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                Equipment(
                  equipmentType: _type,
                  brand: _brandController.text.trim().isEmpty
                      ? null
                      : _brandController.text.trim(),
                  model: _modelController.text.trim().isEmpty
                      ? null
                      : _modelController.text.trim(),
                  burrType: _type == 'grinder' &&
                          _burrController.text.trim().isNotEmpty
                      ? _burrController.text.trim()
                      : null,
                ),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
