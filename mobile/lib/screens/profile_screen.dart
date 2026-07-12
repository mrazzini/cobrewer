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
  bool _dirty = false;
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
      if (res.ok) {
        _equipment = List.of(res.data!);
        _dirty = false;
      }
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
      backgroundColor: Palette.cream,
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
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YOUR SETUP'),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Palette.blush));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Palette.creamDim)),
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
        BrutCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Palette.blush,
                shape: BoxShape.circle,
                border: Border.all(color: Palette.ink, width: 2.5),
              ),
              child: const Icon(Icons.person, color: Palette.ink),
            ),
            title: Text(
              (profile.displayName ?? profile.clerkId).toUpperCase(),
              style: const TextStyle(
                  fontFamily: 'Anton',
                  color: Palette.ink,
                  fontSize: 16,
                  letterSpacing: 0.5),
            ),
            subtitle: Text(
              'AI extractions: ${profile.aiCredits.remaining} of '
              '${profile.aiCredits.extractionsLimit} left',
              style: const TextStyle(
                  color: Palette.inkSoft,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
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
                  fontFamily: 'Anton',
                  color: Palette.cream,
                  fontSize: 17,
                  letterSpacing: 1,
                  shadows: [Shadow(color: Palette.ink, offset: Offset(2, 2))],
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _editEquipment(),
              icon: const Icon(Icons.add, size: 18, color: Palette.ink),
              label: const Text('ADD'),
            ),
          ],
        ),
        if (_equipment.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No equipment yet. Add your brewer and grinder so dial-in can use them.',
              style: TextStyle(color: Palette.creamDim, fontSize: 13),
            ),
          ),
        for (var i = 0; i < _equipment.length; i++) ...[
          BrutCard(
            padding: EdgeInsets.zero,
            shadow: 4,
            child: ListTile(
              title: Text(
                [
                  if (_equipment[i].brand?.isNotEmpty ?? false)
                    _equipment[i].brand!,
                  if (_equipment[i].model?.isNotEmpty ?? false)
                    _equipment[i].model!,
                ].join(' '),
                style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                [
                  _equipment[i].equipmentType,
                  if (_equipment[i].burrType?.isNotEmpty ?? false)
                    '${_equipment[i].burrType} burrs',
                ].join(' · '),
                style: const TextStyle(
                    color: Palette.inkSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              onTap: () => _editEquipment(existing: _equipment[i], index: i),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Palette.inkSoft),
                onPressed: () => setState(() {
                  _equipment.removeAt(i);
                  _dirty = true;
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        if (_dirty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Unsaved changes',
              style: TextStyle(
                  color: Palette.cream,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'SAVING…' : 'SAVE EQUIPMENT'),
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
  String? _validationError;

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
            widget.existing == null ? 'ADD EQUIPMENT' : 'EDIT EQUIPMENT',
            style: const TextStyle(
                fontFamily: 'Anton',
                color: Palette.ink,
                fontSize: 18,
                letterSpacing: 0.8),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            style: const TextStyle(
                color: Palette.ink,
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w600,
                fontSize: 15),
            dropdownColor: Palette.cream,
            items: [
              for (final t in _equipmentTypes)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _brandController,
            style: const TextStyle(
                color: Palette.ink, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(labelText: 'Brand'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _modelController,
            style: const TextStyle(
                color: Palette.ink, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(labelText: 'Model'),
          ),
          if (_type == 'grinder') ...[
            const SizedBox(height: 10),
            TextField(
              controller: _burrController,
              style: const TextStyle(
                  color: Palette.ink, fontWeight: FontWeight.w500),
              decoration:
                  const InputDecoration(labelText: 'Burr type (conical/flat)'),
            ),
          ],
          if (_validationError != null) ...[
            const SizedBox(height: 10),
            Text(
              _validationError!,
              style: const TextStyle(color: Palette.blushDeep, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final brand = _brandController.text.trim();
              final model = _modelController.text.trim();
              if (brand.isEmpty && model.isEmpty) {
                setState(() =>
                    _validationError = 'Give it at least a brand or a model.');
                return;
              }
              Navigator.pop(
                context,
                Equipment(
                  equipmentType: _type,
                  brand: brand.isEmpty ? null : brand,
                  model: model.isEmpty ? null : model,
                  burrType: _type == 'grinder' &&
                          _burrController.text.trim().isNotEmpty
                      ? _burrController.text.trim()
                      : null,
                ),
              );
            },
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }
}
