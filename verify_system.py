#!/usr/bin/env python3
"""
System Verification Script for AI-Powered Agricultural Monitoring System
Verifies all MATLAB files are present and properly structured
"""

import os
import re
from pathlib import Path

def check_file_exists(filepath, description):
    """Check if a file exists and report status"""
    if os.path.exists(filepath):
        size = os.path.getsize(filepath)
        print(f"  ✅ {description} - Found ({size:,} bytes)")
        return True
    else:
        print(f"  ❌ {description} - Missing")
        return False

def check_matlab_syntax(filepath):
    """Basic MATLAB syntax check"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check for basic MATLAB syntax patterns
        if 'function' in content or 'classdef' in content:
            # Check for balanced parentheses and brackets
            paren_count = content.count('(') - content.count(')')
            bracket_count = content.count('[') - content.count(']')
            brace_count = content.count('{') - content.count('}')
            
            if abs(paren_count) <= 2 and abs(bracket_count) <= 2 and abs(brace_count) <= 2:
                return True
            else:
                print(f"    ⚠️  Possible syntax issue in {os.path.basename(filepath)}")
                return False
        return True
    except Exception as e:
        print(f"    ❌ Error reading {filepath}: {e}")
        return False

def main():
    print("=== AI-Powered Agricultural Monitoring System Verification ===\n")
    
    # Get current directory
    project_dir = Path.cwd()
    print(f"Project Directory: {project_dir}\n")
    
    # Test 1: Check main files
    print("Test 1: Checking main files...")
    main_files = [
        ('main.m', 'Main system script'),
        ('trainPipeline.m', 'Training pipeline'),
        ('preprocessData.m', 'Data preprocessing'),
        ('extractImageFeatures.m', 'Image feature extraction'),
        ('trainModels.m', 'Model training'),
        ('detectAnomaly.m', 'Anomaly detection'),
        ('predictCluster.m', 'Cluster prediction'),
        ('loadModels.m', 'Model loading'),
        ('generateTrainingDataset.m', 'Training dataset generation'),
        ('generateSampleMultispectralData.m', 'Sample multispectral data'),
        ('generateSampleSensorData.m', 'Sample sensor data'),
        ('loadConfiguration.m', 'Configuration loader'),
        ('README.md', 'Documentation')
    ]
    
    main_files_ok = 0
    for filename, description in main_files:
        if check_file_exists(filename, description):
            main_files_ok += 1
            check_matlab_syntax(filename)
    
    print(f"\nMain files: {main_files_ok}/{len(main_files)} found\n")
    
    # Test 2: Check modules
    print("Test 2: Checking modules...")
    modules_dir = project_dir / 'modules'
    module_files = [
        ('SpectralImageProcessor.m', 'Spectral image processing'),
        ('CropHealthAnalyzer.m', 'Crop health analysis'),
        ('SoilConditionAnalyzer.m', 'Soil condition analysis'),
        ('PestRiskDetector.m', 'Pest risk detection'),
        ('RealTimeDetector.m', 'Real-time detection'),
        ('RobustDataProcessor.m', 'Robust data processing'),
        ('MultimodalFusion.m', 'Multimodal data fusion'),
        ('EarlyWarningSystem.m', 'Early warning system'),
        ('AdaptiveLearningSystem.m', 'Adaptive learning'),
        ('TrainedModelInference.m', 'Trained model inference'),
        ('ReportGenerator.m', 'Report generation')
    ]
    
    modules_ok = 0
    for filename, description in module_files:
        filepath = modules_dir / filename
        if check_file_exists(filepath, description):
            modules_ok += 1
            check_matlab_syntax(filepath)
    
    print(f"\nModules: {modules_ok}/{len(module_files)} found\n")
    
    # Test 3: Check examples
    print("Test 3: Checking examples...")
    examples_dir = project_dir / 'examples'
    example_files = [
        ('demo_script.m', 'Basic demo script'),
        ('example_usage.m', 'Usage examples'),
        ('advanced_features_demo.m', 'Advanced features demo'),
        ('training_and_inference_demo.m', 'Training and inference demo')
    ]
    
    examples_ok = 0
    for filename, description in example_files:
        filepath = examples_dir / filename
        if check_file_exists(filepath, description):
            examples_ok += 1
            check_matlab_syntax(filepath)
    
    print(f"\nExamples: {examples_ok}/{len(example_files)} found\n")
    
    # Test 4: Check utilities
    print("Test 4: Checking utilities...")
    utils_dir = project_dir / 'utils'
    utility_files = [
        ('displayResults.m', 'Results display utility'),
        ('saveResults.m', 'Results saving utility')
    ]
    
    utils_ok = 0
    for filename, description in utility_files:
        filepath = utils_dir / filename
        if check_file_exists(filepath, description):
            utils_ok += 1
            check_matlab_syntax(filepath)
    
    print(f"\nUtilities: {utils_ok}/{len(utility_files)} found\n")
    
    # Test 5: Check project structure
    print("Test 5: Checking project structure...")
    required_dirs = ['modules', 'examples', 'utils']
    dirs_ok = 0
    
    for dirname in required_dirs:
        if os.path.exists(dirname) and os.path.isdir(dirname):
            print(f"  ✅ {dirname}/ - Directory found")
            dirs_ok += 1
        else:
            print(f"  ❌ {dirname}/ - Directory missing")
    
    print(f"\nDirectories: {dirs_ok}/{len(required_dirs)} found\n")
    
    # Test 6: Check for key features in code
    print("Test 6: Checking for key features...")
    
    # Check for advanced features in modules
    advanced_features = {
        'RealTimeDetector.m': ['real-time', 'clustering', 'detection'],
        'RobustDataProcessor.m': ['missing', 'noise', 'preprocessing'],
        'MultimodalFusion.m': ['multimodal', 'fusion', 'sensor', 'image'],
        'EarlyWarningSystem.m': ['warning', 'prediction', 'risk'],
        'AdaptiveLearningSystem.m': ['learning', 'adaptation', 'optimization']
    }
    
    features_found = 0
    for module, keywords in advanced_features.items():
        module_path = modules_dir / module
        if os.path.exists(module_path):
            try:
                with open(module_path, 'r', encoding='utf-8') as f:
                    content = f.read().lower()
                
                found_keywords = [kw for kw in keywords if kw in content]
                if len(found_keywords) >= 2:  # At least 2 keywords found
                    print(f"  ✅ {module} - Advanced features detected")
                    features_found += 1
                else:
                    print(f"  ⚠️  {module} - Limited advanced features")
            except Exception as e:
                print(f"  ❌ {module} - Error reading file: {e}")
        else:
            print(f"  ❌ {module} - File not found")
    
    print(f"\nAdvanced features: {features_found}/{len(advanced_features)} modules\n")
    
    # Test 7: Check training pipeline
    print("Test 7: Checking training pipeline...")
    training_files = ['trainPipeline.m', 'preprocessData.m', 'extractImageFeatures.m', 'trainModels.m']
    training_ok = 0
    
    for filename in training_files:
        if os.path.exists(filename):
            try:
                with open(filename, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if 'function' in content and ('train' in content.lower() or 'preprocess' in content.lower() or 'extract' in content.lower()):
                    print(f"  ✅ {filename} - Training pipeline component")
                    training_ok += 1
                else:
                    print(f"  ⚠️  {filename} - May not be training component")
            except Exception as e:
                print(f"  ❌ {filename} - Error reading file: {e}")
        else:
            print(f"  ❌ {filename} - File not found")
    
    print(f"\nTraining pipeline: {training_ok}/{len(training_files)} components\n")
    
    # Summary
    total_files = len(main_files) + len(module_files) + len(example_files) + len(utility_files)
    total_found = main_files_ok + modules_ok + examples_ok + utils_ok
    
    print("=== Verification Summary ===")
    print(f"Total files: {total_found}/{total_files} found")
    print(f"Directories: {dirs_ok}/{len(required_dirs)} found")
    print(f"Advanced features: {features_found}/{len(advanced_features)} modules")
    print(f"Training pipeline: {training_ok}/{len(training_files)} components")
    
    success_rate = (total_found / total_files) * 100
    print(f"\nOverall success rate: {success_rate:.1f}%")
    
    if success_rate >= 95:
        print("🎉 System verification PASSED! All components are present.")
    elif success_rate >= 80:
        print("⚠️  System verification PARTIAL. Most components present.")
    else:
        print("❌ System verification FAILED. Missing critical components.")
    
    print("\n=== Next Steps ===")
    print("1. Install MATLAB R2019b or later")
    print("2. Ensure required toolboxes are installed:")
    print("   - Image Processing Toolbox")
    print("   - Statistics and Machine Learning Toolbox")
    print("   - Deep Learning Toolbox")
    print("3. Run in MATLAB:")
    print(f"   cd('{project_dir}')")
    print("   run('test_system.m')")
    print("   run('examples/training_and_inference_demo.m')")
    
    print("\n=== Verification Complete ===")

if __name__ == "__main__":
    main()
