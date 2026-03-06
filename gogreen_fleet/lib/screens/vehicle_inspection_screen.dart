import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/mock_data.dart' hide ActionType;
import 'login_screen.dart';
import 'dashboard_screen.dart';

class PhotoAngle {
  final String id;
  final String label;
  final String icon;
  const PhotoAngle({required this.id, required this.label, required this.icon});
}

const photoAngles = [
  PhotoAngle(id: 'front', label: 'Front View', icon: '🚗'),
  PhotoAngle(id: 'left_view', label: 'Left View', icon: '🚙'),
  PhotoAngle(id: 'backdoor_left', label: 'Backdoor Left View', icon: '🚪'),
  PhotoAngle(id: 'rear_view', label: 'Rear View', icon: '🔙'),
  PhotoAngle(id: 'backdoor_right', label: 'Backdoor Right View', icon: '🚪'),
  PhotoAngle(id: 'right_front_door', label: 'Right Front Door', icon: '🚪'),
  PhotoAngle(id: 'bonnet', label: 'Bonnet', icon: '🚘'),
  PhotoAngle(id: 'stepney', label: 'Stepney', icon: '🛞'),
  PhotoAngle(id: 'interior_1', label: 'Interior Photo 1', icon: '💺'),
  PhotoAngle(id: 'interior_2', label: 'Interior Photo 2', icon: '💺'),
  PhotoAngle(id: 'odo_reading', label: 'Odometer Reading', icon: '🔢'),
];

class VehicleInspectionScreen extends StatefulWidget {
  final VehicleModel vehicle;
  final ActionType actionType;
  final HubModel hub;
  final UserModel user;

  const VehicleInspectionScreen({
    super.key,
    required this.vehicle,
    required this.actionType,
    required this.hub,
    required this.user,
  });

  @override
  State<VehicleInspectionScreen> createState() => _VehicleInspectionScreenState();
}

class IssueItem {
  final String id;
  final String type;
  final String description;
  final List<XFile> photos;
  IssueItem({required this.id, required this.type, required this.description, this.photos = const []});
}

class _VehicleInspectionScreenState extends State<VehicleInspectionScreen> {
  final _driverController = TextEditingController();
  final _odoController = TextEditingController();
  final _issueController = TextEditingController();
  final _remarkController = TextEditingController();
  final _picker = ImagePicker();

  String _purposeOfRide = 'B2B';
  final List<String> _purposes = ['B2B', 'B2C', 'Station Shifting'];

  List<IssueItem> _issues = [];
  String _issueType = 'Damage';
  final List<String> _issueTypes = ['Damage', 'Malfunction', 'Missing Part', 'Scratch/Dent', 'Other'];
  List<XFile> _tempIssuePhotos = [];

  final Map<String, String> _exteriorChecks = {
    'Wiper water spray': 'Ok',
    'Headlight': 'Ok',
    'Tailight': 'Ok',
    'Stepney Tyre': 'Ok',
    'Tyres': 'Ok',
  };

  final Map<String, String> _accessoryChecks = {
    'Mobile Stand': 'Ok',
    'Tissue': 'Ok',
    'Perfume': 'Ok',
  };

  String _chargingType = 'AC Fast Charging';

  // Store XFile objects so we work cross-platform (web + mobile)
  Map<String, List<XFile>> _photos = {};
  bool _showIssueInput = false;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  int get _totalPhotos =>
      _photos.values.fold(0, (sum, list) => sum + list.length);

  Future<void> _pickContinuousPhotos() async {
    for (var i = 0; i < photoAngles.length; i++) {
      final angle = photoAngles[i];
      if ((_photos[angle.id] ?? []).isNotEmpty) continue;

      bool? proceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A2744),
          title: Text('${angle.icon} ${angle.label}', style: const TextStyle(color: Colors.white)),
          content: Text('Take the ${angle.label} now?', style: const TextStyle(color: Color(0xFF9CA3AF))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFFEF4444)))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: widget.actionType.color),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))
            ),
          ],
        )
      );

      if (proceed != true) break;

      final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (img != null) {
        setState(() => _photos.update(angle.id, (l) => [...l, img], ifAbsent: () => [img]));
      } else {
        break; // Cancelled
      }
    }
  }

  Future<void> _pickPhoto(String angleId) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2744),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Photo',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 20),
            if (!kIsWeb)
              _PhotoOption(
                icon: Icons.camera_alt,
                label: 'Take Photo',
                color: widget.actionType.color,
                onTap: () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(
                      source: ImageSource.camera, imageQuality: 85);
                  if (img != null)
                    setState(() => _photos.update(angleId, (l) => [...l, img],
                        ifAbsent: () => [img]));
                },
              ),
            if (!kIsWeb) const SizedBox(height: 12),
            _PhotoOption(
              icon: Icons.photo_library,
              label: 'Choose from Gallery',
              color: widget.actionType.color,
              onTap: () async {
                Navigator.pop(context);
                final imgs = await _picker.pickMultiImage(imageQuality: 85);
                if (imgs.isNotEmpty) {
                  setState(() {
                    for (final img in imgs) {
                      _photos.update(angleId, (l) => [...l, img],
                          ifAbsent: () => [img]);
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _addIssue() {
    if (_issueController.text.trim().isNotEmpty) {
      setState(() {
        _issues.add(IssueItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: _issueType,
            description: _issueController.text.trim(),
            photos: List.from(_tempIssuePhotos)));
        _issueController.clear();
        _tempIssuePhotos.clear();
        _showIssueInput = false;
      });
    }
  }

  void _submit() {
    if (_driverController.text.trim().isEmpty) {
      _showSnack('Please enter the driver name.');
      return;
    }
    if (_odoController.text.trim().isEmpty) {
      _showSnack('Please enter the ODO reading.');
      return;
    }
    if (_totalPhotos == 0) {
      _showSnack('Please add at least one photo.');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2744),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Submission',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Submit ${widget.actionType.label} for ${widget.vehicle.vehicleNumber}?\n\nDriver: ${_driverController.text}\nPurpose: $_purposeOfRide\nODO: ${_odoController.text} km\nIssues: ${_issues.length}\nPhotos: $_totalPhotos\nRemark: ${_remarkController.text.isEmpty ? 'None' : _remarkController.text}',
          style: const TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF9CA3AF)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: widget.actionType.color),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isSubmitting = true);
              Future.delayed(const Duration(milliseconds: 1500), () {
                setState(() {
                  _isSubmitting = false;
                  _isSubmitted = true;
                });
              });
            },
            child: const Text('Submit ✓',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF1A2744),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) return _buildSuccessScreen();
    final color = widget.actionType.color;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1A2744),
                border: Border(bottom: BorderSide(color: Color(0xFF2D3F6B))),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: const Color(0xFF0A1628),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF2D3F6B))),
                      child: const Text('← Back',
                          style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color)),
                        child: Text(
                            '${widget.actionType.icon} ${widget.actionType.label}',
                            style: TextStyle(
                                color: color,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 70),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildVehicleCard(color),
                    const SizedBox(height: 16),
                    _buildDriverSection(),
                    const SizedBox(height: 16),
                    _buildChecklistSection(color),
                    const SizedBox(height: 16),
                    _buildPhotosSection(color),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 8,
                          shadowColor: color.withOpacity(0.5),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(widget.actionType.icon,
                                      style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 10),
                                  Text('Submit ${widget.actionType.label}',
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1A2744),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2D3F6B))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🚗', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.vehicle.vehicleNumber,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(
                        '${widget.vehicle.make} • ${widget.vehicle.color} • ${widget.vehicle.year}',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: color)),
                      child: Text('📍 ${widget.hub.name}',
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Add Issue
          GestureDetector(
            onTap: () => setState(() => _showIssueInput = true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFF3D2A00),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF59E0B))),
              child: const Center(
                  child: Text('⚠️  Add Issue / Damage Note',
                      style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600))),
            ),
          ),

          if (_showIssueInput) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF0A1628), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFF59E0B))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Issue Type', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _issueTypes.map((type) {
                        final isSelected = _issueType == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _issueType = type),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFF59E0B).withAlpha(50) : Colors.transparent,
                                border: Border.all(color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF2D3F6B)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(type, style: TextStyle(color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF9CA3AF), fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _issueController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Description of issue...',
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                      filled: true, fillColor: const Color(0xFF1A2744),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                          if (img != null) setState(() => _tempIssuePhotos.add(img));
                        },
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: const Text('Add Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D3F6B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_tempIssuePhotos.isNotEmpty)
                        Text('${_tempIssuePhotos.length} photo(s)', style: const TextStyle(color: Color(0xFF22C55E), fontSize: 12, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setState(() { _showIssueInput = false; _issueController.clear(); _tempIssuePhotos.clear(); }),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF9CA3AF))),
                      ),
                      ElevatedButton(
                        onPressed: _addIssue,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black),
                        child: const Text('Save Issue', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          if (_issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFF0A1628),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2D3F6B))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Issues Noted (${_issues.length}):',
                      style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  ..._issues.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.key + 1}.',
                                style: const TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.value.type, style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(e.value.description, style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 13)),
                                  if (e.value.photos.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text('${e.value.photos.length} photo(s) attached', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                                  ]
                                ],
                              ),
                            ),
                            GestureDetector(
                                onTap: () => setState(() => _issues
                                    .removeWhere((i) => i.id == e.value.id)),
                                child: const Icon(Icons.close,
                                    color: Color(0xFFEF4444), size: 18)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2D3F6B), height: 1),
          const SizedBox(height: 16),

          // Purpose of Ride
          const Text('🎯  Purpose of Ride *',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF))),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _purposes.map((purpose) {
                final isSelected = _purposeOfRide == purpose;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _purposeOfRide = purpose),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withAlpha(50)
                            : const Color(0xFF0A1628),
                        border: Border.all(
                            color: isSelected ? color : const Color(0xFF2D3F6B),
                            width: isSelected ? 2 : 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        purpose,
                        style: TextStyle(
                          color: isSelected ? color : const Color(0xFF9CA3AF),
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistSection(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2744), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2D3F6B))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✅  Inspection Checklist', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          const Text('Exterior', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._exteriorChecks.keys.map((key) => _buildCheckRow(key, _exteriorChecks, color)),
          const SizedBox(height: 16),
          const Text('Accessories', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._accessoryChecks.keys.map((key) => _buildCheckRow(key, _accessoryChecks, color)),
          
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2D3F6B), height: 1),
          const SizedBox(height: 16),
          const Text('🔌  Charging Type', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: ['AC Fast Charging', 'DC Charging'].map((cType) {
              final isSelected = _chargingType == cType;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _chargingType = cType),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withAlpha(50) : const Color(0xFF0A1628),
                        border: Border.all(color: isSelected ? color : const Color(0xFF2D3F6B), width: isSelected ? 2 : 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          cType,
                          style: TextStyle(
                            color: isSelected ? color : const Color(0xFF9CA3AF),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String label, Map<String, String> map, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 14))),
          Row(
            children: ['Ok', 'Issue'].map((status) {
              final isOk = status == 'Ok';
              final isSelected = map[label] == status;
              final activeColor = isOk ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
              return GestureDetector(
                onTap: () => setState(() => map[label] = status),
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor.withAlpha(40) : const Color(0xFF0A1628),
                    border: Border.all(color: isSelected ? activeColor : const Color(0xFF2D3F6B)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isSelected ? activeColor : const Color(0xFF9CA3AF),
                      fontSize: 12, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1A2744),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2D3F6B))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Driver & Vehicle Details',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 16),
          const Text('👤  Driver Name *',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF))),
          const SizedBox(height: 8),
          TextField(
            controller: _driverController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter driver's full name",
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFF0A1628),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: widget.actionType.color, width: 2)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),
          const Text('📏  ODO Reading (km) *',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF))),
          const SizedBox(height: 8),
          TextField(
            controller: _odoController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. 45230',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFF0A1628),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: widget.actionType.color, width: 2)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),
          const Text('📝  Driver Remark (Optional)',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF))),
          const SizedBox(height: 8),
          TextField(
            controller: _remarkController,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Any additional remarks...',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFF0A1628),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: widget.actionType.color, width: 2)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1A2744),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2D3F6B))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📸  Vehicle Photos',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFF1B4332),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF22C55E))),
                child: Text('$_totalPhotos photos',
                    style: const TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Capture photos from all angles',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 16),
          if (!kIsWeb) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickContinuousPhotos,
                icon: const Icon(Icons.cameraswitch, color: Colors.white),
                label: const Text('Continuous Photo Capture', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.actionType.color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...photoAngles.map((angle) => _buildAngleSection(angle, color)),
        ],
      ),
    );
  }

  Widget _buildAngleSection(PhotoAngle angle, Color color) {
    final anglePhotos = _photos[angle.id] ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D3F6B))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(angle.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(angle.label,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE5E7EB)))),
              Text(
                  '${anglePhotos.length} photo${anglePhotos.length != 1 ? 's' : ''}',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          ),
          if (anglePhotos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: anglePhotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Photo thumbnail - works on both web and mobile
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _PhotoThumbnail(xFile: anglePhotos[i]),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          final list = List<XFile>.from(anglePhotos);
                          list.removeAt(i);
                          _photos[angle.id] = list;
                        }),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                              color: Color(0xFFEF4444), shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _pickPhoto(angle.id),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color, width: 1.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                      anglePhotos.isNotEmpty ? 'Add More Photos' : 'Take Photo',
                      style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2744),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF22C55E)),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF22C55E).withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 2)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✅', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  const Text('Submitted!',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF22C55E))),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.actionType.label} for ${widget.vehicle.vehicleNumber} has been recorded successfully.',
                    style:
                        const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: const Color(0xFF0A1628),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2D3F6B))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🚗 ${widget.vehicle.vehicleNumber}',
                            style: const TextStyle(
                                color: Color(0xFFE5E7EB), fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('👤 ${_driverController.text}',
                            style: const TextStyle(
                                color: Color(0xFFE5E7EB), fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('🎯 $_purposeOfRide',
                            style: const TextStyle(
                                color: Color(0xFFE5E7EB), fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('📏 ${_odoController.text} km',
                            style: const TextStyle(
                                color: Color(0xFFE5E7EB), fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('📸 $_totalPhotos photos captured',
                            style: const TextStyle(
                                color: Color(0xFFE5E7EB), fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('⚠️ ${_issues.length} issue(s) noted',
                            style: const TextStyle(
                                color: Color(0xFFE5E7EB), fontSize: 14)),
                        if (_remarkController.text.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('📝 ${_remarkController.text}',
                              style: const TextStyle(
                                  color: Color(0xFFE5E7EB),
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => DashboardScreen(
                                user: widget.user, hub: widget.hub)),
                        (r) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('← Back to Dashboard',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Photo Thumbnail: works on both Web and Mobile ─────────────────────────

class _PhotoThumbnail extends StatefulWidget {
  final XFile xFile;
  const _PhotoThumbnail({required this.xFile});

  @override
  State<_PhotoThumbnail> createState() => _PhotoThumbnailState();
}

class _PhotoThumbnailState extends State<_PhotoThumbnail> {
  late Future<Uint8List> _bytesFuture;

  @override
  void initState() {
    super.initState();
    _bytesFuture = widget.xFile.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytesFuture,
      builder: (_, snap) {
        if (snap.hasData) {
          return Image.memory(snap.data!,
              width: 80, height: 80, fit: BoxFit.cover);
        }
        return Container(
          width: 80,
          height: 80,
          color: const Color(0xFF1A2744),
          child: const Icon(Icons.image, color: Color(0xFF9CA3AF), size: 28),
        );
      },
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PhotoOption(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
