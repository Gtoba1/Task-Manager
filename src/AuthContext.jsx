// src/AuthContext.jsx
// Provides the logged-in user to the entire app.
// Any component can call useAuth() to get: { user, login, logout, loading }

import { createContext, useContext, useState, useEffect } from 'react';
import { login as loginApi, getMe } from './api';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser]       = useState(null);
  const [loading, setLoading] = useState(true); // true while checking saved token

  // On app load, check if there's a saved token and restore the session
  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      getMe()
        .then(res => setUser(res.data.user))
        .catch(() => localStorage.removeItem('token')) // token expired or invalid
        .finally(() => setLoading(false));
    } else {
      setLoading(false);
    }
  }, []);

  // Call this from the Login page
  const login = async (email, password) => {
    const res = await loginApi(email, password);
    localStorage.setItem('token', res.data.token);
    setUser(res.data.user);
    return res.data.user;
  };

  // Call this to log out
  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
}

// Shorthand hook — use this in any component
export const useAuth = () => useContext(AuthContext);
