import React, { useState, useEffect } from 'react';
import { fleetAPI } from '../services/api';

const DEMO = [
  { id: 'v1', registration_number: 'KA-01-AB-1234', model: 'Hero Electric Optima', hub_name: 'Koramangala', battery_health_pct: 82, odometer_km: 12400, status: 'available' },
  { id: 'v2', registration_number: 'KA-01-CD-5678', model: 'Bounce Infinity E1', hub_name: 'HSR Layout', battery_health_pct: 54, odometer_km: 8220, status: 'allocated' },
  { id: 'v3', registration_number: 'KA-03-EF-9012', model: 'Ather Rizta', hub_name: 'Whitefield', battery_health_pct: 95, odometer_km: 3100, status: 'available' },
  { id: 'v4', registration_number: 'KA-02-GH-3456', model: 'Hero Electric Photon', hub_name: 'Koramangala', battery_health_pct: 35, odometer_km: 21000, status: 'maintenance' },
  { id: 'v5', registration_number: 'KA-05-IJ-7890', model: 'Ampere Magnus EX', hub_name: 'Indiranagar', battery_health_pct: 70, odometer_km: 6500, status: 'allocated' },
];

const pillColors = { available: ['#D5F5E3', '#1E8449'], allocated: ['#D6EAF8', '#1A5276'], maintenance: ['#FADBD8', '#922B21'] };
const battColor = (p) => p > 70 ? '#27AE60' : p > 40 ? '#E67E22' : '#E74C3C';

export default function Fleet() {
  const [vehicles, setVehicles] = useState(DEMO);
  const [filter, setFilter] = useState('');

  useEffect(() => {
    fleetAPI.listVehicles().then(r => { const d = r.data?.results || r.data; if (Array.isArray(d) && d.length) setVehicles(d); }).catch(() => {});
  }, []);

  const filtered = filter ? vehicles.filter(v => v.status === filter) : vehicles;

  const s = {
    panel: { background: '#fff', borderRadius: 12, border: '1px solid #E8EAF0', overflow: 'hidden' },
    header: { padding: '14px 18px', borderBottom: '1px solid #E8EAF0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' },
    table: { width: '100%', borderCollapse: 'collapse', fontSize: 13 },
    th: { padding: '8px 16px', textAlign: 'left', color: '#999', fontWeight: 400, fontSize: 11, borderBottom: '1px solid #E8EAF0' },
    td: { padding: '12px 16px', borderBottom: '1px solid #F4F6F9' },
  };

  return (
    <div>
      <h2 style={{ fontSize: 22, fontWeight: 700, marginBottom: 20, color: '#1a1a2e' }}>Fleet Management</h2>
      <div style={{ display: 'flex', gap: 12, marginBottom: 16 }}>
        {['', 'available', 'allocated', 'maintenance'].map(f => (
          <button key={f} onClick={() => setFilter(f)} style={{ padding: '7px 16px', borderRadius: 8, border: '1px solid ' + (filter === f ? '#1B4F72' : '#ddd'), background: filter === f ? '#1B4F72' : '#fff', color: filter === f ? '#fff' : '#555', fontSize: 13, cursor: 'pointer' }}>
            {f || 'All Vehicles'}
          </button>
        ))}
      </div>
      <div style={s.panel}>
        <div style={s.header}>
          <span style={{ fontSize: 14, fontWeight: 600 }}>Vehicle Fleet</span>
          <span style={{ fontSize: 12, color: '#888' }}>{filtered.length} vehicles</span>
        </div>
        <table style={s.table}>
          <thead><tr>
            <th style={s.th}>Vehicle</th>
            <th style={s.th}>Hub</th>
            <th style={s.th}>Battery</th>
            <th style={s.th}>Odometer</th>
            <th style={s.th}>Status</th>
          </tr></thead>
          <tbody>
            {filtered.map(v => {
              const [bg, fg] = pillColors[v.status] || ['#eee', '#555'];
              return (
                <tr key={v.id}>
                  <td style={s.td}>
                    <div style={{ fontWeight: 600 }}>🛵 {v.registration_number}</div>
                    <div style={{ fontSize: 11, color: '#aaa' }}>{v.model}</div>
                  </td>
                  <td style={{ ...s.td, fontSize: 12, color: '#666' }}>{v.hub_name}</td>
                  <td style={s.td}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                      <div style={{ width: 60, height: 7, background: '#eee', borderRadius: 4, overflow: 'hidden' }}>
                        <div style={{ width: `${v.battery_health_pct}%`, height: '100%', background: battColor(v.battery_health_pct), borderRadius: 4 }} />
                      </div>
                      <span style={{ fontSize: 12, color: battColor(v.battery_health_pct), fontWeight: 600 }}>{v.battery_health_pct}%</span>
                    </div>
                  </td>
                  <td style={{ ...s.td, fontSize: 12, color: '#666' }}>{v.odometer_km.toLocaleString()} km</td>
                  <td style={s.td}>
                    <span style={{ background: bg, color: fg, fontSize: 11, fontWeight: 600, padding: '3px 10px', borderRadius: 20 }}>
                      {v.status.toUpperCase()}
                    </span>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
