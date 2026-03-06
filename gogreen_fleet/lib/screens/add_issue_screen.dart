import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'vehicle_inspection_screen.dart' show IssueItem;

class AddIssueScreen extends StatefulWidget {
  final Color actionColor;
  
  const AddIssueScreen({Key? key, required this.actionColor}) : super(key: key);

  @override
  State<AddIssueScreen> createState() => _AddIssueScreenState();
}

class _AddIssueScreenState extends State<AddIssueScreen> {
  final _descController = TextEditingController();
  final _picker = ImagePicker();
  String _issueType = 'Damage';
  final List<String> _issueTypes = ['Damage', 'Malfunction', 'Missing Part', 'Scratch/Dent', 'Other'];
  List<XFile> _photos = [];

  void _saveIssue() {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please enter a description.'), backgroundColor: const Color(0xFF1A2744)),
      );
      return;
    }
    
    final issue = IssueItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _issueType,
      description: _descController.text.trim(),
      photos: List.from(_photos),
    );
    Navigator.pop(context, issue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        title: const Text('Add Issue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A2744),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Issue Type', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _issueTypes.map((type) {
                final isSelected = _issueType == type;
                return GestureDetector(
                  onTap: () => setState(() => _issueType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF59E0B).withAlpha(50) : const Color(0xFF1A2744),
                      border: Border.all(color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF2D3F6B)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(type, style: TextStyle(color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF9CA3AF), fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Description', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Describe the issue or damage in detail...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true, fillColor: const Color(0xFF1A2744),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: widget.actionColor, width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Photos / Videos', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                if (img != null) setState(() => _photos.add(img));
              },
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text('Capture Media', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3F6B),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (_photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('${_photos.length} item(s) captured', style: const TextStyle(color: Color(0xFF22C55E), fontSize: 13, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveIssue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save Issue ✓', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
