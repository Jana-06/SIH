from flask import Flask, jsonify, render_template, request, send_from_directory
from flask_cors import CORS
import subprocess
import os
import re
import io
import random
from datetime import datetime

try:
    from PIL import Image
except Exception:
    Image = None  # Pillow optional; required for DEMO_MODE

app = Flask(__name__)
CORS(app)

RESULTS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'results')
os.makedirs(RESULTS_DIR, exist_ok=True)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/farmer')
def farmer_dashboard():
    """Simplified dashboard for farmers with essential KPIs and visuals."""
    return render_template('farmer.html')

@app.route('/run-matlab', methods=['POST'])
def run_matlab():
    try:
        # DEMO MODE: generate placeholder results without MATLAB
        if os.getenv('DEMO_MODE', '0') == '1':
            demo_output = generate_demo_results(RESULTS_DIR)
            image_files = [f for f in os.listdir(RESULTS_DIR) if f.endswith('.png')]
            image_urls = [f'/results/{f}' for f in image_files]
            return jsonify({'output': demo_output, 'images': image_urls, 'full_context': demo_output})

        # The main MATLAB script to be executed is 'main.m'
        # The script should be in the root directory of the project
        matlab_script_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
        
        # Use forward slashes for MATLAB compatibility
        matlab_script_path_for_cd = matlab_script_path.replace('\\', '/')

        # Construct the command to run the main script
        matlab_cmd = os.getenv('MATLAB_CMD', 'matlab')
        command = f"{matlab_cmd} -batch \"cd('{matlab_script_path_for_cd}'); main;\""
        
        # Execute the command
        process = subprocess.run(command, shell=True, capture_output=True, text=True, cwd=matlab_script_path)

        if process.returncode != 0:
            # If MATLAB fails, return the error details for debugging
            return jsonify({'error': 'MATLAB script execution failed.', 'details': process.stdout + process.stderr})

        output = process.stdout
        
        # Find all generated .png files in the results directory
        image_files = [f for f in os.listdir(RESULTS_DIR) if f.endswith('.png')]
        image_urls = [f'/results/{f}' for f in image_files]

        # Return the full output and image URLs
        return jsonify({'output': output, 'images': image_urls, 'full_context': output})

    except Exception as e:
        return jsonify({'error': str(e)})

@app.route('/results/<filename>')
def uploaded_file(filename):
    return send_from_directory(RESULTS_DIR, filename)

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    message = data.get('message')
    context = data.get('analysis_context', '')
    
    reply = get_ai_response(message, context)
    
    return jsonify({'reply': reply})

def get_ai_response(message, context):
    """
    A simple AI response generator that parses the analysis context.
    """
    message = message.lower()
    
    if not context:
        if "profit" in message:
            return "I can only calculate potential profit after an analysis has been run. Please run the analysis first."
        return "I don't have any analysis results to work with yet. Please click 'Run Analysis' first."

    # Basic keyword matching
    if "profit" in message:
        # Extract key metrics to estimate profit
        health_match = re.search(r"Overall Crop Health Status:\s*(\w+)", context, re.IGNORECASE)
        pest_match = re.search(r"Overall Pest Risk Level:\s*(\w+)", context, re.IGNORECASE)
        
        health_status = health_match.group(1).lower() if health_match else "unknown"
        pest_status = pest_match.group(1).lower() if pest_match else "unknown"

        base_profit = 1000  # Base profit in USD per unit area
        
        # Adjust profit based on health
        if health_status == "good":
            base_profit *= 1.2
        elif health_status == "moderate":
            base_profit *= 0.9
        elif health_status == "poor":
            base_profit *= 0.6
            
        # Adjust profit based on pest risk
        if pest_status == "low":
            base_profit *= 1.1
        elif pest_status == "medium":
            base_profit *= 0.8
        elif pest_status == "high":
            base_profit *= 0.5

        return f"Based on the analysis, the estimated potential profit is around ${int(base_profit)} per unit area. This is an estimate based on crop health and pest risk."

    if "crop health" in message:
        match = re.search(r"CROP HEALTH ANALYSIS\s*====================([\s\S]*?)SOIL CONDITION ANALYSIS", context)
        return match.group(1).strip() if match else "I couldn't find the Crop Health section in the analysis."

    if "soil" in message or "moisture" in message:
        match = re.search(r"SOIL CONDITION ANALYSIS\s*=======================([\s\S]*?)PEST RISK ANALYSIS", context)
        return match.group(1).strip() if match else "I couldn't find the Soil Condition section in the analysis."

    if "pest" in message:
        match = re.search(r"PEST RISK ANALYSIS\s*==================([\s\S]*?)RECOMMENDATIONS", context)
        return match.group(1).strip() if match else "I couldn't find the Pest Risk section in the analysis."

    if "recommendations" in message:
        match = re.search(r"RECOMMENDATIONS\s*===============([\s\S]*)", context)
        return match.group(1).strip() if match else "I couldn't find any recommendations in the analysis."

    return "I can answer questions about crop health, soil conditions, pest risk, and potential profit. What would you like to know?"

if __name__ == '__main__':
    port = int(os.getenv('PORT', '5001'))
    debug = os.getenv('FLASK_DEBUG', '0') == '1'
    app.run(debug=debug, host='0.0.0.0', port=port)


# ------------------------------
# Demo utilities (no MATLAB)
# ------------------------------
def generate_demo_results(results_dir: str) -> str:
    os.makedirs(results_dir, exist_ok=True)
    # Create simple synthetic maps if Pillow is available; otherwise just return text
    if Image is not None:
        # sizes
        w, h = 256, 256
        # Helpers
        def save_colormap(name, seed=0):
            rnd = random.Random(seed)
            # generate simple gradient with noise
            data = bytearray()
            for y in range(h):
                for x in range(w):
                    v = int(255 * (x / (w - 1)))
                    v = int(0.7*v + 0.3*rnd.randint(0, 255))
                    data.append(max(0, min(255, v)))
            img = Image.frombytes('L', (w, h), bytes(data))
            rgb = apply_jet_palette(img)
            rgb.save(os.path.join(results_dir, f'{name}.png'))

        def save_discrete_rgb(name):
            # 1=low(G), 2=med(Y), 3=high(R)
            img = Image.new('RGB', (w, h))
            for y in range(h):
                for x in range(w):
                    # Three vertical bands
                    if x < w//3:
                        color = (0, 200, 0)
                    elif x < 2*w//3:
                        color = (220, 220, 0)
                    else:
                        color = (220, 0, 0)
                    img.putpixel((x, y), color)
            img.save(os.path.join(results_dir, f'{name}.png'))

        # Save maps
        save_colormap('ndvi_map', seed=1)
        save_colormap('gndvi_map', seed=2)
        save_colormap('ndre_map', seed=3)
        save_colormap('savi_map', seed=4)
        save_colormap('evi_map', seed=5)
        save_colormap('soil_condition_map', seed=6)
        save_discrete_rgb('crop_health_map')
        save_discrete_rgb('pest_risk_map')
        save_colormap('pest_risk_score_map', seed=7)

    # Compose console-like output expected by the UI regex
    now = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')
    output = f"""
=== AGRICULTURAL MONITORING RESULTS ===

EXECUTIVE SUMMARY
================
Report ID: DEMO-{int(time_time_safe())}
Analysis Date: {now}
Overall Assessment: Good (Score: 0.82)
Risk Level: Medium

CROP HEALTH ANALYSIS
====================
Overall Health: Good (Score: 0.78)
Confidence: 0.85

Vegetation Indices:
  NDVI: 0.612 (Healthy)
  GNDVI: 0.488 (Healthy)
  NDRE: 0.212 (Moderate)
  SAVI: 0.365 (Moderate)
  EVI: 0.304 (Moderate)

Health Distribution:
  Healthy: 62.5%
  Stressed: 25.0%
  Unhealthy: 12.5%

SOIL CONDITION ANALYSIS
=======================
Overall Health: Good (Score: 0.81)

Soil Parameters:
  Moisture: 0.18 (Adequate)
  Temperature: 22.1°C (Optimal)
  pH: 6.7 (Optimal)
  EC: 1.35 dS/m (Normal)

PEST RISK ANALYSIS
==================
Overall Risk: Medium (Score: 0.46)
Confidence: 0.77

Specific Pest Risks:
  Aphids: 0.42 (Medium Risk)
  Whiteflies: 0.28 (Low Risk)
  Thrips: 0.31 (Medium Risk)
  Spider Mites: 0.22 (Low Risk)
  Caterpillars: 0.18 (Low Risk)

RECOMMENDATIONS
===============
Crop Health Recommendations:
• Maintain current irrigation; spot-check yellow areas.

Soil Condition Recommendations:
• If moisture < 0.2, apply 10–20 mm irrigation.

Pest Management Recommendations:
• Medium pest pressure; scout hotspots before spraying.

Integrated Recommendations:
• Prioritize scouting in medium/high-risk patches, then re-check indices in 3 days.

=== END OF RESULTS ===
"""
    return output


def apply_jet_palette(gray_img):
    # Simple jet-like palette mapping without numpy
    w, h = gray_img.size
    out = Image.new('RGB', (w, h))
    for y in range(h):
        for x in range(w):
            v = gray_img.getpixel((x, y)) / 255.0
            r, g, b = jet_rgb(v)
            out.putpixel((x, y), (int(r*255), int(g*255), int(b*255)))
    return out


def jet_rgb(v):
    # piecewise jet colormap 0..1
    if v < 0.25:
        r, g, b = 0.0, 4*v, 1.0
    elif v < 0.5:
        r, g, b = 0.0, 1.0, 1.0 - 4*(v-0.25)
    elif v < 0.75:
        r, g, b = 4*(v-0.5), 1.0, 0.0
    else:
        r, g, b = 1.0, 1.0 - 4*(v-0.75), 0.0
    r = max(0.0, min(1.0, r))
    g = max(0.0, min(1.0, g))
    b = max(0.0, min(1.0, b))
    return r, g, b


def time_time_safe():
    try:
        import time
        return time.time()
    except Exception:
        return 0
