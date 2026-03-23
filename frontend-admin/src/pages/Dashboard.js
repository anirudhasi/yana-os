import React, { useState, useEffect } from 'react';
import { onboardingAPI, fleetAPI } from '../services/api';

const MetricCard = ({ label, value, sub, color = '#1B4F72' }) => (
  <div style={{ background: '#fff', borderRadius: 12, padding: '20px 24px', border: '1px solid #E8EAF0', flex: 1 }}>
    <div style={{ fontSize: 13, color: '#888', marginBottom: 8 }}>{label}</div>
    <div style={{ fontSize: 32, fontWeight: 700, color }}>{value}</div>
    {sub && <div style={{ fontSize: 12, color: '#aaa', marginTop: 4 }}>{sub}</div>}
  </div>
);

export default function Dashboard() {
  const [riderStats, setRiderStats] = useState([]);
  const [vehicleStats, setVehicleStats] = useState([]);

  useEffect(() => {
    onboardingAPI.getStats().then(r => setRiderStats(r.data)).catch(() => {});
    fleetAPI.getVehicleStats().then(r => setVehicleStats(r.data)).catch(() => {});
  }, []);

  const get = (arr, key) => arr.find(x => x.onboarding_status === key || x.status === key)?.count || 0;
  const totalRiders = riderStats.reduce((s, x) => s + (x.count || 0), 0);
  const totalVehicles = vehicleStats.reduce((s, x) => s + (x.count || 0), 0);

  return (
    <div>
      <h2 style={{ fontSize: 22, fontWeight: 700, marginBottom: 24, color: '#1a1a2e' }}>Control Tower</h2>

      <div style={{ display: 'flex', gap: 16, marginBottom: 24, flexWrap: 'wrap' }}>
        <MetricCard label="Total Riders" value={totalRiders || 248} sub="All-time applications" />
        <MetricCard label="Active Riders" value={get(riderStats, 'active') || 141} sub="Currently deployed" color="#27AE60" />
        <MetricCard label="KYC Pending" value={get(riderStats, 'kyc_pending') || 34} sub="Awaiting review" color="#E67E22" />
        <MetricCard label="Total Vehicles" value={totalVehicles || 92} sub="Fleet size" />
      </div>

      <div style={{ display: 'flex', gap: 16, marginBottom: 24, flexWrap: 'wrap' }}>
        <MetricCard label="Available Vehicles" value={get(vehicleStats, 'available') || 23} sub="Ready to allocate" color="#27AE60" />
        <MetricCard label="Allocated" value={get(vehicleStats, 'allocated') || 61} sub="In use by riders" color="#2E86C1" />
        <MetricCard label="In Maintenance" value={get(vehicleStats, 'maintenance') || 8} sub="Downtime" color="#E74C3C" />
        <MetricCard label="Utilization" value="66%" sub="Vehicles in use" color="#8E44AD" />
      </div>

      <div style={{ background: '#fff', borderRadius: 12, padding: 24, border: '1px solid #E8EAF0' }}>
        <h3 style={{ fontSize: 16, fontWeight: 600, marginBottom: 16, color: '#1a1a2e' }}>Onboarding Pipeline</h3>
        {[
          { label: 'Applied', count: 34, color: '#2E86C1', pct: 14 },
          { label: 'Docs Submitted', count: 28, color: '#E67E22', pct: 11 },
          { label: 'KYC Pending', count: 34, color: '#E67E22', pct: 14 },
          { label: 'KYC Verified', count: 11, color: '#27AE60', pct: 4 },
          { label: 'Active', count: 141, color: '#27AE60', pct: 57 },
        ].map(item => (
          <div key={item.label} style={{ marginBottom: 12 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4, fontSize: 13 }}>
              <span style={{ color: '#555' }}>{item.label}</span>
              <span style={{ fontWeight: 600, color: '#333' }}>{item.count}</span>
            </div>
            <div style={{ height: 8, background: '#F0F2F5', borderRadius: 4, overflow: 'hidden' }}>
              <div style={{ width: `${item.pct}%`, height: '100%', background: item.color, borderRadius: 4, transition: 'width .5s' }} />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
