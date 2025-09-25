#!/bin/bash

echo "🌾 Agricultural Monitoring Dashboard - Local Development with MATLAB"
echo "=================================================================="

# Set environment for MATLAB integration
export DEMO_MODE=0
export FLASK_DEBUG=1
export MATLAB_CMD=matlab

echo "Environment configured for MATLAB integration:"
echo "- DEMO_MODE=0 (MATLAB analysis enabled)"  
echo "- FLASK_DEBUG=1 (Debug mode enabled)"
echo "- MATLAB_CMD=matlab (Default MATLAB command)"
echo ""

# Check if MATLAB is available
if command -v matlab &> /dev/null; then
    echo "✅ MATLAB found in PATH"
else
    echo "⚠️  MATLAB not found in PATH. Please ensure MATLAB is installed and accessible."
    echo "   You can set custom MATLAB path with: export MATLAB_CMD=/path/to/matlab"
fi

echo ""
echo "🚀 Starting Flask development server..."
echo "📊 Your dashboard will be available at: http://localhost:5001"
echo "🧪 Click 'Run Analysis' to execute MATLAB analysis and generate real visualizations"
echo ""

# Install requirements if needed
pip install -r requirements.txt

# Run Flask app with MATLAB integration
python app.py