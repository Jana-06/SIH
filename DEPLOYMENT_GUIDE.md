# 🌾 Agricultural Monitoring Dashboard - Deployment Guide

Your Flask application is now ready for deployment! Here are three easy ways to get a global URL:

## 🚀 Quick Deploy Options

### Option 1: Render (Recommended - FREE)

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Prepare for deployment"
   git push origin main
   ```

2. **Deploy on Render:**
   - Go to [render.com](https://render.com)
   - Sign up/login with GitHub
   - Click "New" → "Web Service"
   - Connect your GitHub repository
   - Render will auto-detect the `render.yaml` configuration
   - Click "Create Web Service"
   - Your app will be live at: `https://your-app-name.onrender.com`

### Option 2: Railway (Alternative - FREE)

1. **Push to GitHub (if not done already)**

2. **Deploy on Railway:**
   - Go to [railway.app](https://railway.app)
   - Sign up with GitHub
   - Click "New Project" → "Deploy from GitHub repo"
   - Select your repository
   - Railway will auto-detect settings from `railway.json`
   - Your app will be live at: `https://your-app-name.up.railway.app`

### Option 3: Heroku (Classic)

1. **Install Heroku CLI** and login:
   ```bash
   heroku login
   ```

2. **Create Heroku app:**
   ```bash
   heroku create your-app-name
   ```

3. **Deploy:**
   ```bash
   git push heroku main
   ```
   - Your app will be live at: `https://your-app-name.herokuapp.com`

## 🛠️ Local Testing

Before deploying, test locally:

```bash
# Install dependencies
pip install -r requirements.txt

# Run locally
python app.py
```

Visit: `http://localhost:5001`

## 🌐 What You'll Get

- **Main Dashboard**: Full research/analyst view at `/`
- **Farmer Dashboard**: Simplified view at `/farmer`
- **Global URL**: Accessible from anywhere in the world
- **Demo Mode**: Works without MATLAB (uses simulated data)

## 📊 Features

- **Crop Health Analysis** with color-coded maps
- **Soil Condition Monitoring**
- **Pest Risk Detection**
- **Multi-spectral Vegetation Indices** (NDVI, GNDVI, NDRE, EVI, SAVI)
- **Interactive Visualizations**
- **Responsive Design** for mobile/desktop

## 🔧 Environment Variables

Your app runs in **DEMO_MODE=1** by default, which generates realistic sample data without requiring MATLAB.

## 📝 Next Steps

1. Choose your preferred deployment platform
2. Push your code to GitHub
3. Follow the deployment steps above
4. Share your global URL!

## 🆘 Need Help?

If you encounter any issues:
1. Check the deployment logs on your chosen platform
2. Ensure all files are committed to your repository
3. Verify the requirements.txt includes all dependencies

Your agricultural monitoring dashboard will be accessible worldwide once deployed! 🌍