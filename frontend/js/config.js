// config.js - Frontend Configuration
export const config = {
  // API URL - points to your Render backend
  API_URL: import.meta.env.VITE_API_URL || 'https://mindquest-pxjz.onrender.com',
  
  // App configuration
  APP_NAME: import.meta.env.VITE_APP_NAME || 'MindQuest',
  VERSION: import.meta.env.VITE_VERSION || '1.0.0',
  ENABLE_ANALYTICS: import.meta.env.VITE_ENABLE_ANALYTICS === 'true',
  
  // API endpoints
  ENDPOINTS: {
    HEALTH: '/health',
    CHAT: '/api/chat',
    CREATE_JOURNAL: '/api/create_journal',
    GET_INSIGHTS: '/api/get_insights'
  }
};

// Helper function to build full endpoint URL
export const getEndpoint = (endpoint) => {
  return `${config.API_URL}${config.ENDPOINTS[endpoint]}`;
};

export default config;