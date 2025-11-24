import axios, { AxiosError } from "axios";
import { API_BASE_URL } from "../config";

// Create axios instance with default config
export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true, // Important: Include cookies in requests
  headers: {
    "Content-Type": "application/json",
  },
});

// Request interceptor (can be used for adding auth headers if needed)
apiClient.interceptors.request.use(
  (config) => {
    // Cookies are automatically included with withCredentials: true
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle 401/403
apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    // Don't redirect if already on login page to avoid infinite loop
    if (
      (error.response?.status === 401 || error.response?.status === 403) &&
      !window.location.pathname.includes("/login")
    ) {
      // Redirect to login - ProtectedRoute will also handle this
      window.location.href = "/login";
    }
    return Promise.reject(error);
  }
);

export default apiClient;
