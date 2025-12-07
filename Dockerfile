FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY backend/ ./backend/

# Expose port
EXPOSE 8000

# Build JAC files
RUN jsctl jac build backend/mindquest.jac && \
    jsctl jac build backend/agents/analyzer.jac && \
    jsctl jac build backend/agents/insights.jac && \
    jsctl jac build backend/agents/companion.jac && \
    jsctl jac build backend/training_data/collector.jac || true

# Start server
CMD ["jsctl", "serv", "-m", "-p", "8000", "--host", "0.0.0.0"]
