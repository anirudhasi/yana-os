import React, { useState } from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';

const navItems = [
  { path: '/dashboard', label: 'Dashboard', icon: '📊' },
  { path: '/onboarding', label: 'Rider Onboarding', icon: '👤' },
  { path: '/allocation', label: 'Vehicle Allocation', icon: '🛵' },
  { path: '/fleet', label: 'Fleet Management', icon: '🚗' },
  { path: '/payments', label: 'Payments', icon: '💰' },
];

const styles = {
  shell: { display: 'flex', height: '100vh', fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif' },
  sidebar: { width: 220, background: '#1B4F72', color: '#fff', display: 'flex', flexDirection: 'column', flexShrink: 0 },
  logo: { padding: '20px 20px 16px', borderBottom: '1px solid rgba(255,255,255,0.1)' },
  logoTitle: { fontSize: 20, fontWeight: 700, color: '#fff' },
  logoSub: { fontSize: 11, color: 'rgba(255,255,255,0.5)', marginTop: 2 },
  nav: { flex: 1, padding: '12px 0', overflowY: 'auto' },
  navItem: { display: 'flex', alignItems: 'center', gap: 10, padding: '10px 20px', fontSize: 13, color: 'rgba(255,255,255,0.75)', textDecoration: 'none', cursor: 'pointer', transition: 'background .15s' },
  navActive: { background: 'rgba(255,255,255,0.15)', color: '#fff', borderLeft: '3px solid #fff' },
  main: { flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden', background: '#F4F6F9' },
  topbar: { height: 56, background: '#fff', borderBottom: '1px solid #E8EAF0', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 24px', flexShrink: 0 },
  topbarTitle: { fontSize: 15, fontWeight: 600, color: '#1a1a2e' },
  avatar: { width: 36, height: 36, borderRadius: '50%', background: '#1B4F72', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 13, fontWeight: 600, cursor: 'pointer' },
  content: { flex: 1, overflowY: 'auto', padding: 24 },
};

export default function Layout() {
  const navigate = useNavigate();
  const logout = () => { localStorage.clear(); navigate('/login'); };

  return (
    <div style={styles.shell}>
      <div style={styles.sidebar}>
        <div style={styles.logo}>
          <div style={styles.logoTitle}>Yana OS</div>
          <div style={styles.logoSub}>Operations HQ</div>
        </div>
        <nav style={styles.nav}>
          {navItems.map(item => (
            <NavLink
              key={item.path}
              to={item.path}
              style={({ isActive }) => ({ ...styles.navItem, ...(isActive ? styles.navActive : {}) })}
            >
              <span style={{ fontSize: 16 }}>{item.icon}</span>
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div style={{ padding: '16px 20px', borderTop: '1px solid rgba(255,255,255,0.1)' }}>
          <div onClick={logout} style={{ ...styles.navItem, padding: 0, cursor: 'pointer', color: 'rgba(255,255,255,0.6)', fontSize: 13 }}>
            🚪 Logout
          </div>
        </div>
      </div>
      <div style={styles.main}>
        <div style={styles.topbar}>
          <div style={styles.topbarTitle}>Yana OS — Admin Dashboard</div>
          <div style={styles.avatar}>OP</div>
        </div>
        <div style={styles.content}>
          <Outlet />
        </div>
      </div>
    </div>
  );
}
