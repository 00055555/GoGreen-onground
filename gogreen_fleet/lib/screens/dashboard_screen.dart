import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'vehicle_list_screen.dart';

class ActionType {
  final String id;
  final String label;
  final String icon;
  final String description;
  final Color color;
  final Color bgColor;

  const ActionType({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
    required this.color,
    required this.bgColor,
  });
}

const actionTypes = [
  ActionType(id: 'service_in', label: 'Service In', icon: '🔧', description: 'Vehicle arriving for service', color: Color(0xFF3B82F6), bgColor: Color(0xFF1E3A5F)),
  ActionType(id: 'service_out', label: 'Service Out', icon: '✅', description: 'Vehicle leaving after service', color: Color(0xFF22C55E), bgColor: Color(0xFF1B4332)),
  ActionType(id: 'inventory_in', label: 'Inventory In', icon: '📦', description: 'Vehicle added to inventory', color: Color(0xFFF59E0B), bgColor: Color(0xFF3D2A00)),
  ActionType(id: 'inventory_out', label: 'Inventory Out', icon: '🚚', description: 'Vehicle removed from inventory', color: Color(0xFFEF4444), bgColor: Color(0xFF3B1A1A)),
];

class DashboardScreen extends StatelessWidget {
  final UserModel user;
  final HubModel hub;

  const DashboardScreen({super.key, required this.user, required this.hub});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final hubVehicles = mockVehicles.where((v) => v.hubId == hub.id).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1A2744),
                border: Border(bottom: BorderSide(color: Color(0xFF2D3F6B))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_getGreeting()}, 👋', style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                        const SizedBox(height: 2),
                        Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B4332),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF22C55E)),
                          ),
                          child: Text('📍 ${hub.name}', style: const TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const _LogoutPlaceholder())),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B1A1A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEF4444)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.power_settings_new, color: Color(0xFFEF4444), size: 20),
                          SizedBox(height: 2),
                          Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stats Row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _StatCard(value: '$hubVehicles', label: 'Vehicles'),
                  const SizedBox(width: 10),
                  _StatCard(value: 'Mar 04', label: 'Today'),
                  const SizedBox(width: 10),
                  const _StatCard(value: 'Active', label: 'Status'),
                ],
              ),
            ),

            // Actions
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Action Type', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('What would you like to record?', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: actionTypes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final action = actionTypes[i];
                          return _ActionCard(
                            action: action,
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => VehicleListScreen(hub: hub, user: user, actionType: action),
                            )),
                          );
                        },
                      ),
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

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2744),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D3F6B)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF22C55E))),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final ActionType action;
  final VoidCallback onTap;
  const _ActionCard({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: action.bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: action.color, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(action.icon, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action.label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: action.color)),
                  const SizedBox(height: 2),
                  Text(action.description, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: action.color, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.arrow_forward, color: Colors.white, size: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for logout to go back to login
class _LogoutPlaceholder extends StatelessWidget {
  const _LogoutPlaceholder();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const _LoginRedirect()),
        (r) => false,
      );
    });
    return const Scaffold(backgroundColor: Color(0xFF0A1628));
  }
}

class _LoginRedirect extends StatelessWidget {
  const _LoginRedirect();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Color(0xFF0A1628));
  }
}
