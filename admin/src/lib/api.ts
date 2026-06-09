import axios, { AxiosInstance, AxiosResponse } from 'axios';

class ApiClient {
  private client: AxiosInstance;
  private baseURL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

  constructor() {
    this.client = axios.create({
      baseURL: this.baseURL,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.client.interceptors.request.use((config) => {
      const token = localStorage.getItem('accessToken');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });

    this.client.interceptors.response.use(
      (response) => response,
      async (error) => {
        if (error.response?.status === 401) {
          const refreshToken = localStorage.getItem('refreshToken');
          if (refreshToken) {
            try {
              const refreshResponse = await axios.post(`${this.baseURL}/auth/refresh`, {
                refreshToken,
              });
              const { accessToken } = refreshResponse.data;
              localStorage.setItem('accessToken', accessToken);
              error.config.headers.Authorization = `Bearer ${accessToken}`;
              return this.client.request(error.config);
            } catch (refreshError) {
              localStorage.removeItem('accessToken');
              localStorage.removeItem('refreshToken');
              window.location.href = '/login';
            }
          } else {
            localStorage.removeItem('accessToken');
            localStorage.removeItem('refreshToken');
            window.location.href = '/login';
          }
        }
        return Promise.reject(error);
      }
    );
  }

  // Auth methods
  async login(username: string, password: string) {
    const response = await this.client.post('/auth/login', { username, password });
    const { accessToken, refreshToken } = response.data;
    localStorage.setItem('accessToken', accessToken);
    localStorage.setItem('refreshToken', refreshToken);
    return response.data;
  }

  async register(username: string, phone: string, password: string) {
    const response = await this.client.post('/auth/register', { username, phone, password });
    const { accessToken, refreshToken } = response.data;
    localStorage.setItem('accessToken', accessToken);
    localStorage.setItem('refreshToken', refreshToken);
    return response.data;
  }

  async logout() {
    const refreshToken = localStorage.getItem('refreshToken');
    if (refreshToken) {
      await this.client.post('/auth/logout', { refreshToken });
    }
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  }

  // User methods
  async getProfile() {
    const response = await this.client.get('/users/me');
    return response.data;
  }

  async updateProfile(data: any) {
    const response = await this.client.patch('/users/me', data);
    return response.data;
  }

  // Activities
  async getActivities() {
    const response = await this.client.get('/activities/me');
    return response.data;
  }

  async createActivity(data: any) {
    const response = await this.client.post('/activities', data);
    return response.data;
  }

  // Territories
  async getTerritories() {
    const response = await this.client.get('/territories');
    return response.data;
  }

  async claimTerritory(data: any) {
    const response = await this.client.post('/territories/claim', data);
    return response.data;
  }

  // Payments
  async getPayments() {
    const response = await this.client.get('/payments/me');
    return response.data;
  }

  async createPayment(data: any) {
    const response = await this.client.post('/payments', data);
    return response.data;
  }

  // Friends
  async getFriends() {
    const response = await this.client.get('/friends');
    return response.data;
  }

  async sendFriendRequest(data: any) {
    const response = await this.client.post('/friends/request', data);
    return response.data;
  }

  async acceptFriendRequest(data: any) {
    const response = await this.client.post('/friends/accept', data);
    return response.data;
  }

  // Challenges
  async getChallenges() {
    const response = await this.client.get('/challenges');
    return response.data;
  }

  async createChallenge(data: any) {
    const response = await this.client.post('/challenges', data);
    return response.data;
  }

  async joinChallenge(data: any) {
    const response = await this.client.post('/challenges/join', data);
    return response.data;
  }

  // Notifications
  async getNotifications() {
    const response = await this.client.get('/notifications/me');
    return response.data;
  }

  async markNotificationRead(data: any) {
    const response = await this.client.patch('/notifications/read', data);
    return response.data;
  }
}

export const apiClient = new ApiClient();
