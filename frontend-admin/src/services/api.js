import axios from 'axios';

const API_BASE = process.env.REACT_APP_API_URL || '/api';

const api = axios.create({ baseURL: API_BASE, timeout: 15000 });

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  (res) => res,
  async (err) => {
    if (err.response?.status === 401) {
      const refresh = localStorage.getItem('refresh_token');
      if (refresh) {
        try {
          const res = await axios.post(`${API_BASE}/auth/token/refresh/`, { refresh });
          localStorage.setItem('access_token', res.data.access);
          err.config.headers.Authorization = `Bearer ${res.data.access}`;
          return api.request(err.config);
        } catch {
          localStorage.clear();
          window.location.href = '/login';
        }
      }
    }
    return Promise.reject(err);
  }
);

export const authAPI = {
  requestOTP: (phone) => api.post('/auth/otp/request/', { phone_number: phone }),
  verifyOTP: (phone, otp) => api.post('/auth/otp/verify/', { phone_number: phone, otp }),
  me: () => api.get('/auth/me/'),
};

export const onboardingAPI = {
  listRiders: (params) => api.get('/onboarding/riders/', { params }),
  getRider: (id) => api.get(`/onboarding/riders/${id}/`),
  verifyRider: (id, data) => api.post(`/onboarding/riders/${id}/verify/`, data),
  activateRider: (id) => api.post(`/onboarding/riders/${id}/activate/`),
  getStats: () => api.get('/onboarding/riders/stats/'),
  getEvents: (id) => api.get(`/onboarding/riders/${id}/events/`),
};

export const fleetAPI = {
  listVehicles: (params) => api.get('/fleet/vehicles/', { params }),
  availableVehicles: (params) => api.get('/fleet/vehicles/available/', { params }),
  getVehicleStats: () => api.get('/fleet/vehicles/stats/'),
  listHubs: () => api.get('/fleet/hubs/'),
  allocate: (data) => api.post('/fleet/allocations/allocate/', data),
  returnVehicle: (id) => api.post(`/fleet/allocations/${id}/return_vehicle/`),
  listAllocations: (params) => api.get('/fleet/allocations/', { params }),
};

export default api;
