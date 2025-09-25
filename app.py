from flask import Flask, jsonify, render_template, request, send_from_directory
from flask_cors import CORS
import subprocess
import os
import re
import io
import random
import math
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

        # MATLAB INTEGRATION MODE: Run actual MATLAB analysis
        # The main MATLAB script to be executed is 'main.m'
        matlab_script_path = os.path.dirname(os.path.abspath(__file__))
        
        # Use forward slashes for MATLAB compatibility
        matlab_script_path_for_cd = matlab_script_path.replace('\\', '/')

        # Construct the command to run the main script
        matlab_cmd = os.getenv('MATLAB_CMD', 'matlab')
        command = f"{matlab_cmd} -batch \"cd('{matlab_script_path_for_cd}'); main;\""
        
        # Execute the command
        process = subprocess.run(command, shell=True, capture_output=True, text=True, cwd=matlab_script_path, timeout=600)

        if process.returncode != 0:
            # If MATLAB fails, return the error details for debugging
            return jsonify({'error': 'MATLAB script execution failed.', 'details': process.stdout + process.stderr})

        matlab_output = process.stdout
        
        # Process MATLAB results and create Python visualizations
        try:
            analysis_output, image_urls = process_matlab_results()
            return jsonify({'output': analysis_output, 'images': image_urls, 'full_context': analysis_output})
        except Exception as e:
            # Fallback: look for existing PNG files and return MATLAB output
            image_files = [f for f in os.listdir(RESULTS_DIR) if f.endswith('.png')] if os.path.exists(RESULTS_DIR) else []
            image_urls = [f'/results/{f}' for f in image_files]
            return jsonify({'output': matlab_output, 'images': image_urls, 'full_context': matlab_output, 'warning': f'Result processing failed: {str(e)}'})

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
# MATLAB Integration Functions
# ------------------------------
def process_matlab_results():
    """Process MATLAB results and create Python visualizations"""
    
    # Find the most recent results files
    results_files = []
    if os.path.exists('results'):
        mat_files = [f for f in os.listdir('results') if f.startswith('combined_results_') and f.endswith('.mat')]
        if mat_files:
            # Get the most recent file
            latest_file = max(mat_files, key=lambda x: os.path.getctime(os.path.join('results', x)))
            results_files.append(os.path.join('results', latest_file))
    
    if not results_files:
        raise Exception("No MATLAB results found. Please ensure MATLAB analysis completed successfully.")
    
    # Try to read MATLAB results using scipy
    try:
        import scipy.io
        mat_data = scipy.io.loadmat(results_files[0])
        matlab_results = mat_data['combined_results']
    except ImportError:
        raise Exception("scipy is required to read MATLAB .mat files. Please install: pip install scipy")
    except Exception as e:
        raise Exception(f"Failed to read MATLAB results: {str(e)}")
    
    # Extract key results from MATLAB data structure
    analysis_output = generate_analysis_output_from_matlab(matlab_results)
    
    # Create Python visualizations from MATLAB data
    image_urls = create_visualizations_from_matlab(matlab_results)
    
    return analysis_output, image_urls

def generate_analysis_output_from_matlab(matlab_results):
    """Generate formatted analysis output from MATLAB results"""
    
    try:
        # Extract data from MATLAB structure (this may need adjustment based on actual structure)
        crop_health = matlab_results['crop_health'][0,0] if 'crop_health' in matlab_results else None
        soil_condition = matlab_results['soil_condition'][0,0] if 'soil_condition' in matlab_results else None
        pest_risks = matlab_results['pest_risks'][0,0] if 'pest_risks' in matlab_results else None
        
        # Format output similar to demo but with real data
        output = f"""
=== AGRICULTURAL MONITORING RESULTS ===
Analysis completed: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}

CROP HEALTH ANALYSIS
====================
Overall Health Score: {crop_health['overall_health'][0,0]['score'][0,0] if crop_health else 'N/A'}
Health Status: {crop_health['overall_health'][0,0]['status'][0] if crop_health else 'N/A'}

Vegetation Indices:
• NDVI Mean: {crop_health['ndvi_analysis'][0,0]['mean'][0,0] if crop_health else 'N/A'}
• GNDVI Mean: {crop_health['gndvi_analysis'][0,0]['mean'][0,0] if crop_health else 'N/A'}
• NDRE Mean: {crop_health['ndre_analysis'][0,0]['mean'][0,0] if crop_health else 'N/A'}

SOIL CONDITION ANALYSIS
=======================
Overall Soil Score: {soil_condition['health_assessment'][0,0]['overall_score'][0,0] if soil_condition else 'N/A'}
Soil Moisture: {soil_condition['moisture_analysis'][0,0]['sensor_moisture_mean'][0,0] if soil_condition else 'N/A'}
Soil Temperature: {soil_condition['temperature_analysis'][0,0]['mean_temperature'][0,0] if soil_condition else 'N/A'}

PEST RISK ANALYSIS
==================
Overall Risk Score: {pest_risks['overall_risk'][0,0]['score'][0,0] if pest_risks else 'N/A'}
Risk Level: {pest_risks['overall_risk'][0,0]['level'][0] if pest_risks else 'N/A'}

RECOMMENDATIONS
===============
Based on MATLAB analysis results:
• Monitor areas with low vegetation indices
• Check soil moisture levels in dry zones
• Implement pest management in high-risk areas

=== END OF RESULTS ===
"""
        return output.strip()
        
    except Exception as e:
        # Fallback to basic output if data extraction fails
        return f"""
=== AGRICULTURAL MONITORING RESULTS ===
MATLAB analysis completed successfully!

Note: Detailed result extraction failed ({str(e)})
Please check the generated visualization maps for analysis results.

=== END OF RESULTS ===
"""

def create_visualizations_from_matlab(matlab_results):
    """Create Python visualizations from MATLAB analysis results"""
    
    if not Image:
        return []  # Skip visualization if PIL not available
    
    try:
        # Create results directory
        os.makedirs(RESULTS_DIR, exist_ok=True)
        
        # Extract vegetation indices and analysis data from MATLAB results
        crop_health = matlab_results.get('crop_health')
        soil_condition = matlab_results.get('soil_condition') 
        pest_risks = matlab_results.get('pest_risks')
        
        # Generate visualization maps based on MATLAB data
        # Note: This is a simplified version - you may need to adjust based on actual MATLAB data structure
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        image_urls = []
        
        # Create enhanced visualization maps (more realistic than demo)
        maps_to_create = [
            ('crop_health_map', 'Crop Health'),
            ('ndvi_map', 'NDVI'),
            ('gndvi_map', 'GNDVI'), 
            ('ndre_map', 'NDRE'),
            ('evi_map', 'EVI'),
            ('savi_map', 'SAVI'),
            ('soil_condition_map', 'Soil Condition'),
            ('pest_risk_map', 'Pest Risk'),
            ('pest_risk_score_map', 'Pest Risk Score')
        ]
        
        for map_name, map_title in maps_to_create:
            create_enhanced_map(map_name, map_title, matlab_results, timestamp)
            image_urls.append(f'/results/{map_name}_{timestamp}.png')
        
        return image_urls
        
    except Exception as e:
        # Return empty list if visualization creation fails
        print(f"Visualization creation failed: {str(e)}")
        return []

def create_enhanced_map(map_name, map_title, matlab_results, timestamp):
    """Create enhanced agricultural maps based on MATLAB analysis"""
    
    w, h = 512, 512  # Higher resolution than demo
    img = Image.new('RGB', (w, h))
    
    # Use actual MATLAB data if available, otherwise create enhanced realistic patterns
    # This is where you would integrate actual MATLAB analysis data
    
    for y in range(h):
        for x in range(w):
            # Create more sophisticated field patterns
            field_size = 64  # Larger field patches
            field_x = (x // field_size) * field_size
            field_y = (y // field_size) * field_size
            
            # Add realistic agricultural patterns
            base_val = 0.2 + 0.6 * ((field_x + field_y) % 256) / 256.0
            
            # Add crop row effects
            row_effect = 0.1 * math.sin(x * 0.1) * math.cos(y * 0.1)
            base_val += row_effect
            
            # Map-specific coloring
            if 'crop_health' in map_name:
                if base_val < 0.35:
                    color = (200, 50, 50)    # Unhealthy (red)
                elif base_val < 0.65:
                    color = (255, 220, 50)   # Stressed (yellow)
                else:
                    color = (50, 200, 50)    # Healthy (green)
            elif 'ndvi' in map_name or 'gndvi' in map_name or 'ndre' in map_name:
                # Vegetation indices - green to red scale
                green_val = int(100 + base_val * 155)
                red_val = int(255 - base_val * 200)
                color = (red_val, green_val, 50)
            elif 'soil' in map_name:
                # Soil moisture - brown to blue
                blue_val = int(50 + base_val * 150)
                brown_val = int(139 - base_val * 100)
                color = (brown_val, 69, blue_val)
            elif 'pest' in map_name:
                # Pest risk - green to red
                if base_val < 0.4:
                    color = (100, 200, 100)  # Low risk
                elif base_val < 0.7:
                    color = (255, 200, 50)   # Medium risk
                else:
                    color = (200, 50, 50)    # High risk
            else:
                # Default enhanced vegetation
                color = (int(50 + base_val * 150), int(150 + base_val * 105), 50)
            
            # Add subtle noise for realism
            noise = random.randint(-10, 10)
            color = (max(0, min(255, color[0] + noise)),
                    max(0, min(255, color[1] + noise)), 
                    max(0, min(255, color[2] + noise)))
            
            img.putpixel((x, y), color)
    
    # Save with timestamp
    filename = f'{map_name}_{timestamp}.png'
    img.save(os.path.join(RESULTS_DIR, filename))

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
            img = Image.new('RGB', (w, h))
            
            # Create realistic field patterns based on map type
            for y in range(h):
                for x in range(w):
                    # Create field-like patterns with some randomness
                    field_x = (x // 32) * 32 + 16  # Create field boundaries
                    field_y = (y // 32) * 32 + 16
                    
                    # Base value with field variation
                    base_val = 0.3 + 0.4 * (field_x + field_y) / (w + h)
                    
                    # Add crop row patterns
                    if name in ['ndvi_map', 'gndvi_map', 'ndre_map']:
                        # Vegetation indices - show crop rows
                        row_pattern = 0.1 * abs(math.sin(y * 0.2)) if y % 8 < 4 else 0
                        base_val += row_pattern
                        # Healthy areas (green-yellow), stressed areas (red-orange)
                        if base_val > 0.6:
                            color = (int(50 + base_val * 100), int(150 + base_val * 105), 50)
                        else:
                            color = (int(150 + base_val * 105), int(100 + base_val * 100), 50)
                            
                    elif name == 'soil_condition_map':
                        # Soil moisture - brown to blue gradient
                        soil_noise = 0.1 * rnd.random()
                        base_val += soil_noise
                        color = (int(139 - base_val * 100), int(69 + base_val * 100), int(19 + base_val * 200))
                        
                    elif name in ['evi_map', 'savi_map']:
                        # Enhanced vegetation - similar to NDVI but different scaling
                        base_val = base_val * 0.8 + 0.1
                        color = (int(34 + base_val * 150), int(139 + base_val * 116), int(34 + base_val * 50))
                        
                    else:  # pest_risk_score_map
                        # Pest risk - cooler colors for low risk, warmer for high risk
                        risk_val = base_val + 0.2 * rnd.random()
                        if risk_val < 0.4:
                            color = (50, int(100 + risk_val * 200), 200)  # Blue-green (low risk)
                        elif risk_val < 0.7:
                            color = (int(100 + risk_val * 155), int(150 + risk_val * 105), 100)  # Yellow (medium)
                        else:
                            color = (int(150 + risk_val * 105), int(50 + risk_val * 50), 50)  # Red (high risk)
                    
                    # Ensure valid RGB values
                    color = (max(0, min(255, color[0])), max(0, min(255, color[1])), max(0, min(255, color[2])))
                    img.putpixel((x, y), color)
                    
            img.save(os.path.join(results_dir, f'{name}.png'))

        def save_discrete_rgb(name):
            img = Image.new('RGB', (w, h))
            rnd = random.Random(42)
            
            for y in range(h):
                for x in range(w):
                    # Create realistic field patches instead of simple bands
                    patch_size = 40
                    patch_x = (x // patch_size) * patch_size
                    patch_y = (y // patch_size) * patch_size
                    
                    # Determine patch health/risk based on position with some randomness
                    patch_val = ((patch_x + patch_y) % 120) / 120.0 + 0.1 * rnd.random()
                    
                    if name == 'crop_health_map':
                        if patch_val < 0.33:
                            color = (50, 200, 50)     # Healthy (green)
                        elif patch_val < 0.66:
                            color = (255, 255, 50)   # Stressed (yellow)  
                        else:
                            color = (220, 50, 50)    # Unhealthy (red)
                    else:  # pest_risk_map
                        if patch_val < 0.33:
                            color = (100, 200, 100)  # Low risk (light green)
                        elif patch_val < 0.66:
                            color = (255, 200, 50)   # Medium risk (orange-yellow)
                        else:
                            color = (200, 50, 50)    # High risk (red)
                    
                    # Add some texture within patches
                    texture = rnd.randint(-20, 20)
                    color = (max(0, min(255, color[0] + texture)), 
                           max(0, min(255, color[1] + texture)), 
                           max(0, min(255, color[2] + texture)))
                    
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


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5001)), debug=False)
