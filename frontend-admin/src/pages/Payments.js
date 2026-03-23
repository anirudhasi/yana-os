import React from 'react';

export default function Payments() {
  const txns = [
    { id: 1, rider: 'Mohan Das', type: 'Rent Debit', amount: -120, date: '23 Mar 2026', status: 'success' },
    { id: 2, rider: 'Suresh Patil', type: 'Wallet Top-up', amount: 500, date: '22 Mar 2026', status: 'success' },
    { id: 3, rider: 'Ravi Kumar', type: 'Incentive Credit', amount: 50, date: '22 Mar 2026', status: 'success' },
    { id: 4, rider: 'Lakshmi N', type: 'Rent Debit', amount: -120, date: '22 Mar 2026', status: 'pending' },
  ];
  const s = {
    panel: { background: '#fff', borderRadius: 12, border: '1px solid #E8EAF0', overflow: 'hidden' },
    th: { padding: '8px 16px', textAlign: 'left', color: '#999', fontWeight: 400, fontSize: 11, borderBottom: '1px solid #E8EAF0' },
    td: { padding: '12px 16px', borderBottom: '1px solid #F4F6F9', fontSize: 13 },
  };
  return (
    <div>
      <h2 style={{ fontSize: 22, fontWeight: 700, marginBottom: 20, color: '#1a1a2e' }}>Payments</h2>
      <div style={{ display: 'flex', gap: 16, marginBottom: 20 }}>
        {[{ label: 'Total Collected', val: '₹18,400', color: '#27AE60' }, { label: 'Pending Dues', val: '₹4,080', color: '#E67E22' }, { label: 'Incentives Paid', val: '₹2,350', color: '#2E86C1' }]
          .map(m => <div key={m.label} style={{ flex: 1, background: '#fff', border: '1px solid #E8EAF0', borderRadius: 12, padding: '18px 22px' }}>
            <div style={{ fontSize: 12, color: '#888', marginBottom: 6 }}>{m.label}</div>
            <div style={{ fontSize: 28, fontWeight: 700, color: m.color }}>{m.val}</div>
          </div>)}
      </div>
      <div style={s.panel}>
        <div style={{ padding: '14px 18px', borderBottom: '1px solid #E8EAF0', fontSize: 14, fontWeight: 600 }}>Recent Transactions</div>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
          <thead><tr>
            <th style={s.th}>Rider</th><th style={s.th}>Type</th><th style={s.th}>Amount</th><th style={s.th}>Date</th><th style={s.th}>Status</th>
          </tr></thead>
          <tbody>
            {txns.map(t => (
              <tr key={t.id}>
                <td style={s.td}>{t.rider}</td>
                <td style={s.td}>{t.type}</td>
                <td style={{ ...s.td, fontWeight: 600, color: t.amount > 0 ? '#27AE60' : '#E74C3C' }}>{t.amount > 0 ? '+' : ''}₹{Math.abs(t.amount)}</td>
                <td style={{ ...s.td, color: '#888' }}>{t.date}</td>
                <td style={s.td}><span style={{ background: t.status === 'success' ? '#D5F5E3' : '#FDEBD0', color: t.status === 'success' ? '#1E8449' : '#784212', fontSize: 11, fontWeight: 600, padding: '3px 10px', borderRadius: 20 }}>{t.status.toUpperCase()}</span></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
