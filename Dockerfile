# syntax=docker/dockerfile:1

# Base image with Python and optional MATLAB Runtime (if available)
# For demo we start with python-slim; in production use a MATLAB Runtime image if you have compiled code.
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5001 \
    DEMO_MODE=1

# System deps (curl for healthcheck, fonts for matplotlib if needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates fonts-dejavu && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only requirements first for better layer caching
COPY requirements.txt /app/requirements.txt

# Install Python deps
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the entire project
COPY . /app/

# Create results directory
RUN mkdir -p /app/results

# Expose port
EXPOSE 5001

# Simple health endpoint (optional)
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS http://localhost:${PORT}/ || exit 1

# Run with gunicorn for production
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5001", "app:app", "-k", "gthread", "--threads", "4", "--timeout", "180"]
