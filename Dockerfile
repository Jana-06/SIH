x# syntax=docker/dockerfile:1

# Base image with Python and optional MATLAB Runtime (if available)
# For demo we start with python-slim; in production use a MATLAB Runtime image if you have compiled code.
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5001

# System deps (curl for healthcheck, fonts for matplotlib if needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates fonts-dejavu && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only requirements first for better layer caching
COPY flask_server/requirements.txt /app/flask_server/requirements.txt

# Install Python deps
RUN pip install --no-cache-dir -r /app/flask_server/requirements.txt

# Copy the entire project so MATLAB .m files are available inside the container
# The Flask app expects to run from /app/flask_server and call MATLAB in the parent (/app)
COPY . /app/

# Expose port
EXPOSE 5001

# By default we assume MATLAB is on PATH inside the container. If not, the /run-matlab will error.
# Set this env to override MATLAB binary name if needed
ENV MATLAB_CMD=matlab

# Simple health endpoint (optional)
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS http://localhost:${PORT}/ || exit 1

# Set working directory to the Flask app folder so templates/static resolve correctly
WORKDIR /app/flask_server

# Run with gunicorn for production
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5001", "app:app"]
