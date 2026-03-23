import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { authAPI } from '../services/api';

export default function Login() {
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState('phone');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const sendOTP = async () => {
    setLoading(true); setError('');
    try {
      await authAPI.requestOTP('+91' + phone);
      setStep('otp');
    } catch (e) {
      setError(e.response?.data?.error || 'Failed to send OTP');
    } finally { setLoading(false); }
  };

  const verifyOTP = async () => {
    setLoading(true); setError('');
    try {
      const res = await authAPI.verifyOTP('+91' + phone, otp);
      localStorage.setItem('access_token', res.data.access);
      localStorage.setItem('refresh_token', res.data.refresh);
      navigate('/dashboard');
    } catch (e) {
      setError(e.response?.data?.error || 'Invalid OTP');
    } finally { setLoading(false); }
  };

  const s = {
    page: { minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#1B4F72' },
    card: { background: '#fff', borderRadius: 16, padding: 40, width: 380, boxShadow: '0 20px 60px rgba(0,0,0,0.3)' },
    logo: { textAlign: 'center', marginBottom: 32 },
    logoText: { fontSize: 28, fontWeight: 700, color: '#1B4F72' },
    logoSub: { fontSize: 14, color: '#666', marginTop: 4 },
    label: { display: 'block', fontSize: 13, color: '#555', marginBottom: 6, fontWeight: 500 },
    input: { width: '100%', padding: '10px 14px', border: '1px solid #ddd', borderRadius: 8, fontSize: 14, outline: 'none', boxSizing: 'border-box' },
    btn: { width: '100%', padding: '12px', background: '#1B4F72', color: '#fff', border: 'none', borderRadius: 8, fontSize: 15, fontWeight: 600, cursor: 'pointer', marginTop: 20 },
    error: { background: '#ffeaea', color: '#c0392b', padding: '10px 14px', borderRadius: 8, fontSize: 13, marginTop: 12 },
  };

  return (
    <div style={s.page}>
      <div style={s.card}>
        <div style={s.logo}>
          <div style={s.logoText}>Yana OS</div>
          <div style={s.logoSub}>Operations Dashboard</div>
        </div>
        {step === 'phone' ? (
          <>
            <label style={s.label}>Mobile Number</label>
            <div style={{ display: 'flex', gap: 8 }}>
              <span style={{ ...s.input, width: 56, textAlign: 'center', background: '#f5f5f5', color: '#333' }}>+91</span>
              <input style={{ ...s.input, flex: 1 }} placeholder="98765 43210" maxLength={10}
                value={phone} onChange={e => setPhone(e.target.value.replace(/\D/g, ''))}
                onKeyDown={e => e.key === 'Enter' && sendOTP()} />
            </div>
            <button style={s.btn} onClick={sendOTP} disabled={loading}>
              {loading ? 'Sending...' : 'Send OTP'}
            </button>
          </>
        ) : (
          <>
            <label style={s.label}>Enter OTP sent to +91 {phone}</label>
            <input style={s.input} placeholder="6-digit OTP" maxLength={6}
              value={otp} onChange={e => setOtp(e.target.value.replace(/\D/g, ''))}
              onKeyDown={e => e.key === 'Enter' && verifyOTP()} autoFocus />
            <button style={s.btn} onClick={verifyOTP} disabled={loading}>
              {loading ? 'Verifying...' : 'Verify & Login'}
            </button>
            <div style={{ textAlign: 'center', marginTop: 12 }}>
              <span style={{ fontSize: 13, color: '#888', cursor: 'pointer' }} onClick={() => setStep('phone')}>
                ← Change number
              </span>
            </div>
          </>
        )}
        {error && <div style={s.error}>{error}</div>}
        <div style={{ textAlign: 'center', marginTop: 20, fontSize: 12, color: '#aaa' }}>
          For Ops / Sales / Admin team access only
        </div>
      </div>
    </div>
  );
}
