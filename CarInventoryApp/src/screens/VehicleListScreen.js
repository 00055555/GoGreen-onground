import React, { useState } from 'react';
import {
    View,
    Text,
    TouchableOpacity,
    StyleSheet,
    FlatList,
    TextInput,
} from 'react-native';
import { useAuth } from '../context/AuthContext';
import { VEHICLES } from '../data/mockData';

export default function VehicleListScreen({ navigation, route }) {
    const { actionType } = route.params;
    const { hub } = useAuth();
    const [searchText, setSearchText] = useState('');

    // Filter vehicles by hub
    const hubVehicles = VEHICLES.filter((v) => v.hubId === hub?.id);

    // Filter by search
    const filteredVehicles = hubVehicles.filter(
        (v) =>
            v.vehicleNumber.toLowerCase().includes(searchText.toLowerCase()) ||
            v.make.toLowerCase().includes(searchText.toLowerCase())
    );

    const handleVehicleSelect = (vehicle) => {
        navigation.navigate('VehicleInspection', { vehicle, actionType });
    };

    const getActionColor = () => {
        const colors = {
            service_in: '#3B82F6',
            service_out: '#22C55E',
            inventory_in: '#F59E0B',
            inventory_out: '#EF4444',
        };
        return colors[actionType.id] || '#22C55E';
    };

    const renderVehicleCard = ({ item }) => (
        <TouchableOpacity
            style={styles.vehicleCard}
            onPress={() => handleVehicleSelect(item)}
            activeOpacity={0.8}
        >
            <View style={styles.vehicleLeft}>
                <View style={[styles.vehicleIconBg, { borderColor: getActionColor() }]}>
                    <Text style={styles.vehicleIcon}>🚗</Text>
                </View>
                <View style={styles.vehicleInfo}>
                    <Text style={styles.vehicleNumber}>{item.vehicleNumber}</Text>
                    <Text style={styles.vehicleMake}>{item.make}</Text>
                    <View style={styles.vehicleTags}>
                        <View style={styles.tag}>
                            <Text style={styles.tagText}>{item.color}</Text>
                        </View>
                        <View style={styles.tag}>
                            <Text style={styles.tagText}>{item.year}</Text>
                        </View>
                    </View>
                </View>
            </View>
            <View style={[styles.selectBtn, { backgroundColor: getActionColor() }]}>
                <Text style={styles.selectBtnText}>Select →</Text>
            </View>
        </TouchableOpacity>
    );

    return (
        <View style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
                    <Text style={styles.backBtnText}>← Back</Text>
                </TouchableOpacity>
                <View style={styles.headerCenter}>
                    <Text style={styles.headerIcon}>{actionType.icon}</Text>
                    <Text style={[styles.headerTitle, { color: getActionColor() }]}>{actionType.label}</Text>
                </View>
                <View style={styles.hubInfo}>
                    <Text style={styles.hubInfoText}>📍 {hub?.city}</Text>
                </View>
            </View>

            {/* Search Bar */}
            <View style={styles.searchSection}>
                <View style={styles.searchBar}>
                    <Text style={styles.searchIcon}>🔍</Text>
                    <TextInput
                        style={styles.searchInput}
                        placeholder="Search by vehicle number or model..."
                        placeholderTextColor="#9CA3AF"
                        value={searchText}
                        onChangeText={setSearchText}
                    />
                    {searchText ? (
                        <TouchableOpacity onPress={() => setSearchText('')}>
                            <Text style={styles.clearBtn}>✕</Text>
                        </TouchableOpacity>
                    ) : null}
                </View>
                <Text style={styles.resultCount}>
                    {filteredVehicles.length} vehicle{filteredVehicles.length !== 1 ? 's' : ''} found
                </Text>
            </View>

            {/* Vehicle List */}
            <FlatList
                data={filteredVehicles}
                keyExtractor={(item) => item.id}
                renderItem={renderVehicleCard}
                contentContainerStyle={styles.listContent}
                ListEmptyComponent={
                    <View style={styles.emptyState}>
                        <Text style={styles.emptyIcon}>🚫</Text>
                        <Text style={styles.emptyText}>No vehicles found</Text>
                        <Text style={styles.emptySubtext}>Try adjusting your search</Text>
                    </View>
                }
            />
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#0A1628',
    },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 16,
        paddingTop: 50,
        paddingBottom: 16,
        backgroundColor: '#1A2744',
        borderBottomWidth: 1,
        borderBottomColor: '#2D3F6B',
    },
    backBtn: {
        padding: 8,
        backgroundColor: '#0A1628',
        borderRadius: 8,
        borderWidth: 1,
        borderColor: '#2D3F6B',
    },
    backBtnText: {
        color: '#9CA3AF',
        fontSize: 13,
        fontWeight: '600',
    },
    headerCenter: {
        alignItems: 'center',
        flex: 1,
    },
    headerIcon: {
        fontSize: 20,
    },
    headerTitle: {
        fontSize: 18,
        fontWeight: '700',
    },
    hubInfo: {
        alignItems: 'flex-end',
    },
    hubInfoText: {
        color: '#9CA3AF',
        fontSize: 11,
    },
    searchSection: {
        padding: 16,
        paddingBottom: 8,
    },
    searchBar: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: '#1A2744',
        borderRadius: 12,
        borderWidth: 1,
        borderColor: '#2D3F6B',
        paddingHorizontal: 12,
        paddingVertical: 10,
        marginBottom: 8,
    },
    searchIcon: {
        fontSize: 16,
        marginRight: 8,
    },
    searchInput: {
        flex: 1,
        color: '#F9FAFB',
        fontSize: 14,
    },
    clearBtn: {
        color: '#9CA3AF',
        fontSize: 14,
        padding: 4,
    },
    resultCount: {
        color: '#6B7280',
        fontSize: 12,
    },
    listContent: {
        padding: 16,
        paddingTop: 8,
        gap: 12,
    },
    vehicleCard: {
        backgroundColor: '#1A2744',
        borderRadius: 16,
        padding: 16,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        borderWidth: 1,
        borderColor: '#2D3F6B',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 3 },
        shadowOpacity: 0.3,
        shadowRadius: 6,
        elevation: 5,
    },
    vehicleLeft: {
        flexDirection: 'row',
        alignItems: 'center',
        flex: 1,
    },
    vehicleIconBg: {
        width: 52,
        height: 52,
        borderRadius: 14,
        backgroundColor: '#0A1628',
        alignItems: 'center',
        justifyContent: 'center',
        borderWidth: 2,
        marginRight: 12,
    },
    vehicleIcon: {
        fontSize: 24,
    },
    vehicleInfo: {
        flex: 1,
    },
    vehicleNumber: {
        fontSize: 16,
        fontWeight: '700',
        color: '#F9FAFB',
        letterSpacing: 0.5,
    },
    vehicleMake: {
        fontSize: 13,
        color: '#9CA3AF',
        marginTop: 2,
    },
    vehicleTags: {
        flexDirection: 'row',
        gap: 6,
        marginTop: 6,
    },
    tag: {
        backgroundColor: '#0A1628',
        borderRadius: 6,
        paddingHorizontal: 8,
        paddingVertical: 2,
        borderWidth: 1,
        borderColor: '#2D3F6B',
    },
    tagText: {
        color: '#9CA3AF',
        fontSize: 11,
    },
    selectBtn: {
        borderRadius: 8,
        paddingHorizontal: 14,
        paddingVertical: 8,
        marginLeft: 8,
    },
    selectBtnText: {
        color: '#fff',
        fontSize: 13,
        fontWeight: '700',
    },
    emptyState: {
        alignItems: 'center',
        paddingVertical: 60,
    },
    emptyIcon: {
        fontSize: 48,
        marginBottom: 12,
    },
    emptyText: {
        fontSize: 18,
        fontWeight: '600',
        color: '#6B7280',
    },
    emptySubtext: {
        fontSize: 13,
        color: '#4B5563',
        marginTop: 4,
    },
});
