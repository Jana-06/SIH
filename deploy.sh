#!/bin/bash

echo "🌾 Agricultural Monitoring Dashboard - Quick Deploy Setup"
echo "========================================================"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit - Agricultural Monitoring Dashboard"
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository found"
fi

# Add all files and commit
echo "Adding files to git..."
git add .
git status

echo ""
echo "🚀 Ready to deploy! Choose your deployment method:"
echo ""
echo "1. RENDER (Recommended - Free):"
echo "   - Push to GitHub: git push origin main"
echo "   - Go to render.com and connect your repo"
echo ""
echo "2. RAILWAY (Alternative - Free):"
echo "   - Push to GitHub: git push origin main" 
echo "   - Go to railway.app and deploy from GitHub"
echo ""
echo "3. HEROKU (Classic):"
echo "   - heroku create your-app-name"
echo "   - git push heroku main"
echo ""
echo "Your app will be accessible globally once deployed! 🌍"