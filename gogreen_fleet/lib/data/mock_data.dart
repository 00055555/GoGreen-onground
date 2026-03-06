import 'package:flutter/material.dart';


class UserModel {
  final String id;
  final String email;
  final String password;
  final String hubId;
  final String name;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.hubId,
    required this.name,
  });
}

class HubModel {
  final String id;
  final String name;
  final String city;

  HubModel({required this.id, required this.name, required this.city});
}

class VehicleModel {
  final String id;
  final String hubId;
  final String vehicleNumber;
  final String make;
  final String color;
  final String year;

  VehicleModel({
    required this.id,
    required this.hubId,
    required this.vehicleNumber,
    required this.make,
    required this.color,
    required this.year,
  });
}

class IssueModel {
  final String id;
  final String text;

  IssueModel({required this.id, required this.text});
}

// Mock Data
final List<HubModel> mockHubs = [
  HubModel(id: 'hub_mumbai', name: 'Mumbai Hub', city: 'Mumbai'),
  HubModel(id: 'hub_delhi', name: 'Delhi Hub', city: 'Delhi'),
  HubModel(id: 'hub_bangalore', name: 'Bangalore Hub', city: 'Bangalore'),
];

final List<UserModel> mockUsers = [
  UserModel(
    id: 'u1',
    email: 'agent1@gogreen.com',
    password: 'pass123',
    hubId: 'hub_mumbai',
    name: 'Rahul Sharma',
  ),
  UserModel(
    id: 'u2',
    email: 'agent2@gogreen.com',
    password: 'pass123',
    hubId: 'hub_delhi',
    name: 'Priya Singh',
  ),
  UserModel(
    id: 'u3',
    email: 'agent3@gogreen.com',
    password: 'pass123',
    hubId: 'hub_bangalore',
    name: 'Amit Kumar',
  ),
];

final List<VehicleModel> mockVehicles = [
  VehicleModel(id: 'v1', hubId: 'hub_mumbai', vehicleNumber: 'MH 01 AB 1234', make: 'Maruti Swift', color: 'White', year: '2022'),
  VehicleModel(id: 'v2', hubId: 'hub_mumbai', vehicleNumber: 'MH 02 CD 5678', make: 'Honda City', color: 'Silver', year: '2021'),
  VehicleModel(id: 'v3', hubId: 'hub_mumbai', vehicleNumber: 'MH 03 EF 9012', make: 'Hyundai i20', color: 'Red', year: '2023'),
  VehicleModel(id: 'v4', hubId: 'hub_mumbai', vehicleNumber: 'MH 04 GH 3456', make: 'Toyota Innova', color: 'Black', year: '2022'),
  VehicleModel(id: 'v5', hubId: 'hub_delhi', vehicleNumber: 'DL 01 KL 2345', make: 'Tata Nexon', color: 'Blue', year: '2023'),
  VehicleModel(id: 'v6', hubId: 'hub_delhi', vehicleNumber: 'DL 02 MN 6789', make: 'Kia Seltos', color: 'Grey', year: '2022'),
  VehicleModel(id: 'v7', hubId: 'hub_delhi', vehicleNumber: 'DL 03 PQ 0123', make: 'Mahindra XUV700', color: 'White', year: '2023'),
  VehicleModel(id: 'v8', hubId: 'hub_bangalore', vehicleNumber: 'KA 01 RS 4567', make: 'Renault Kwid', color: 'Orange', year: '2021'),
  VehicleModel(id: 'v9', hubId: 'hub_bangalore', vehicleNumber: 'KA 02 TU 8901', make: 'Ford EcoSport', color: 'Dark Grey', year: '2022'),
  VehicleModel(id: 'v10', hubId: 'hub_bangalore', vehicleNumber: 'KA 03 VW 2345', make: 'MG Hector', color: 'Silver', year: '2023'),
];
// Action Types
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
