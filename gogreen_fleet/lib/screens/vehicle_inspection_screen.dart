import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/mock_data.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class PhotoAngle {
  final String id;
  final String label;
  final String icon;
  const PhotoAngle({required this.id, required this.label, required this.icon});
}

const photoAngles = [
  PhotoAngle(id: 'front', label: 'Front View', icon: '⬆️'),
  PhotoAngle(id: 'rear', label: 'Rear View', icon: '⬇️'),
  PhotoAngle(id: 'left', label: 'Left Side', icon: '⬅️'),
  PhotoAngle(id: 'right', label: 'Right Side', icon: '➡️'),
  PhotoAngle(id: 'dashboard', label: 'Dashboard', icon: '🎛️'),
  PhotoAngle(id: 'odometer', label: 'Odometer', icon: '🔢'),
  PhotoAngle(id: 'additional', label: 'Additional', icon: '📸'),
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

class _VehicleInspectionScreenState extends State<VehicleInspectionScreen> {
  final _driverController = TextEditingController();
  final _odoController = TextEditingController();
  final _issueController = TextEditingController();
  final _picker = ImagePicker();

  List<IssueModel> _issues = [];
  Map<String, List<String>> _photos = {};
  bool _showIssueInput = false;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  int get _totalPhotos => _photos.values.fold(0, (sum, list) => sum + list.length);

  Future<void> _pickPhoto(String angleId) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2744),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 20),
            _PhotoOption(
              icon: Icons.camera_alt,
              label: 'Take Photo',
              color: widget.actionType.color,
              onTap: () async {
                Navigator.pop(context);
                final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                if (img != null) setState(() => _photos.update(angleId, (l) => [...l, img.path], ifAbsent: () => [img.path]));
              },
            ),
            const SizedBox(height: 12),
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
                      _photos.update(angleId, (l) => [...l, img.path], ifAbsent: () => [img.path]);
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
        _issues.add(IssueModel(id: DateTime.now().millisecondsSinceEpoch.toString(), text: _issueController.text.trim()));
        _issueController.clear();
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
        title: const Text('Confirm Submission', style: TextStyle(color: Colors.white)),
        content: Text(
          'Submit ${widget.actionType.label} for ${widget.vehicle.vehicleNumber}?\n\nDriver: ${_driverController.text}\nODO: ${_odoController.text} km\nIssues: ${_issues.length}\nPhotos: $_totalPhotos',
          style: const TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF9CA3AF)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: widget.actionType.color),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isSubmitting = true);
              Future.delayed(const Duration(milliseconds: 1500), () {
                setState(() { _isSubmitting = false; _isSubmitted = true; });
              });
            },
            child: const Text('Submit ✓', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFF0A1628), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF2D3F6B))),
                      child: const Text('← Back', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color),
                        ),
                        child: Text('${widget.actionType.icon} ${widget.actionType.label}',
                          style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 70),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Vehicle Card
                    _buildVehicleCard(color),
                    const SizedBox(height: 16),
                    // Driver Details
                    _buildDriverSection(),
                    const SizedBox(height: 16),
                    // Photos Section
                    _buildPhotosSection(color),
                    const SizedBox(height: 20),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 8,
                          shadowColor: color.withOpacity(0.5),
                        ),
                        child: _isSubmitting
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(widget.actionType.icon, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                Text('Submit ${widget.actionType.label}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
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
        border: Border.all(color: const Color(0xFF2D3F6B)),
      ),
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
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text('${widget.vehicle.make} • ${widget.vehicle.color} • ${widget.vehicle.year}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color),
                      ),
                      child: Text('📍 ${widget.hub.name}', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Add Issue Button
          GestureDetector(
            onTap: () => setState(() => _showIssueInput = true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3D2A00),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: const Center(
                child: Text('⚠️  Add Issue / Damage Note',
                  style: TextStyle(color: Color(0xFFF59E0B), fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ),

          // Issue Input
          if (_showIssueInput) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _issueController,
                    autofocus: true,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Describe the issue or damage...',
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0xFF0A1628),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFF59E0B))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFF59E0B))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2)),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    GestureDetector(
                      onTap: _addIssue,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(10)),
                        child: const Text('Add', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => setState(() { _showIssueInput = false; _issueController.clear(); }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFF1A2744), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF2D3F6B))),
                        child: const Text('✕', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],

          // Issues List
          if (_issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2D3F6B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Issues Noted (${_issues.length}):', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  ..._issues.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${e.key + 1}.', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        Expanded(child: Text(e.value.text, style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 13))),
                        GestureDetector(
                          onTap: () => setState(() => _issues.removeWhere((i) => i.id == e.value.id)),
                          child: const Icon(Icons.close, color: Color(0xFFEF4444), size: 18),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
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
        border: Border.all(color: const Color(0xFF2D3F6B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Driver & Vehicle Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          const Text('👤  Driver Name *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 8),
          TextField(
            controller: _driverController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter driver's full name",
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFF0A1628),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.actionType.color, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),
          const Text('📏  ODO Reading (km) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.actionType.color, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        border: Border.all(color: const Color(0xFF2D3F6B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📸  Vehicle Photos', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF1B4332), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF22C55E))),
                child: Text('$_totalPhotos photos', style: const TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Capture photos from all angles', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 16),
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
        border: Border.all(color: const Color(0xFF2D3F6B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(angle.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(child: Text(angle.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFE5E7EB)))),
              Text('${anglePhotos.length} photo${anglePhotos.length != 1 ? 's' : ''}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          ),

          // Thumbnails
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(anglePhotos[i]), width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: -6, right: -6,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          final list = List<String>.from(anglePhotos);
                          list.removeAt(i);
                          _photos[angle.id] = list;
                        }),
                        child: Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 12),
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
                border: Border.all(color: color, style: BorderStyle.solid, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(anglePhotos.isNotEmpty ? 'Add More Photos' : 'Take Photo',
                    style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
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
                boxShadow: [BoxShadow(color: const Color(0xFF22C55E).withOpacity(0.25), blurRadius: 20, spreadRadius: 2)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✅', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  const Text('Submitted!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF22C55E))),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.actionType.label} for ${widget.vehicle.vehicleNumber} has been recorded successfully.',
                    style: const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF0A1628), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2D3F6B))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🚗 ${widget.vehicle.vehicleNumber}', style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('👤 ${_driverController.text}', style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('📏 ${_odoController.text} km', style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('📸 $_totalPhotos photos captured', style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('⚠️ ${_issues.length} issue(s) noted', style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => DashboardScreen(user: widget.user, hub: widget.hub)),
                        (r) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('← Back to Dashboard', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
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

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PhotoOption({required this.icon, required this.label, required this.color, required this.onTap});

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
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
