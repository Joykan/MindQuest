// Configuration management for MindQuest
const getEnvVar = (key, defaultValue = '') => {
  // For Vercel, environment variables are available at build time
  if (typeof import.meta !== 'undefined' && import.meta.env) {
    return import.meta.env[key] || defaultValue;
  }
  // Fallback for development
  return window.ENV?.[key] || defaultValue;
};

const config = {
  // API Configuration
  apiUrl: getEnvVar('VITE_API_URL', 'http://localhost:8000'),
  
  // App Configuration
  appName: getEnvVar('VITE_APP_NAME', 'MindQuest'),
  version: getEnvVar('VITE_VERSION', '1.0.0'),
  
  // Feature Flags
  enableAnalytics: getEnvVar('VITE_ENABLE_ANALYTICS', 'false') === 'true',
  enableAuth: getEnvVar('VITE_ENABLE_AUTH', 'true') === 'true',
  enableTraining: getEnvVar('VITE_ENABLE_TRAINING', 'true') === 'true',
  
  // Development Mode
  isDevelopment: getEnvVar('NODE_ENV', 'production') === 'development',
  
  // Timeouts
  apiTimeout: 30000,
  retryAttempts: 3,
  
  // Storage Keys
  storageKeys: {
    userId: 'mindquest_user_id',
    authToken: 'mindquest_auth_token',
    preferences: 'mindquest_preferences'
  },
  
  // UI Configuration
  ui: {
    emotions: ['happy', 'sad', 'anxious', 'angry', 'calm', 'excited'],
    intensityRange: [1, 10],
    chartColors: {
      happy: '#4CAF50',
      sad: '#2196F3',
      anxious: '#FF9800',
      angry: '#F44336',
      calm: '#9C27B0',
      excited: '#FFEB3B'
    }
  }
};

// Log configuration in development
if (config.isDevelopment) {
  console.log('MindQuest Configuration:', config);
}

// Validate critical configuration
if (!config.apiUrl) {
  console.error('API URL is not configured! Please set VITE_API_URL');
}

export default config;