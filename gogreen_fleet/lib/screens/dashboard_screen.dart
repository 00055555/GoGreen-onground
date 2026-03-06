import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'vehicle_list_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;
  final HubModel hub;

  const DashboardScreen({super.key, required this.user, required this.hub});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _shiftStarted = false;
  DateTime? _shiftStartTime;

  static const _bg = Color(0xFF0A1628);
  static const _card = Color(0xFF1A2744);
  static const _border = Color(0xFF2D3F6B);
  static const _green = Color(0xFF22C55E);
  static const _textSecondary = Color(0xFF9CA3AF);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatShiftTime() {
    if (_shiftStartTime == null) return '';
    final h = _shiftStartTime!.hour.toString().padLeft(2, '0');
    final m = _shiftStartTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _toggleShift() {
    if (!_shiftStarted) {
      setState(() {
        _shiftStarted = true;
        _shiftStartTime = DateTime.now();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Shift started! Have a great day.'),
          backgroundColor: const Color(0xFF1B4332),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      _showEndShiftDialog();
    }
  }

  void _showEndShiftDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFEF4444))),
        title: const Row(children: [
          Text('🔴', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('End Shift', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to end your shift?', style: TextStyle(color: _textSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
              child: Row(children: [
                const Icon(Icons.access_time, color: _textSecondary, size: 16),
                const SizedBox(width: 8),
                Text('Shift started at ${_formatShiftTime()}', style: const TextStyle(color: _textSecondary, fontSize: 13)),
              ]),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: _textSecondary, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() { _shiftStarted = false; _shiftStartTime = null; });
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (r) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('OK, End Shift', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(String actionId) {
    final action = actionTypes.firstWhere((a) => a.id == actionId);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => VehicleListScreen(hub: widget.hub, user: widget.user, actionType: action),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hubVehicles = mockVehicles.where((v) => v.hubId == widget.hub.id).length;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ─── HEADER ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: const BoxDecoration(
                  color: _card,
                  border: Border(bottom: BorderSide(color: _border)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_getGreeting()} 👋', style: const TextStyle(fontSize: 13, color: _textSecondary)),
                          const SizedBox(height: 2),
                          Text(widget.user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B4332),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _green),
                            ),
                            child: Text('📍 ${widget.hub.name}', style: const TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (r) => false,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B1A1A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEF4444)),
                        ),
                        child: const Column(children: [
                          Icon(Icons.power_settings_new, color: Color(0xFFEF4444), size: 20),
                          SizedBox(height: 2),
                          Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ─── SHIFT BUTTON ─────────────────────────────
                    GestureDetector(
                      onTap: _toggleShift,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          color: _shiftStarted ? const Color(0xFF3B1A1A) : const Color(0xFF1B4332),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _shiftStarted ? const Color(0xFFEF4444) : _green,
                            width: 2,
                          ),
                          boxShadow: [BoxShadow(
                            color: (_shiftStarted ? const Color(0xFFEF4444) : _green).withOpacity(0.2),
                            blurRadius: 12, offset: const Offset(0, 4),
                          )],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _shiftStarted ? Icons.stop_circle : Icons.play_circle,
                              color: _shiftStarted ? const Color(0xFFEF4444) : _green,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _shiftStarted ? 'End Shift' : 'Start Shift',
                                  style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w800,
                                    color: _shiftStarted ? const Color(0xFFEF4444) : _green,
                                  ),
                                ),
                                Text(
                                  _shiftStarted ? 'Shift started at ${_formatShiftTime()}' : 'Tap to begin your shift',
                                  style: const TextStyle(fontSize: 11, color: _textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── INVENTORY SECTION ─────────────────────────
                    _SectionHeader(title: '📦 Inventory', subtitle: 'Manage vehicle inventory'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionBox(
                            icon: '📥', label: 'Inventory\nIn',
                            color: const Color(0xFFF59E0B), bgColor: const Color(0xFF3D2A00),
                            onTap: () => _navigateTo('inventory_in'), locked: !_shiftStarted,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _VehicleCountBox(count: hubVehicles, hubName: widget.hub.city),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionBox(
                            icon: '📤', label: 'Inventory\nOut',
                            color: const Color(0xFFEF4444), bgColor: const Color(0xFF3B1A1A),
                            onTap: () => _navigateTo('inventory_out'), locked: !_shiftStarted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ─── SERVICE SECTION ───────────────────────────
                    _SectionHeader(title: '🔧 Service', subtitle: 'Manage vehicle service'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionBox(
                            icon: '🔧', label: 'Service\nIn',
                            color: const Color(0xFF3B82F6), bgColor: const Color(0xFF1E3A5F),
                            onTap: () => _navigateTo('service_in'), locked: !_shiftStarted,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionBox(
                            icon: '✅', label: 'Service\nOut',
                            color: _green, bgColor: const Color(0xFF1B4332),
                            onTap: () => _navigateTo('service_out'), locked: !_shiftStarted,
                          ),
                        ),
                      ],
                    ),

                    if (!_shiftStarted) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(12),
                          border: const Border(left: BorderSide(color: Color(0xFFF59E0B), width: 3)),
                        ),
                        child: const Row(children: [
                          Text('⚠️', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 10),
                          Expanded(child: Text(
                            'Please start your shift to access Inventory and Service actions.',
                            style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13),
                          )),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Action Types ──────────────────────────────────────────────────────────

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
  ActionType(id: 'inventory_in', label: 'Inventory In', icon: '📥', description: 'Vehicle added to inventory', color: Color(0xFFF59E0B), bgColor: Color(0xFF3D2A00)),
  ActionType(id: 'inventory_out', label: 'Inventory Out', icon: '📤', description: 'Vehicle removed from inventory', color: Color(0xFFEF4444), bgColor: Color(0xFF3B1A1A)),
];

// ─── Widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          ],
        ),
      ],
    );
  }
}

class _ActionBox extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  final bool locked;

  const _ActionBox({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked
        ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('⚠️ Start your shift first!'),
              backgroundColor: Color(0xFF1A2744),
              behavior: SnackBarBehavior.floating,
            ))
        : onTap,
      child: Opacity(
        opacity: locked ? 0.5 : 1.0,
        child: Container(
          height: 130,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color, height: 1.2)),
              if (locked) ...[
                const SizedBox(height: 4),
                const Icon(Icons.lock, color: Color(0xFF6B7280), size: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleCountBox extends StatelessWidget {
  final int count;
  final String hubName;
  const _VehicleCountBox({required this.count, required this.hubName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2744),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2D3F6B)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🚗', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text('$count', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF22C55E))),
          const Text('All\nVehicles', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), height: 1.2)),
          const SizedBox(height: 2),
          Text(hubName, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}
