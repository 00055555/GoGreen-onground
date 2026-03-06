import 'package:flutter/material.dart';
import '../data/mock_data.dart' hide ActionType;
import 'dashboard_screen.dart';
import 'vehicle_inspection_screen.dart';

class VehicleListScreen extends StatefulWidget {
  final HubModel hub;
  final UserModel user;
  final ActionType actionType;

  const VehicleListScreen({super.key, required this.hub, required this.user, required this.actionType});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final _searchController = TextEditingController();
  String _searchText = '';

  List<VehicleModel> get _filtered {
    final hubVehicles = mockVehicles.where((v) => v.hubId == widget.hub.id).toList();
    if (_searchText.isEmpty) return hubVehicles;
    return hubVehicles.where((v) =>
      v.vehicleNumber.toLowerCase().contains(_searchText.toLowerCase()) ||
      v.make.toLowerCase().contains(_searchText.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1628),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2D3F6B)),
                      ),
                      child: const Text('← Back', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(widget.actionType.icon, style: const TextStyle(fontSize: 20)),
                        Text(widget.actionType.label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                      ],
                    ),
                  ),
                  Text('📍 ${widget.hub.city}', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) => setState(() => _searchText = v),
                    decoration: InputDecoration(
                      hintText: 'Search by vehicle number or model...',
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                      suffixIcon: _searchText.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)), onPressed: () { _searchController.clear(); setState(() => _searchText = ''); })
                        : null,
                      filled: true,
                      fillColor: const Color(0xFF1A2744),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3F6B))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${_filtered.length} vehicle${_filtered.length != 1 ? 's' : ''} found',
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                ],
              ),
            ),

            // Vehicle List
            Expanded(
              child: _filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🚫', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text('No vehicles found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                        Text('Try adjusting your search', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final vehicle = _filtered[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => VehicleInspectionScreen(
                            vehicle: vehicle,
                            actionType: widget.actionType,
                            hub: widget.hub,
                            user: widget.user,
                          ),
                        )),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2744),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2D3F6B)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A1628),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: color, width: 2),
                                ),
                                child: const Center(child: Text('🚗', style: TextStyle(fontSize: 24))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(vehicle.vehicleNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
                                    const SizedBox(height: 2),
                                    Text(vehicle.make, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _Tag(vehicle.color),
                                        const SizedBox(width: 6),
                                        _Tag(vehicle.year),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                                child: const Text('Select →', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2D3F6B)),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
    );
  }
}
