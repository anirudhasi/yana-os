import React, { useState, useEffect } from 'react';
import { fleetAPI, onboardingAPI } from '../services/api';

const DEMO_VEHICLES = [
  { id: 'v1', registration_number: 'KA-01-AB-1234', model: 'Hero Electric Optima', hub_name: 'Koramangala', battery_health_pct: 82, odometer_km: 12400, status: 'available', vehicle_type: 'ev_2w' },
  { id: 'v2', registration_number: 'KA-01-CD-5678', model: 'Bounce Infinity E1', hub_name: 'HSR Layout', battery_health_pct: 54, odometer_km: 8220, status: 'available', vehicle_type: 'ev_2w' },
  { id: 'v3', registration_number: 'KA-03-EF-9012', model: 'Ather Rizta', hub_name: 'Whitefield', battery_health_pct: 95, odometer_km: 3100, status: 'available', vehicle_type: 'ev_2w' },
];
const DEMO_RIDERS = [
  { id: 'r2', user: { full_name: 'Suresh Patil', phone_number: '+91 87654 32109' }, onboarding_status: 'kyc_verified', hub_name: 'HSR Layout' },
  { id: 'r5', user: { full_name: 'Ramesh B', phone_number: '+91 54321 09876' }, onboarding_status: 'kyc_verified', hub_name: 'Koramangala' },
];

export default function VehicleAllocation() {
  const [vehicles, setVehicles] = useState(DEMO_VEHICLES);
  const [riders, setRiders] = useState(DEMO_RIDERS);
  const [selVehicle, setSelVehicle] = useState(DEMO_VEHICLES[0]);
  const [selRider, setSelRider] = useState(DEMO_RIDERS[0]);
  const [plan, setPlan] = useState('daily');
  const [startDate, setStartDate] = useState(new Date().toISOString().split('T')[0]);
  const [endDate, setEndDate] = useState('');
  const [rent, setRent] = useState(120);
  const [loading, setLoading] = useState(false);
  const [msg, setMsg] = useState('');

  useEffect(() => {
    fleetAPI.availableVehicles().then(r => { const d = r.data?.results || r.data; if (Array.isArray(d) && d.length) { setVehicles(d); setSelVehicle(d[0]); } }).catch(() => {});
    onboardingAPI.listRiders({ onboarding_status: 'kyc_verified' }).then(r => { const d = r.data?.results || r.data; if (Array.isArray(d) && d.length) { setRiders(d); setSelRider(d[0]); } }).catch(() => {});
  }, []);

  const doAllocate = async () => {
    if (!selVehicle || !selRider) return;
    setLoading(true); setMsg('');
    try {
      await fleetAPI.allocate({ vehicle_id: selVehicle.id, rider_id: selRider.id, plan_type: plan, start_date: startDate, end_date: endDate || null, daily_rent: rent });
      setMsg(`✅ Vehicle ${selVehicle.registration_number} allocated to ${selRider.user?.full_name}!`);
      setVehicles(v => v.filter(x => x.id !== selVehicle.id));
      setSelVehicle(vehicles.find(x => x.id !== selVehicle.id));
    } catch (e) {
      setMsg('Allocation failed: ' + (e.response?.data?.error || 'check backend'));
    } finally { setLoading(false); }
  };

  const battColor = (p) => p > 70 ? '#27AE60' : p > 40 ? '#E67E22' : '#E74C3C';

  const s = {
    grid: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 },
    panel: { background: '#fff', borderRadius: 12, border: '1px solid #E8EAF0', overflow: 'hidden' },
    header: { padding: '14px 18px', borderBottom: '1px solid #E8EAF0', display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: 14, fontWeight: 600, color: '#1a1a2e' },
    vehicleCard: (sel) => ({ display: 'flex', gap: 12, padding: '12px 16px', borderBottom: '1px solid #F4F6F9', cursor: 'pointer', background: sel ? '#F0F7FF' : 'transparent', alignItems: 'center' }),
    icon: { width: 44, height: 44, borderRadius: 10, background: '#D6EAF8', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22, flexShrink: 0 },
    formRow: { marginBottom: 14 },
    label: { display: 'block', fontSize: 12, color: '#666', marginBottom: 5, fontWeight: 500 },
    input: { width: '100%', padding: '8px 12px', border: '1px solid #ddd', borderRadius: 8, fontSize: 13, outline: 'none', boxSizing: 'border-box' },
    select: { width: '100%', padding: '8px 12px', border: '1px solid #ddd', borderRadius: 8, fontSize: 13, outline: 'none', background: '#fff' },
    btn: { width: '100%', padding: '12px', background: '#1B4F72', color: '#fff', border: 'none', borderRadius: 8, fontSize: 14, fontWeight: 600, cursor: 'pointer' },
    summary: { background: '#F4F6F9', borderRadius: 8, padding: '12px 16px', marginBottom: 16, fontSize: 13 },
    sumRow: { display: 'flex', justifyContent: 'space-between', marginBottom: 6, color: '#555' },
    sumTotal: { display: 'flex', justifyContent: 'space-between', fontWeight: 700, color: '#1a1a2e', paddingTop: 8, borderTop: '1px solid #ddd' },
  };

  const days = endDate ? Math.max(1, Math.ceil((new Date(endDate) - new Date(startDate)) / 86400000)) : (plan === 'daily' ? 1 : plan === 'weekly' ? 7 : 30);

  return (
    <div>
      <h2 style={{ fontSize: 22, fontWeight: 700, marginBottom: 20, color: '#1a1a2e' }}>Vehicle Allocation</h2>
      {msg && <div style={{ background: msg.startsWith('✅') ? '#D5F5E3' : '#FADBD8', color: msg.startsWith('✅') ? '#1E8449' : '#922B21', padding: '10px 16px', borderRadius: 8, marginBottom: 16, fontSize: 13 }}>{msg}</div>}
      <div style={s.grid}>
        {/* Available vehicles */}
        <div style={s.panel}>
          <div style={s.header}>
            Available Vehicles
            <span style={{ fontSize: 11, background: '#D5F5E3', color: '#1E8449', padding: '2px 8px', borderRadius: 10 }}>{vehicles.length} ready</span>
          </div>
          {vehicles.map(v => (
            <div key={v.id} style={s.vehicleCard(selVehicle?.id === v.id)} onClick={() => setSelVehicle(v)}>
              <div style={s.icon}>🛵</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 600, fontSize: 13 }}>{v.registration_number}</div>
                <div style={{ fontSize: 12, color: '#888' }}>{v.model} · {v.hub_name}</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 4 }}>
                  <span style={{ fontSize: 11, color: battColor(v.battery_health_pct), fontWeight: 600 }}>⚡ {v.battery_health_pct}%</span>
                  <div style={{ flex: 1, height: 5, background: '#eee', borderRadius: 3, overflow: 'hidden' }}>
                    <div style={{ width: `${v.battery_health_pct}%`, height: '100%', background: battColor(v.battery_health_pct), borderRadius: 3 }} />
                  </div>
                  <span style={{ fontSize: 11, color: '#aaa' }}>{(v.odometer_km / 1000).toFixed(1)}k km</span>
                </div>
              </div>
              {selVehicle?.id === v.id && <span style={{ color: '#1B4F72', fontSize: 18 }}>✓</span>}
            </div>
          ))}
        </div>

        {/* Allocation form */}
        <div style={s.panel}>
          <div style={s.header}>Allocate to Rider</div>
          <div style={{ padding: 18 }}>
            <div style={s.formRow}>
              <label style={s.label}>Select Rider (Verified)</label>
              <select style={s.select} value={selRider?.id || ''} onChange={e => setSelRider(riders.find(r => r.id === e.target.value))}>
                {riders.map(r => <option key={r.id} value={r.id}>{r.user?.full_name} — {r.hub_name}</option>)}
              </select>
            </div>
            <div style={s.formRow}>
              <label style={s.label}>Selected Vehicle</label>
              <input style={{ ...s.input, background: '#f9f9f9' }} readOnly value={selVehicle ? `${selVehicle.registration_number} — ${selVehicle.model}` : ''} />
            </div>
            <div style={s.formRow}>
              <label style={s.label}>Rental Plan</label>
              <select style={s.select} value={plan} onChange={e => setPlan(e.target.value)}>
                <option value="daily">Daily Rental</option>
                <option value="weekly">Weekly Rental</option>
                <option value="monthly">Monthly Rental</option>
              </select>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 14 }}>
              <div>
                <label style={s.label}>Start Date</label>
                <input type="date" style={s.input} value={startDate} onChange={e => setStartDate(e.target.value)} />
              </div>
              <div>
                <label style={s.label}>End Date</label>
                <input type="date" style={s.input} value={endDate} onChange={e => setEndDate(e.target.value)} />
              </div>
            </div>
            <div style={s.formRow}>
              <label style={s.label}>Daily Rent (₹)</label>
              <input type="number" style={s.input} value={rent} onChange={e => setRent(Number(e.target.value))} />
            </div>
            <div style={s.summary}>
              <div style={s.sumRow}><span>Daily rent</span><span>₹{rent}</span></div>
              <div style={s.sumRow}><span>Duration</span><span>{days} day{days > 1 ? 's' : ''}</span></div>
              <div style={s.sumTotal}><span>Total commitment</span><span>₹{rent * days}</span></div>
            </div>
            <button style={s.btn} onClick={doAllocate} disabled={loading || !selVehicle || !selRider}>
              {loading ? 'Allocating...' : '🛵 Confirm Allocation'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
