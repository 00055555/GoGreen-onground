import React, { createContext, useContext, useState } from 'react';
import { USERS, HUBS } from '../data/mockData';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
    const [user, setUser] = useState(null);
    const [hub, setHub] = useState(null);

    const login = (hubLocation, email, password) => {
        // Find matching user
        const found = USERS.find(
            (u) =>
                u.email.toLowerCase() === email.toLowerCase() &&
                u.password === password &&
                u.hubId === hubLocation
        );
        if (found) {
            const foundHub = HUBS.find((h) => h.id === found.hubId);
            setUser(found);
            setHub(foundHub);
            return { success: true };
        }
        return { success: false, error: 'Invalid credentials. Please check your hub, email, and password.' };
    };

    const logout = () => {
        setUser(null);
        setHub(null);
    };

    return (
        <AuthContext.Provider value={{ user, hub, login, logout }}>
            {children}
        </AuthContext.Provider>
    );
}

export function useAuth() {
    return useContext(AuthContext);
}
