import React, { useState, useEffect } from 'react';
import { onboardingAPI } from '../services/api';

const DEMO_RIDERS = [
  { id: 'r1', user: { full_name: 'Ravi Kumar', phone_number: '+91 98765 43210' }, onboarding_status: 'applied', hub_name: 'Koramangala' },
  { id: 'r2', user: { full_name: 'Suresh Patil', phone_number: '+91 87654 32109' }, onboarding_status: 'kyc_verified', hub_name: 'HSR Layout' },
  { id: 'r3', user: { full_name: 'Mohan Das', phone_number: '+91 76543 21098' }, onboarding_status: 'active', hub_name: 'Whitefield' },
  { id: 'r4', user: { full_name: 'Lakshmi N', phone_number: '+91 65432 10987' }, onboarding_status: 'kyc_pending', hub_name: 'Indiranagar' },
  { id: 'r5', user: { full_name: 'Ramesh B', phone_number: '+91 54321 09876' }, onboarding_status: 'kyc_verified', hub_name: 'Koramangala' },
  { id: 'r6', user: { full_name: 'Priya S', phone_number: '+91 43210 98765' }, onboarding_status: 'docs_submitted', hub_name: 'Marathahalli' },
];

const pillColors = {
  applied: { bg: '#D6EAF8', fg: '#1A5276' },
  kyc_pending: { bg: '#FDEBD0', fg: '#784212' },
  docs_submitted: { bg: '#EBF5FB', fg: '#1A5276' },
  kyc_verified: { bg: '#D5F5E3', fg: '#1E8449' },
  active: { bg: '#D5F5E3', fg: '#1E8449' },
  rejected: { bg: '#FADBD8', fg: '#922B21' },
};

const StatusPill = ({ status }) => {
  const c = pillColors[status] || { bg: '#eee', fg: '#555' };
  return (
    <span style={{ background: c.bg, color: c.fg, fontSize: 11, fontWeight: 600, padding: '3px 10px', borderRadius: 20, whiteSpace: 'nowrap' }}>
      {status.replace(/_/g, ' ').toUpperCase()}
    </span>
  );
};

const STEPS = ['Applied', 'Docs', 'KYC', 'Training', 'Active'];
const stepForStatus = { applied: 0, docs_submitted: 1, kyc_pending: 2, kyc_verified: 2, training_pending: 3, active: 4 };

export default function Onboarding() {
  const [riders, setRiders] = useState(DEMO_RIDERS);
  const [selected, setSelected] = useState(DEMO_RIDERS[0]);
  const [search, setSearch] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [tab, setTab] = useState('profile');
  const [loading, setLoading] = useState(false);
  const [msg, setMsg] = useState('');

  useEffect(() => {
    onboardingAPI.listRiders().then(r => {
      const data = r.data?.results || r.data;
      if (Array.isArray(data) && data.length) { setRiders(data); setSelected(data[0]); }
    }).catch(() => {});
  }, []);

  const filtered = riders.filter(r => {
    const name = r.user?.full_name?.toLowerCase() || '';
    const phone = r.user?.phone_number || '';
    const matchSearch = !search || name.includes(search.toLowerCase()) || phone.includes(search);
    const matchStatus = !filterStatus || r.onboarding_status === filterStatus;
    return matchSearch && matchStatus;
  });

  const doVerify = async (action) => {
    setLoading(true); setMsg('');
    try {
      await onboardingAPI.verifyRider(selected.id, { action });
      const updated = riders.map(r => r.id === selected.id
        ? { ...r, onboarding_status: action === 'approve' ? 'kyc_verified' : 'rejected' } : r);
      setRiders(updated);
      const sel = updated.find(r => r.id === selected.id);
      setSelected(sel);
      setMsg(action === 'approve' ? '✅ Rider verified successfully!' : '❌ Rider rejected.');
    } catch { setMsg('Action failed. Is the backend running?'); }
    finally { setLoading(false); }
  };

  const s = {
    grid: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 },
    panel: { background: '#fff', borderRadius: 12, border: '1px solid #E8EAF0', overflow: 'hidden' },
    panelHeader: { padding: '14px 18px', borderBottom: '1px solid #E8EAF0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' },
    panelTitle: { fontSize: 14, fontWeight: 600, color: '#1a1a2e' },
    searchBar: { display: 'flex', gap: 8, padding: '10px 16px', borderBottom: '1px solid #E8EAF0' },
    input: { flex: 1, padding: '6px 10px', border: '1px solid #ddd', borderRadius: 6, fontSize: 12, outline: 'none' },
    select: { padding: '6px 10px', border: '1px solid #ddd', borderRadius: 6, fontSize: 12, outline: 'none' },
    table: { width: '100%', borderCollapse: 'collapse', fontSize: 13 },
    th: { padding: '8px 16px', textAlign: 'left', color: '#999', fontWeight: 400, fontSize: 11, borderBottom: '1px solid #E8EAF0' },
    td: { padding: '10px 16px', borderBottom: '1px solid #F4F6F9', color: '#333' },
    tabBar: { display: 'flex', borderBottom: '1px solid #E8EAF0' },
    tabBtn: (active) => ({ padding: '10px 18px', fontSize: 13, border: 'none', background: 'none', cursor: 'pointer', color: active ? '#1B4F72' : '#888', borderBottom: active ? '2px solid #1B4F72' : '2px solid transparent', fontWeight: active ? 600 : 400 }),
    row: { display: 'flex', gap: 8, marginBottom: 8, alignItems: 'center' },
    key: { fontSize: 12, color: '#888', width: 110, flexShrink: 0 },
    val: { fontSize: 13, color: '#333' },
    btn: (color) => ({ padding: '8px 16px', background: color, color: '#fff', border: 'none', borderRadius: 8, fontSize: 13, fontWeight: 600, cursor: 'pointer', flex: 1 }),
    step: (done, active) => ({ width: 28, height: 28, borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 12, fontWeight: 700, background: done ? '#27AE60' : active ? '#1B4F72' : '#E8EAF0', color: done || active ? '#fff' : '#aaa', flexShrink: 0 }),
  };

  const curStep = stepForStatus[selected?.onboarding_status] ?? 0;

  return (
    <div>
      <h2 style={{ fontSize: 22, fontWeight: 700, marginBottom: 20, color: '#1a1a2e' }}>Rider Onboarding</h2>
      {msg && <div style={{ background: msg.startsWith('✅') ? '#D5F5E3' : '#FADBD8', color: msg.startsWith('✅') ? '#1E8449' : '#922B21', padding: '10px 16px', borderRadius: 8, marginBottom: 16, fontSize: 13 }}>{msg}</div>}
      <div style={s.grid}>
        {/* Left panel — list */}
        <div style={s.panel}>
          <div style={s.panelHeader}>
            <span style={s.panelTitle}>Rider Applications</span>
            <span style={{ fontSize: 11, background: '#D6EAF8', color: '#1A5276', padding: '2px 8px', borderRadius: 10 }}>{riders.length} total</span>
          </div>
          <div style={s.searchBar}>
            <input style={s.input} placeholder="Search name or phone..." value={search} onChange={e => setSearch(e.target.value)} />
            <select style={s.select} value={filterStatus} onChange={e => setFilterStatus(e.target.value)}>
              <option value="">All</option>
              <option value="applied">Applied</option>
              <option value="kyc_pending">KYC Pending</option>
              <option value="kyc_verified">Verified</option>
              <option value="active">Active</option>
            </select>
          </div>
          <table style={s.table}>
            <thead><tr>
              <th style={s.th}>Rider</th>
              <th style={s.th}>Status</th>
              <th style={s.th}>Hub</th>
            </tr></thead>
            <tbody>
              {filtered.map(r => (
                <tr key={r.id} onClick={() => setSelected(r)} style={{ cursor: 'pointer', background: selected?.id === r.id ? '#F0F7FF' : 'transparent' }}>
                  <td style={s.td}>
                    <div style={{ fontWeight: 600 }}>{r.user?.full_name}</div>
                    <div style={{ fontSize: 11, color: '#aaa' }}>{r.user?.phone_number}</div>
                  </td>
                  <td style={s.td}><StatusPill status={r.onboarding_status} /></td>
                  <td style={{ ...s.td, fontSize: 12, color: '#888' }}>{r.hub_name}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Right panel — detail */}
        <div style={s.panel}>
          <div style={s.tabBar}>
            {['profile', 'documents', 'history'].map(t => (
              <button key={t} style={s.tabBtn(tab === t)} onClick={() => setTab(t)}>
                {t.charAt(0).toUpperCase() + t.slice(1)}
              </button>
            ))}
          </div>
          <div style={{ padding: 18 }}>
            {/* Progress stepper */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 0, marginBottom: 20 }}>
              {STEPS.map((step, i) => (
                <React.Fragment key={step}>
                  <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
                    <div style={s.step(i < curStep, i === curStep)}>{i < curStep ? '✓' : i + 1}</div>
                    <span style={{ fontSize: 9, color: i <= curStep ? '#1B4F72' : '#aaa', whiteSpace: 'nowrap' }}>{step}</span>
                  </div>
                  {i < STEPS.length - 1 && <div style={{ flex: 1, height: 2, background: i < curStep ? '#27AE60' : '#E8EAF0', margin: '0 4px', marginBottom: 14 }} />}
                </React.Fragment>
              ))}
            </div>

            {tab === 'profile' && selected && (
              <>
                <div style={{ fontSize: 11, color: '#aaa', textTransform: 'uppercase', letterSpacing: '.04em', marginBottom: 10 }}>Personal</div>
                <div style={s.row}><span style={s.key}>Full name</span><span style={s.val}>{selected.user?.full_name}</span></div>
                <div style={s.row}><span style={s.key}>Phone</span><span style={s.val}>{selected.user?.phone_number}</span></div>
                <div style={s.row}><span style={s.key}>Hub</span><span style={s.val}>{selected.hub_name}</span></div>
                <div style={s.row}><span style={s.key}>Status</span><StatusPill status={selected.onboarding_status} /></div>
                <div style={{ marginTop: 20, fontSize: 11, color: '#aaa', textTransform: 'uppercase', letterSpacing: '.04em', marginBottom: 10 }}>KYC Details</div>
                <div style={s.row}><span style={s.key}>Aadhaar</span><span style={s.val}>XXXX XXXX 4821</span></div>
                <div style={s.row}><span style={s.key}>DL Number</span><span style={s.val}>KA-05-20190123</span></div>
                <div style={s.row}><span style={s.key}>Bank A/C</span><span style={s.val}>SBI xxxxxx8901</span></div>
                <div style={{ display: 'flex', gap: 10, marginTop: 20 }}>
                  <button style={s.btn('#27AE60')} onClick={() => doVerify('approve')} disabled={loading}>
                    {loading ? '...' : '✓ Approve KYC'}
                  </button>
                  <button style={s.btn('#E74C3C')} onClick={() => doVerify('reject')} disabled={loading}>
                    ✗ Reject
                  </button>
                </div>
              </>
            )}

            {tab === 'documents' && (
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
                {[
                  { name: 'Aadhaar Card', status: 'pending' },
                  { name: 'Driving License', status: 'kyc_verified' },
                  { name: 'Bank Passbook', status: 'pending' },
                  { name: 'Passport Photo', status: 'applied' },
                ].map(doc => (
                  <div key={doc.name} style={{ border: '1px solid #E8EAF0', borderRadius: 10, padding: 14 }}>
                    <div style={{ fontWeight: 600, fontSize: 13 }}>{doc.name}</div>
                    <div style={{ marginTop: 8 }}><StatusPill status={doc.status} /></div>
                    <div style={{ marginTop: 8, fontSize: 12, color: '#2E86C1', cursor: 'pointer' }}>View document →</div>
                  </div>
                ))}
              </div>
            )}

            {tab === 'history' && (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                {[
                  { time: '22 Mar 09:12', text: 'Applied via Rider App' },
                  { time: '22 Mar 09:45', text: 'Aadhaar uploaded' },
                  { time: '22 Mar 10:02', text: 'DL uploaded & auto-verified' },
                  { time: '22 Mar 11:30', text: 'Assigned to hub' },
                ].map((e, i) => (
                  <div key={i} style={{ fontSize: 13, display: 'flex', gap: 10 }}>
                    <span style={{ color: '#aaa', fontSize: 11, whiteSpace: 'nowrap', marginTop: 2 }}>{e.time}</span>
                    <span style={{ color: '#333' }}>{e.text}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
