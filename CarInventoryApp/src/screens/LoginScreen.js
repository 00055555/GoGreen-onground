import React, { useState } from 'react';
import {
    View,
    Text,
    TextInput,
    TouchableOpacity,
    StyleSheet,
    ScrollView,
    Alert,
    ActivityIndicator,
    KeyboardAvoidingView,
    Platform,
    Image,
} from 'react-native';
import { useAuth } from '../context/AuthContext';
import { HUBS } from '../data/mockData';

export default function LoginScreen() {
    const { login } = useAuth();
    const [selectedHub, setSelectedHub] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [showPassword, setShowPassword] = useState(false);
    const [hubDropdownOpen, setHubDropdownOpen] = useState(false);

    const handleLogin = async () => {
        if (!selectedHub) {
            Alert.alert('Missing Field', 'Please select a Hub Location.');
            return;
        }
        if (!email.trim()) {
            Alert.alert('Missing Field', 'Please enter your Email ID.');
            return;
        }
        if (!password.trim()) {
            Alert.alert('Missing Field', 'Please enter your Password.');
            return;
        }
        setLoading(true);
        setTimeout(() => {
            const result = login(selectedHub, email.trim(), password);
            setLoading(false);
            if (!result.success) {
                Alert.alert('Login Failed', result.error);
            }
        }, 800);
    };

    const selectedHubName = HUBS.find((h) => h.id === selectedHub)?.name || '';

    return (
        <KeyboardAvoidingView
            style={styles.container}
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        >
            <ScrollView
                contentContainerStyle={styles.scrollContent}
                keyboardShouldPersistTaps="handled"
            >
                {/* Header */}
                <View style={styles.headerSection}>
                    <View style={styles.logoContainer}>
                        <View style={styles.logoCircle}>
                            <Text style={styles.logoIcon}>🚗</Text>
                        </View>
                    </View>
                    <Text style={styles.appTitle}>GoGreen</Text>
                    <Text style={styles.appSubtitle}>Vehicle Inventory System</Text>
                    <Text style={styles.tagline}>Capture. Track. Manage.</Text>
                </View>

                {/* Form Card */}
                <View style={styles.card}>
                    <Text style={styles.cardTitle}>Sign In</Text>
                    <Text style={styles.cardSubtitle}>Please log in to continue</Text>

                    {/* Hub Location Dropdown */}
                    <View style={styles.inputGroup}>
                        <Text style={styles.label}>🏢 Hub Location</Text>
                        <TouchableOpacity
                            style={[styles.dropdownBtn, hubDropdownOpen && styles.dropdownBtnActive]}
                            onPress={() => setHubDropdownOpen(!hubDropdownOpen)}
                        >
                            <Text style={[styles.dropdownBtnText, !selectedHub && styles.placeholderText]}>
                                {selectedHubName || 'Select your hub location'}
                            </Text>
                            <Text style={styles.dropdownArrow}>{hubDropdownOpen ? '▲' : '▼'}</Text>
                        </TouchableOpacity>
                        {hubDropdownOpen && (
                            <View style={styles.dropdown}>
                                {HUBS.map((hub) => (
                                    <TouchableOpacity
                                        key={hub.id}
                                        style={[styles.dropdownItem, selectedHub === hub.id && styles.dropdownItemActive]}
                                        onPress={() => {
                                            setSelectedHub(hub.id);
                                            setHubDropdownOpen(false);
                                        }}
                                    >
                                        <Text style={[styles.dropdownItemText, selectedHub === hub.id && styles.dropdownItemTextActive]}>
                                            📍 {hub.name}
                                        </Text>
                                        {selectedHub === hub.id && <Text style={styles.checkmark}>✓</Text>}
                                    </TouchableOpacity>
                                ))}
                            </View>
                        )}
                    </View>

                    {/* Email */}
                    <View style={styles.inputGroup}>
                        <Text style={styles.label}>✉️ Email ID</Text>
                        <TextInput
                            style={styles.input}
                            placeholder="Enter your email address"
                            placeholderTextColor="#9CA3AF"
                            keyboardType="email-address"
                            autoCapitalize="none"
                            value={email}
                            onChangeText={setEmail}
                        />
                    </View>

                    {/* Password */}
                    <View style={styles.inputGroup}>
                        <Text style={styles.label}>🔒 Password</Text>
                        <View style={styles.passwordContainer}>
                            <TextInput
                                style={styles.passwordInput}
                                placeholder="Enter your password"
                                placeholderTextColor="#9CA3AF"
                                secureTextEntry={!showPassword}
                                value={password}
                                onChangeText={setPassword}
                            />
                            <TouchableOpacity onPress={() => setShowPassword(!showPassword)} style={styles.eyeBtn}>
                                <Text style={styles.eyeIcon}>{showPassword ? '🙈' : '👁️'}</Text>
                            </TouchableOpacity>
                        </View>
                    </View>

                    {/* Login Button */}
                    <TouchableOpacity
                        style={[styles.loginBtn, loading && styles.loginBtnDisabled]}
                        onPress={handleLogin}
                        disabled={loading}
                    >
                        {loading ? (
                            <ActivityIndicator color="#fff" size="small" />
                        ) : (
                            <Text style={styles.loginBtnText}>Sign In →</Text>
                        )}
                    </TouchableOpacity>

                    {/* Demo hint */}
                    <View style={styles.demoHint}>
                        <Text style={styles.demoHintText}>Demo: agent1@gogreen.com / pass123</Text>
                        <Text style={styles.demoHintText}>Hub: Mumbai Hub</Text>
                    </View>
                </View>

                <Text style={styles.footer}>GoGreen Fleet Management • v1.0</Text>
            </ScrollView>
        </KeyboardAvoidingView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#0A1628',
    },
    scrollContent: {
        flexGrow: 1,
        padding: 20,
        paddingTop: 50,
    },
    headerSection: {
        alignItems: 'center',
        marginBottom: 32,
    },
    logoContainer: {
        marginBottom: 12,
    },
    logoCircle: {
        width: 80,
        height: 80,
        borderRadius: 40,
        backgroundColor: '#1B4332',
        borderWidth: 3,
        borderColor: '#22C55E',
        alignItems: 'center',
        justifyContent: 'center',
        shadowColor: '#22C55E',
        shadowOffset: { width: 0, height: 0 },
        shadowOpacity: 0.5,
        shadowRadius: 15,
        elevation: 10,
    },
    logoIcon: {
        fontSize: 36,
    },
    appTitle: {
        fontSize: 32,
        fontWeight: '800',
        color: '#22C55E',
        letterSpacing: 2,
    },
    appSubtitle: {
        fontSize: 14,
        color: '#9CA3AF',
        marginTop: 4,
        letterSpacing: 1,
    },
    tagline: {
        fontSize: 12,
        color: '#6B7280',
        marginTop: 6,
        fontStyle: 'italic',
    },
    card: {
        backgroundColor: '#1A2744',
        borderRadius: 20,
        padding: 24,
        borderWidth: 1,
        borderColor: '#2D3F6B',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.4,
        shadowRadius: 16,
        elevation: 12,
    },
    cardTitle: {
        fontSize: 24,
        fontWeight: '700',
        color: '#F9FAFB',
        marginBottom: 4,
    },
    cardSubtitle: {
        fontSize: 13,
        color: '#9CA3AF',
        marginBottom: 24,
    },
    inputGroup: {
        marginBottom: 18,
    },
    label: {
        fontSize: 13,
        fontWeight: '600',
        color: '#9CA3AF',
        marginBottom: 8,
        letterSpacing: 0.5,
    },
    input: {
        backgroundColor: '#0F1A2E',
        borderWidth: 1,
        borderColor: '#2D3F6B',
        borderRadius: 12,
        paddingHorizontal: 16,
        paddingVertical: 14,
        fontSize: 15,
        color: '#F9FAFB',
    },
    dropdownBtn: {
        backgroundColor: '#0F1A2E',
        borderWidth: 1,
        borderColor: '#2D3F6B',
        borderRadius: 12,
        paddingHorizontal: 16,
        paddingVertical: 14,
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
    },
    dropdownBtnActive: {
        borderColor: '#22C55E',
        borderBottomLeftRadius: 0,
        borderBottomRightRadius: 0,
    },
    dropdownBtnText: {
        fontSize: 15,
        color: '#F9FAFB',
    },
    placeholderText: {
        color: '#9CA3AF',
    },
    dropdownArrow: {
        color: '#9CA3AF',
        fontSize: 12,
    },
    dropdown: {
        backgroundColor: '#0F1A2E',
        borderWidth: 1,
        borderTopWidth: 0,
        borderColor: '#22C55E',
        borderBottomLeftRadius: 12,
        borderBottomRightRadius: 12,
        overflow: 'hidden',
    },
    dropdownItem: {
        paddingHorizontal: 16,
        paddingVertical: 14,
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        borderTopWidth: 1,
        borderTopColor: '#1A2744',
    },
    dropdownItemActive: {
        backgroundColor: '#1B4332',
    },
    dropdownItemText: {
        fontSize: 14,
        color: '#E5E7EB',
    },
    dropdownItemTextActive: {
        color: '#22C55E',
        fontWeight: '600',
    },
    checkmark: {
        color: '#22C55E',
        fontSize: 16,
        fontWeight: '700',
    },
    passwordContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: '#0F1A2E',
        borderWidth: 1,
        borderColor: '#2D3F6B',
        borderRadius: 12,
    },
    passwordInput: {
        flex: 1,
        paddingHorizontal: 16,
        paddingVertical: 14,
        fontSize: 15,
        color: '#F9FAFB',
    },
    eyeBtn: {
        paddingHorizontal: 14,
        paddingVertical: 14,
    },
    eyeIcon: {
        fontSize: 18,
    },
    loginBtn: {
        backgroundColor: '#22C55E',
        borderRadius: 12,
        paddingVertical: 16,
        alignItems: 'center',
        marginTop: 8,
        shadowColor: '#22C55E',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.4,
        shadowRadius: 10,
        elevation: 8,
    },
    loginBtnDisabled: {
        opacity: 0.7,
    },
    loginBtnText: {
        color: '#fff',
        fontSize: 17,
        fontWeight: '700',
        letterSpacing: 0.5,
    },
    demoHint: {
        marginTop: 16,
        padding: 12,
        backgroundColor: '#0F1A2E',
        borderRadius: 8,
        borderLeftWidth: 3,
        borderLeftColor: '#F59E0B',
    },
    demoHintText: {
        color: '#F59E0B',
        fontSize: 11,
        textAlign: 'center',
    },
    footer: {
        textAlign: 'center',
        color: '#4B5563',
        fontSize: 11,
        marginTop: 24,
        marginBottom: 10,
    },
});
