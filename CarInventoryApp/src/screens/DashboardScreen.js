import React from 'react';
import {
    View,
    Text,
    TouchableOpacity,
    StyleSheet,
    ScrollView,
    StatusBar,
} from 'react-native';
import { useAuth } from '../context/AuthContext';

const ACTION_TYPES = [
    {
        id: 'service_in',
        label: 'Service In',
        icon: '🔧',
        description: 'Vehicle arriving for service',
        color: '#3B82F6',
        bgColor: '#1E3A5F',
        borderColor: '#3B82F6',
    },
    {
        id: 'service_out',
        label: 'Service Out',
        icon: '✅',
        description: 'Vehicle leaving after service',
        color: '#22C55E',
        bgColor: '#1B4332',
        borderColor: '#22C55E',
    },
    {
        id: 'inventory_in',
        label: 'Inventory In',
        icon: '📦',
        description: 'Vehicle added to inventory',
        color: '#F59E0B',
        bgColor: '#3D2A00',
        borderColor: '#F59E0B',
    },
    {
        id: 'inventory_out',
        label: 'Inventory Out',
        icon: '🚚',
        description: 'Vehicle removed from inventory',
        color: '#EF4444',
        bgColor: '#3B1A1A',
        borderColor: '#EF4444',
    },
];

export default function DashboardScreen({ navigation }) {
    const { user, hub, logout } = useAuth();

    const handleActionSelect = (actionType) => {
        navigation.navigate('VehicleList', { actionType });
    };

    const getGreeting = () => {
        const hour = new Date().getHours();
        if (hour < 12) return 'Good Morning';
        if (hour < 17) return 'Good Afternoon';
        return 'Good Evening';
    };

    return (
        <View style={styles.container}>
            <StatusBar barStyle="light-content" backgroundColor="#0A1628" />

            {/* Header */}
            <View style={styles.header}>
                <View style={styles.headerLeft}>
                    <Text style={styles.greeting}>{getGreeting()}, 👋</Text>
                    <Text style={styles.userName}>{user?.name}</Text>
                    <View style={styles.hubBadge}>
                        <Text style={styles.hubBadgeText}>📍 {hub?.name}</Text>
                    </View>
                </View>
                <TouchableOpacity onPress={logout} style={styles.logoutBtn}>
                    <Text style={styles.logoutIcon}>⏻</Text>
                    <Text style={styles.logoutText}>Logout</Text>
                </TouchableOpacity>
            </View>

            {/* Stats Row */}
            <View style={styles.statsRow}>
                <View style={styles.statCard}>
                    <Text style={styles.statNumber}>4</Text>
                    <Text style={styles.statLabel}>Vehicles</Text>
                </View>
                <View style={styles.statCard}>
                    <Text style={styles.statNumber}>Mar 04</Text>
                    <Text style={styles.statLabel}>Today</Text>
                </View>
                <View style={styles.statCard}>
                    <Text style={styles.statNumber}>Active</Text>
                    <Text style={styles.statLabel}>Status</Text>
                </View>
            </View>

            <ScrollView style={styles.scroll} contentContainerStyle={styles.scrollContent}>
                <Text style={styles.sectionTitle}>Select Action Type</Text>
                <Text style={styles.sectionSubtitle}>What would you like to record?</Text>

                <View style={styles.actionsGrid}>
                    {ACTION_TYPES.map((action) => (
                        <TouchableOpacity
                            key={action.id}
                            style={[styles.actionCard, { borderColor: action.borderColor, backgroundColor: action.bgColor }]}
                            onPress={() => handleActionSelect(action)}
                            activeOpacity={0.8}
                        >
                            <View style={[styles.actionIconContainer, { backgroundColor: action.color + '22' }]}>
                                <Text style={styles.actionIcon}>{action.icon}</Text>
                            </View>
                            <Text style={[styles.actionLabel, { color: action.color }]}>{action.label}</Text>
                            <Text style={styles.actionDesc}>{action.description}</Text>
                            <View style={[styles.actionArrow, { backgroundColor: action.color }]}>
                                <Text style={styles.actionArrowText}>→</Text>
                            </View>
                        </TouchableOpacity>
                    ))}
                </View>
            </ScrollView>
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
        justifyContent: 'space-between',
        alignItems: 'flex-start',
        paddingHorizontal: 20,
        paddingTop: 50,
        paddingBottom: 16,
        backgroundColor: '#1A2744',
        borderBottomWidth: 1,
        borderBottomColor: '#2D3F6B',
    },
    headerLeft: {
        flex: 1,
    },
    greeting: {
        fontSize: 13,
        color: '#9CA3AF',
    },
    userName: {
        fontSize: 20,
        fontWeight: '700',
        color: '#F9FAFB',
        marginTop: 2,
    },
    hubBadge: {
        marginTop: 6,
        backgroundColor: '#1B4332',
        borderRadius: 20,
        paddingHorizontal: 10,
        paddingVertical: 4,
        alignSelf: 'flex-start',
        borderWidth: 1,
        borderColor: '#22C55E',
    },
    hubBadgeText: {
        color: '#22C55E',
        fontSize: 11,
        fontWeight: '600',
    },
    logoutBtn: {
        alignItems: 'center',
        backgroundColor: '#3B1A1A',
        borderRadius: 10,
        padding: 10,
        borderWidth: 1,
        borderColor: '#EF4444',
    },
    logoutIcon: {
        fontSize: 18,
        color: '#EF4444',
    },
    logoutText: {
        fontSize: 10,
        color: '#EF4444',
        marginTop: 2,
        fontWeight: '600',
    },
    statsRow: {
        flexDirection: 'row',
        paddingHorizontal: 16,
        paddingVertical: 12,
        gap: 10,
    },
    statCard: {
        flex: 1,
        backgroundColor: '#1A2744',
        borderRadius: 12,
        padding: 12,
        alignItems: 'center',
        borderWidth: 1,
        borderColor: '#2D3F6B',
    },
    statNumber: {
        fontSize: 16,
        fontWeight: '700',
        color: '#22C55E',
    },
    statLabel: {
        fontSize: 11,
        color: '#9CA3AF',
        marginTop: 2,
    },
    scroll: {
        flex: 1,
    },
    scrollContent: {
        padding: 16,
        paddingBottom: 30,
    },
    sectionTitle: {
        fontSize: 20,
        fontWeight: '700',
        color: '#F9FAFB',
        marginBottom: 4,
    },
    sectionSubtitle: {
        fontSize: 13,
        color: '#9CA3AF',
        marginBottom: 20,
    },
    actionsGrid: {
        gap: 14,
    },
    actionCard: {
        borderRadius: 16,
        padding: 20,
        borderWidth: 1.5,
        position: 'relative',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 8,
        elevation: 6,
    },
    actionIconContainer: {
        width: 52,
        height: 52,
        borderRadius: 14,
        alignItems: 'center',
        justifyContent: 'center',
        marginBottom: 12,
    },
    actionIcon: {
        fontSize: 26,
    },
    actionLabel: {
        fontSize: 20,
        fontWeight: '700',
        marginBottom: 4,
    },
    actionDesc: {
        fontSize: 13,
        color: '#9CA3AF',
    },
    actionArrow: {
        position: 'absolute',
        right: 16,
        top: '50%',
        marginTop: -16,
        width: 32,
        height: 32,
        borderRadius: 16,
        alignItems: 'center',
        justifyContent: 'center',
    },
    actionArrowText: {
        color: '#fff',
        fontSize: 16,
        fontWeight: '700',
    },
});
