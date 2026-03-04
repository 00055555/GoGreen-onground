import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { useAuth } from '../context/AuthContext';

import LoginScreen from '../screens/LoginScreen';
import DashboardScreen from '../screens/DashboardScreen';
import VehicleListScreen from '../screens/VehicleListScreen';
import VehicleInspectionScreen from '../screens/VehicleInspectionScreen';

const Stack = createStackNavigator();

export default function AppNavigator() {
    const { user } = useAuth();

    return (
        <NavigationContainer>
            <Stack.Navigator screenOptions={{ headerShown: false }}>
                {!user ? (
                    <Stack.Screen name="Login" component={LoginScreen} />
                ) : (
                    <>
                        <Stack.Screen name="Dashboard" component={DashboardScreen} />
                        <Stack.Screen name="VehicleList" component={VehicleListScreen} />
                        <Stack.Screen name="VehicleInspection" component={VehicleInspectionScreen} />
                    </>
                )}
            </Stack.Navigator>
        </NavigationContainer>
    );
}
