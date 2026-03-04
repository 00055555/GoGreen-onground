
// Mock authentication data
export const USERS = [
    {
        id: 'u1',
        email: 'agent1@gogreen.com',
        password: 'pass123',
        hubId: 'hub_mumbai',
        name: 'Rahul Sharma',
    },
    {
        id: 'u2',
        email: 'agent2@gogreen.com',
        password: 'pass123',
        hubId: 'hub_delhi',
        name: 'Priya Singh',
    },
    {
        id: 'u3',
        email: 'agent3@gogreen.com',
        password: 'pass123',
        hubId: 'hub_bangalore',
        name: 'Amit Kumar',
    },
];

// Hub locations
export const HUBS = [
    { id: 'hub_mumbai', name: 'Mumbai Hub', city: 'Mumbai' },
    { id: 'hub_delhi', name: 'Delhi Hub', city: 'Delhi' },
    { id: 'hub_bangalore', name: 'Bangalore Hub', city: 'Bangalore' },
];

// Vehicles assigned to each hub
export const VEHICLES = [
    // Mumbai Hub
    { id: 'v1', hubId: 'hub_mumbai', vehicleNumber: 'MH 01 AB 1234', make: 'Maruti Swift', color: 'White', year: '2022' },
    { id: 'v2', hubId: 'hub_mumbai', vehicleNumber: 'MH 02 CD 5678', make: 'Honda City', color: 'Silver', year: '2021' },
    { id: 'v3', hubId: 'hub_mumbai', vehicleNumber: 'MH 03 EF 9012', make: 'Hyundai i20', color: 'Red', year: '2023' },
    { id: 'v4', hubId: 'hub_mumbai', vehicleNumber: 'MH 04 GH 3456', make: 'Toyota Innova', color: 'Black', year: '2022' },
    // Delhi Hub
    { id: 'v5', hubId: 'hub_delhi', vehicleNumber: 'DL 01 KL 2345', make: 'Tata Nexon', color: 'Blue', year: '2023' },
    { id: 'v6', hubId: 'hub_delhi', vehicleNumber: 'DL 02 MN 6789', make: 'Kia Seltos', color: 'Grey', year: '2022' },
    { id: 'v7', hubId: 'hub_delhi', vehicleNumber: 'DL 03 PQ 0123', make: 'Mahindra XUV700', color: 'White', year: '2023' },
    // Bangalore Hub
    { id: 'v8', hubId: 'hub_bangalore', vehicleNumber: 'KA 01 RS 4567', make: 'Renault Kwid', color: 'Orange', year: '2021' },
    { id: 'v9', hubId: 'hub_bangalore', vehicleNumber: 'KA 02 TU 8901', make: 'Ford EcoSport', color: 'Dark Grey', year: '2022' },
    { id: 'v10', hubId: 'hub_bangalore', vehicleNumber: 'KA 03 VW 2345', make: 'MG Hector', color: 'Silver', year: '2023' },
];
