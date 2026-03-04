import React, { useState, useRef } from 'react';
import {
    View,
    Text,
    TextInput,
    TouchableOpacity,
    StyleSheet,
    ScrollView,
    Alert,
    Image,
    FlatList,
    Modal,
    ActivityIndicator,
    Platform,
} from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import * as MediaLibrary from 'expo-media-library';
import { useAuth } from '../context/AuthContext';

const PHOTO_ANGLES = [
    { id: 'front', label: 'Front View', icon: '⬆️' },
    { id: 'rear', label: 'Rear View', icon: '⬇️' },
    { id: 'left', label: 'Left Side', icon: '⬅️' },
    { id: 'right', label: 'Right Side', icon: '➡️' },
    { id: 'dashboard', label: 'Dashboard', icon: '🎛️' },
    { id: 'odometer', label: 'Odometer', icon: '🔢' },
    { id: 'additional', label: 'Additional', icon: '📸' },
];

export default function VehicleInspectionScreen({ navigation, route }) {
    const { vehicle, actionType } = route.params;
    const { user, hub } = useAuth();

    const [driverName, setDriverName] = useState('');
    const [odoReading, setOdoReading] = useState('');
    const [issues, setIssues] = useState([]);
    const [newIssue, setNewIssue] = useState('');
    const [showIssueInput, setShowIssueInput] = useState(false);
    const [photos, setPhotos] = useState({}); // { angleId: [uri, uri, ...] }
    const [previewPhoto, setPreviewPhoto] = useState(null);
    const [submitting, setSubmitting] = useState(false);
    const [submitted, setSubmitted] = useState(false);

    const getActionColor = () => {
        const colors = {
            service_in: '#3B82F6',
            service_out: '#22C55E',
            inventory_in: '#F59E0B',
            inventory_out: '#EF4444',
        };
        return colors[actionType.id] || '#22C55E';
    };

    const totalPhotos = Object.values(photos).reduce((sum, arr) => sum + arr.length, 0);

    const requestPermissions = async () => {
        const { status: cameraStatus } = await ImagePicker.requestCameraPermissionsAsync();
        const { status: mediaStatus } = await MediaLibrary.requestPermissionsAsync();
        return cameraStatus === 'granted' && mediaStatus === 'granted';
    };

    const handleTakePhoto = async (angleId) => {
        const granted = await requestPermissions();
        if (!granted) {
            Alert.alert(
                'Permission Required',
                'Camera and media library permissions are required to take photos.',
                [{ text: 'OK' }]
            );
            return;
        }

        Alert.alert(
            `${PHOTO_ANGLES.find(a => a.id === angleId)?.label}`,
            'How would you like to add a photo?',
            [
                {
                    text: '📷 Take Photo',
                    onPress: async () => {
                        const result = await ImagePicker.launchCameraAsync({
                            quality: 0.85,
                            allowsEditing: false,
                            exif: true,
                        });
                        if (!result.canceled && result.assets[0]) {
                            addPhoto(angleId, result.assets[0].uri);
                        }
                    },
                },
                {
                    text: '🖼️ Choose from Gallery',
                    onPress: async () => {
                        const result = await ImagePicker.launchImageLibraryAsync({
                            mediaTypes: ImagePicker.MediaTypeOptions.Images,
                            quality: 0.85,
                            allowsMultipleSelection: true,
                        });
                        if (!result.canceled && result.assets.length > 0) {
                            result.assets.forEach(asset => addPhoto(angleId, asset.uri));
                        }
                    },
                },
                { text: 'Cancel', style: 'cancel' },
            ]
        );
    };

    const addPhoto = (angleId, uri) => {
        setPhotos((prev) => ({
            ...prev,
            [angleId]: [...(prev[angleId] || []), uri],
        }));
    };

    const removePhoto = (angleId, index) => {
        setPhotos((prev) => {
            const updated = [...(prev[angleId] || [])];
            updated.splice(index, 1);
            return { ...prev, [angleId]: updated };
        });
    };

    const addIssue = () => {
        if (newIssue.trim()) {
            setIssues([...issues, { id: Date.now().toString(), text: newIssue.trim() }]);
            setNewIssue('');
            setShowIssueInput(false);
        }
    };

    const removeIssue = (id) => {
        setIssues(issues.filter((i) => i.id !== id));
    };

    const handleSubmit = () => {
        if (!driverName.trim()) {
            Alert.alert('Required', 'Please enter the driver name.');
            return;
        }
        if (!odoReading.trim()) {
            Alert.alert('Required', 'Please enter the ODO reading.');
            return;
        }
        if (totalPhotos === 0) {
            Alert.alert('Photos Required', 'Please add at least one photo of the vehicle.');
            return;
        }

        Alert.alert(
            'Confirm Submission',
            `Submit ${actionType.label} for ${vehicle.vehicleNumber}?\n\nDriver: ${driverName}\nODO: ${odoReading} km\nIssues: ${issues.length}\nPhotos: ${totalPhotos}`,
            [
                { text: 'Cancel', style: 'cancel' },
                {
                    text: 'Submit ✓',
                    onPress: () => {
                        setSubmitting(true);
                        setTimeout(() => {
                            setSubmitting(false);
                            setSubmitted(true);
                        }, 1500);
                    },
                },
            ]
        );
    };

    if (submitted) {
        return (
            <View style={styles.successScreen}>
                <View style={styles.successCard}>
                    <Text style={styles.successIcon}>✅</Text>
                    <Text style={styles.successTitle}>Submitted!</Text>
                    <Text style={styles.successMsg}>
                        {actionType.label} for {vehicle.vehicleNumber} has been recorded successfully.
                    </Text>
                    <View style={styles.successDetails}>
                        <Text style={styles.successDetailText}>🚗 {vehicle.vehicleNumber}</Text>
                        <Text style={styles.successDetailText}>👤 {driverName}</Text>
                        <Text style={styles.successDetailText}>📏 {odoReading} km</Text>
                        <Text style={styles.successDetailText}>📸 {totalPhotos} photos captured</Text>
                        <Text style={styles.successDetailText}>⚠️ {issues.length} issue(s) noted</Text>
                    </View>
                    <TouchableOpacity
                        style={styles.successBtn}
                        onPress={() => navigation.navigate('Dashboard')}
                    >
                        <Text style={styles.successBtnText}>← Back to Dashboard</Text>
                    </TouchableOpacity>
                </View>
            </View>
        );
    }

    return (
        <View style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
                    <Text style={styles.backBtnText}>← Back</Text>
                </TouchableOpacity>
                <View style={styles.headerCenter}>
                    <Text style={[styles.actionBadge, { backgroundColor: getActionColor() + '22', borderColor: getActionColor() }]}>
                        <Text style={{ color: getActionColor() }}>{actionType.icon} {actionType.label}</Text>
                    </Text>
                </View>
                <View style={{ width: 60 }} />
            </View>

            <ScrollView style={styles.scroll} contentContainerStyle={styles.scrollContent}>
                {/* Vehicle Info Card */}
                <View style={styles.vehicleCard}>
                    <View style={styles.vehicleHeader}>
                        <Text style={styles.vehicleIcon}>🚗</Text>
                        <View style={styles.vehicleHeaderInfo}>
                            <Text style={styles.vehicleNumber}>{vehicle.vehicleNumber}</Text>
                            <Text style={styles.vehicleMake}>{vehicle.make} • {vehicle.color} • {vehicle.year}</Text>
                            <View style={[styles.hubBadge, { borderColor: getActionColor() }]}>
                                <Text style={[styles.hubBadgeText, { color: getActionColor() }]}>
                                    📍 {hub?.name}
                                </Text>
                            </View>
                        </View>
                    </View>

                    {/* Add Issue Button */}
                    <TouchableOpacity
                        style={styles.addIssueBtn}
                        onPress={() => setShowIssueInput(true)}
                    >
                        <Text style={styles.addIssueBtnText}>⚠️  Add Issue / Damage Note</Text>
                    </TouchableOpacity>

                    {/* Issue Input */}
                    {showIssueInput && (
                        <View style={styles.issueInputRow}>
                            <TextInput
                                style={styles.issueInput}
                                placeholder="Describe the issue or damage..."
                                placeholderTextColor="#9CA3AF"
                                value={newIssue}
                                onChangeText={setNewIssue}
                                autoFocus
                                multiline
                            />
                            <TouchableOpacity style={styles.issueAddBtn} onPress={addIssue}>
                                <Text style={styles.issueAddBtnText}>Add</Text>
                            </TouchableOpacity>
                            <TouchableOpacity style={styles.issueCancelBtn} onPress={() => { setShowIssueInput(false); setNewIssue(''); }}>
                                <Text style={styles.issueCancelBtnText}>✕</Text>
                            </TouchableOpacity>
                        </View>
                    )}

                    {/* Issues List */}
                    {issues.length > 0 && (
                        <View style={styles.issuesList}>
                            <Text style={styles.issuesListTitle}>Issues Noted ({issues.length}):</Text>
                            {issues.map((issue, index) => (
                                <View key={issue.id} style={styles.issueItem}>
                                    <Text style={styles.issueNumber}>{index + 1}.</Text>
                                    <Text style={styles.issueText}>{issue.text}</Text>
                                    <TouchableOpacity onPress={() => removeIssue(issue.id)}>
                                        <Text style={styles.issueRemove}>✕</Text>
                                    </TouchableOpacity>
                                </View>
                            ))}
                        </View>
                    )}
                </View>

                {/* Driver Details */}
                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>Driver & Vehicle Details</Text>

                    <View style={styles.inputGroup}>
                        <Text style={styles.label}>👤 Driver Name *</Text>
                        <TextInput
                            style={styles.input}
                            placeholder="Enter driver's full name"
                            placeholderTextColor="#9CA3AF"
                            value={driverName}
                            onChangeText={setDriverName}
                        />
                    </View>

                    <View style={styles.inputGroup}>
                        <Text style={styles.label}>📏 ODO Reading (km) *</Text>
                        <TextInput
                            style={styles.input}
                            placeholder="e.g. 45230"
                            placeholderTextColor="#9CA3AF"
                            keyboardType="numeric"
                            value={odoReading}
                            onChangeText={setOdoReading}
                        />
                    </View>
                </View>

                {/* Photo Section */}
                <View style={styles.section}>
                    <View style={styles.sectionHeader}>
                        <Text style={styles.sectionTitle}>📸 Vehicle Photos</Text>
                        <View style={styles.photoBadge}>
                            <Text style={styles.photoBadgeText}>{totalPhotos} photos</Text>
                        </View>
                    </View>
                    <Text style={styles.sectionSubtitle}>Capture photos from all angles</Text>

                    {PHOTO_ANGLES.map((angle) => {
                        const anglePhotos = photos[angle.id] || [];
                        return (
                            <View key={angle.id} style={styles.angleSection}>
                                <View style={styles.angleHeader}>
                                    <Text style={styles.angleIcon}>{angle.icon}</Text>
                                    <Text style={styles.angleLabel}>{angle.label}</Text>
                                    <Text style={styles.angleCount}>{anglePhotos.length} photo{anglePhotos.length !== 1 ? 's' : ''}</Text>
                                </View>

                                {/* Photo Thumbnails */}
                                {anglePhotos.length > 0 && (
                                    <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.thumbsRow}>
                                        {anglePhotos.map((uri, idx) => (
                                            <TouchableOpacity
                                                key={idx}
                                                onPress={() => setPreviewPhoto(uri)}
                                                style={styles.thumbContainer}
                                            >
                                                <Image source={{ uri }} style={styles.thumb} />
                                                <TouchableOpacity
                                                    style={styles.thumbRemove}
                                                    onPress={() => removePhoto(angle.id, idx)}
                                                >
                                                    <Text style={styles.thumbRemoveText}>✕</Text>
                                                </TouchableOpacity>
                                            </TouchableOpacity>
                                        ))}
                                    </ScrollView>
                                )}

                                <TouchableOpacity
                                    style={[styles.captureBtn, { borderColor: getActionColor() }]}
                                    onPress={() => handleTakePhoto(angle.id)}
                                >
                                    <Text style={[styles.captureBtnIcon, { color: getActionColor() }]}>📷</Text>
                                    <Text style={[styles.captureBtnText, { color: getActionColor() }]}>
                                        {anglePhotos.length > 0 ? 'Add More Photos' : 'Take Photo'}
                                    </Text>
                                </TouchableOpacity>
                            </View>
                        );
                    })}
                </View>

                {/* Submit Button */}
                <TouchableOpacity
                    style={[styles.submitBtn, { backgroundColor: getActionColor() }, submitting && styles.submitBtnDisabled]}
                    onPress={handleSubmit}
                    disabled={submitting}
                >
                    {submitting ? (
                        <ActivityIndicator color="#fff" size="small" />
                    ) : (
                        <>
                            <Text style={styles.submitBtnIcon}>{actionType.icon}</Text>
                            <Text style={styles.submitBtnText}>Submit {actionType.label}</Text>
                        </>
                    )}
                </TouchableOpacity>
            </ScrollView>

            {/* Photo Preview Modal */}
            <Modal visible={!!previewPhoto} transparent animationType="fade">
                <TouchableOpacity style={styles.previewOverlay} onPress={() => setPreviewPhoto(null)}>
                    <Image source={{ uri: previewPhoto }} style={styles.previewImage} resizeMode="contain" />
                    <Text style={styles.previewClose}>✕ Tap to close</Text>
                </TouchableOpacity>
            </Modal>
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
        flex: 1,
        alignItems: 'center',
    },
    actionBadge: {
        paddingHorizontal: 14,
        paddingVertical: 6,
        borderRadius: 20,
        borderWidth: 1,
        fontSize: 14,
        fontWeight: '700',
    },
    scroll: { flex: 1 },
    scrollContent: {
        padding: 16,
        paddingBottom: 40,
        gap: 16,
    },
    vehicleCard: {
        backgroundColor: '#1A2744',
        borderRadius: 16,
        padding: 16,
        borderWidth: 1,
        borderColor: '#2D3F6B',
    },
    vehicleHeader: {
        flexDirection: 'row',
        alignItems: 'flex-start',
        marginBottom: 14,
    },
    vehicleIcon: {
        fontSize: 36,
        marginRight: 12,
    },
    vehicleHeaderInfo: {
        flex: 1,
    },
    vehicleNumber: {
        fontSize: 20,
        fontWeight: '800',
        color: '#F9FAFB',
        letterSpacing: 1,
    },
    vehicleMake: {
        fontSize: 13,
        color: '#9CA3AF',
        marginTop: 2,
    },
    hubBadge: {
        marginTop: 6,
        borderRadius: 6,
        paddingHorizontal: 8,
        paddingVertical: 3,
        alignSelf: 'flex-start',
        borderWidth: 1,
    },
    hubBadgeText: {
        fontSize: 11,
        fontWeight: '600',
    },
    addIssueBtn: {
        backgroundColor: '#3D2A00',
        borderRadius: 10,
        padding: 12,
        alignItems: 'center',
        borderWidth: 1,
        borderColor: '#F59E0B',
        marginTop: 4,
    },
    addIssueBtnText: {
        color: '#F59E0B',
        fontSize: 14,
        fontWeight: '600',
    },
    issueInputRow: {
        flexDirection: 'row',
        alignItems: 'flex-start',
        marginTop: 10,
        gap: 8,
    },
    issueInput: {
        flex: 1,
        backgroundColor: '#0A1628',
        borderRadius: 10,
        borderWidth: 1,
        borderColor: '#F59E0B',
        paddingHorizontal: 12,
        paddingVertical: 10,
        color: '#F9FAFB',
        fontSize: 13,
        minHeight: 44,
    },
    issueAddBtn: {
        backgroundColor: '#F59E0B',
        borderRadius: 10,
        paddingHorizontal: 14,
        paddingVertical: 10,
        height: 44,
        justifyContent: 'center',
    },
    issueAddBtnText: {
        color: '#000',
        fontWeight: '700',
        fontSize: 13,
    },
    issueCancelBtn: {
        backgroundColor: '#1A2744',
        borderRadius: 10,
        paddingHorizontal: 12,
        paddingVertical: 10,
        height: 44,
        justifyContent: 'center',
        borderWidth: 1,
        borderColor: '#2D3F6B',
    },
    issueCancelBtnText: {
        color: '#9CA3AF',
        fontSize: 14,
    },
    issuesList: {
        marginTop: 10,
        backgroundColor: '#0A1628',
        borderRadius: 10,
        padding: 10,
        borderWidth: 1,
        borderColor: '#2D3F6B',
    },
    issuesListTitle: {
        color: '#F59E0B',
        fontSize: 12,
        fontWeight: '600',
        marginBottom: 6,
    },
    issueItem: {
        flexDirection: 'row',
        alignItems: 'flex-start',
        paddingVertical: 4,
        gap: 6,
    },
    issueNumber: {
        color: '#F59E0B',
        fontSize: 13,
        fontWeight: '700',
        minWidth: 18,
    },
    issueText: {
        flex: 1,
        color: '#E5E7EB',
        fontSize: 13,
    },
    issueRemove: {
        color: '#EF4444',
        fontSize: 14,
        fontWeight: '700',
        paddingHorizontal: 4,
    },
    section: {
        backgroundColor: '#1A2744',
        borderRadius: 16,
        padding: 16,
        borderWidth: 1,
        borderColor: '#2D3F6B',
    },
    sectionHeader: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        marginBottom: 4,
    },
    sectionTitle: {
        fontSize: 17,
        fontWeight: '700',
        color: '#F9FAFB',
        marginBottom: 4,
    },
    sectionSubtitle: {
        fontSize: 12,
        color: '#9CA3AF',
        marginBottom: 16,
    },
    photoBadge: {
        backgroundColor: '#1B4332',
        borderRadius: 12,
        paddingHorizontal: 10,
        paddingVertical: 3,
        borderWidth: 1,
        borderColor: '#22C55E',
    },
    photoBadgeText: {
        color: '#22C55E',
        fontSize: 11,
        fontWeight: '600',
    },
    inputGroup: {
        marginBottom: 14,
    },
    label: {
        fontSize: 13,
        fontWeight: '600',
        color: '#9CA3AF',
        marginBottom: 8,
    },
    input: {
        backgroundColor: '#0A1628',
        borderWidth: 1,
        borderColor: '#2D3F6B',
        borderRadius: 12,
        paddingHorizontal: 14,
        paddingVertical: 13,
        fontSize: 15,
        color: '#F9FAFB',
    },
    angleSection: {
        marginBottom: 16,
        backgroundColor: '#0A1628',
        borderRadius: 12,
        padding: 12,
        borderWidth: 1,
        borderColor: '#2D3F6B',
    },
    angleHeader: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 10,
        gap: 8,
    },
    angleIcon: {
        fontSize: 18,
    },
    angleLabel: {
        fontSize: 14,
        fontWeight: '600',
        color: '#E5E7EB',
        flex: 1,
    },
    angleCount: {
        fontSize: 11,
        color: '#9CA3AF',
    },
    thumbsRow: {
        marginBottom: 10,
    },
    thumbContainer: {
        marginRight: 8,
        position: 'relative',
    },
    thumb: {
        width: 80,
        height: 80,
        borderRadius: 8,
        borderWidth: 1,
        borderColor: '#2D3F6B',
    },
    thumbRemove: {
        position: 'absolute',
        top: -6,
        right: -6,
        backgroundColor: '#EF4444',
        width: 20,
        height: 20,
        borderRadius: 10,
        alignItems: 'center',
        justifyContent: 'center',
    },
    thumbRemoveText: {
        color: '#fff',
        fontSize: 10,
        fontWeight: '700',
    },
    captureBtn: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        borderWidth: 1.5,
        borderRadius: 10,
        paddingVertical: 10,
        gap: 6,
        borderStyle: 'dashed',
    },
    captureBtnIcon: {
        fontSize: 16,
    },
    captureBtnText: {
        fontSize: 13,
        fontWeight: '600',
    },
    submitBtn: {
        borderRadius: 14,
        paddingVertical: 18,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 10,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.4,
        shadowRadius: 8,
        elevation: 8,
    },
    submitBtnDisabled: {
        opacity: 0.7,
    },
    submitBtnIcon: {
        fontSize: 20,
    },
    submitBtnText: {
        color: '#fff',
        fontSize: 17,
        fontWeight: '700',
    },
    previewOverlay: {
        flex: 1,
        backgroundColor: 'rgba(0,0,0,0.95)',
        alignItems: 'center',
        justifyContent: 'center',
    },
    previewImage: {
        width: '95%',
        height: '80%',
        borderRadius: 12,
    },
    previewClose: {
        color: '#9CA3AF',
        fontSize: 14,
        marginTop: 16,
    },
    // Success Screen
    successScreen: {
        flex: 1,
        backgroundColor: '#0A1628',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 24,
    },
    successCard: {
        backgroundColor: '#1A2744',
        borderRadius: 20,
        padding: 28,
        alignItems: 'center',
        borderWidth: 1,
        borderColor: '#22C55E',
        width: '100%',
        shadowColor: '#22C55E',
        shadowOffset: { width: 0, height: 0 },
        shadowOpacity: 0.3,
        shadowRadius: 20,
        elevation: 12,
    },
    successIcon: {
        fontSize: 60,
        marginBottom: 16,
    },
    successTitle: {
        fontSize: 28,
        fontWeight: '800',
        color: '#22C55E',
        marginBottom: 8,
    },
    successMsg: {
        fontSize: 15,
        color: '#9CA3AF',
        textAlign: 'center',
        marginBottom: 20,
        lineHeight: 22,
    },
    successDetails: {
        backgroundColor: '#0A1628',
        borderRadius: 12,
        padding: 16,
        width: '100%',
        marginBottom: 24,
        gap: 8,
        borderWidth: 1,
        borderColor: '#2D3F6B',
    },
    successDetailText: {
        color: '#E5E7EB',
        fontSize: 14,
    },
    successBtn: {
        backgroundColor: '#22C55E',
        borderRadius: 12,
        paddingVertical: 14,
        paddingHorizontal: 28,
        width: '100%',
        alignItems: 'center',
    },
    successBtnText: {
        color: '#fff',
        fontSize: 16,
        fontWeight: '700',
    },
});
