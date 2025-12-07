import config from './config.js';

/**
 * Enhanced Jac Client with error handling, retry logic, and analytics
 */
class JacClient {
  constructor() {
    this.baseUrl = config.apiUrl;
    this.timeout = config.apiTimeout;
    this.retryAttempts = config.retryAttempts;
    this.headers = {
      'Content-Type': 'application/json'
    };
  }

  setAuthToken(token) {
    if (token) {
      this.headers['Authorization'] = `Bearer ${token}`;
    } else {
      delete this.headers['Authorization'];
    }
  }

  async spawn(walkerName, data = {}, options = {}) {
    const {
      retries = this.retryAttempts,
      timeout = this.timeout,
      onProgress = null,
      errorHandler = null
    } = options;

    let lastError;
    
    for (let attempt = 0; attempt <= retries; attempt++) {
      try {
        if (attempt > 0 && onProgress) {
          onProgress(`Retrying... (${attempt}/${retries})`);
        }

        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), timeout);

        const response = await fetch(`${this.baseUrl}/walker/${walkerName}`, {
          method: 'POST',
          headers: this.headers,
          body: JSON.stringify(data),
          signal: controller.signal
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}));
          throw new Error(
            errorData.message || `HTTP error! status: ${response.status}`
          );
        }

        const result = await response.json();
        
        // Log successful interaction for AI training
        if (config.enableTraining && config.enableAnalytics) {
          this.logInteraction(walkerName, data, result, true);
        }
        
        return result;

      } catch (error) {
        lastError = error;
        
        if (error.name === 'AbortError') {
          throw new Error('Request timeout');
        }
        
        if (error.message.includes('4')) {
          throw error;
        }
        
        if (attempt < retries) {
          await this.sleep(Math.pow(2, attempt) * 1000);
        }
      }
    }

    console.error(`Failed to call walker ${walkerName} after ${retries} retries:`, lastError);
    
    if (config.enableTraining && config.enableAnalytics) {
      this.logInteraction(walkerName, data, null, false, lastError.message);
    }
    
    if (errorHandler) {
      errorHandler(lastError);
    }
    
    throw lastError;
  }

  async logInteraction(walkerName, input, output, success, errorMsg = null) {
    try {
      if (walkerName === 'api_log_interaction') return;

      const interactionData = {
        walker: walkerName,
        timestamp: new Date().toISOString(),
        success: success,
        anonymized_input: this.anonymizeData(input),
        has_output: !!output,
        error: errorMsg
      };

      fetch(`${this.baseUrl}/walker/api_log_interaction`, {
        method: 'POST',
        headers: this.headers,
        body: JSON.stringify(interactionData),
        keepalive: true
      }).catch(() => {
        if (config.isDevelopment) {
          console.debug('Analytics logging failed');
        }
      });
    } catch (error) {
      if (config.isDevelopment) {
        console.debug('Analytics logging error:', error);
      }
    }
  }

  anonymizeData(data) {
    if (!data) return {};
    
    const sanitized = { ...data };
    
    const piiFields = ['email', 'name', 'phone', 'address', 'user_id'];
    piiFields.forEach(field => {
      if (sanitized[field]) {
        sanitized[field] = this.hashString(sanitized[field]);
      }
    });
    
    return {
      emotion: sanitized.emotion,
      intensity_range: sanitized.intensity ? this.bucketIntensity(sanitized.intensity) : null,
      has_notes: !!sanitized.notes,
      timestamp_bucket: this.bucketTimestamp(new Date())
    };
  }

  hashString(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return `anon_${Math.abs(hash)}`;
  }

  bucketIntensity(intensity) {
    if (intensity <= 3) return 'low';
    if (intensity <= 7) return 'medium';
    return 'high';
  }

  bucketTimestamp(date) {
    return `${date.getHours()}:00`;
  }

  async healthCheck() {
    try {
      const response = await fetch(`${this.baseUrl}/walker/health_check`, {
        method: 'POST',
        headers: this.headers,
        body: JSON.stringify({})
      });
      
      if (response.ok) {
        const data = await response.json();
        return { healthy: true, data };
      }
      return { healthy: false, error: `Status: ${response.status}` };
    } catch (error) {
      return { healthy: false, error: error.message };
    }
  }

  async batchSpawn(requests) {
    const promises = requests.map(({ walker, data, options }) =>
      this.spawn(walker, data, options).catch(error => ({ error: error.message }))
    );
    return Promise.all(promises);
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async getStatus() {
    try {
      const health = await this.healthCheck();
      return {
        ...health,
        baseUrl: this.baseUrl,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      return {
        healthy: false,
        error: error.message,
        baseUrl: this.baseUrl,
        timestamp: new Date().toISOString()
      };
    }
  }
}

const jacClient = new JacClient();

export default jacClient;
export { JacClient };