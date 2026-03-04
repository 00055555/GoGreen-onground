// Data models
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
