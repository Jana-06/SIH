
        try
            cd('d:/SIH/SIH/flask_server/..');
            fprintf('Starting custom analysis for: nhap_68d2cbfbd10e17e.csv\n');
            trainPipeline('d:/SIH/SIH/flask_server/uploads/nhap_68d2cbfbd10e17e.csv', '', 'user_models_m_f6d85a59_2301_42a6_8870_c29b61734a7c', 'TrainSupervised', false, 'K', 3);
            fprintf('Custom analysis complete. Models saved to user_models_m_f6d85a59_2301_42a6_8870_c29b61734a7c\n');
            
            load(fullfile('user_models_m_f6d85a59_2301_42a6_8870_c29b61734a7c', 'kmeans_model.mat'));
            load(fullfile('user_models_m_f6d85a59_2301_42a6_8870_c29b61734a7c', 'crop_health_model.mat'));
            load(fullfile('user_models_m_f6d85a59_2301_42a6_8870_c29b61734a7c', 'pest_risk_model.mat'));
            
            config = loadConfiguration();
            [sensorData, ~] = preprocessData('d:/SIH/SIH/flask_server/uploads/nhap_68d2cbfbd10e17e.csv', '', config);
            
            results = struct();
            results.crop_health = CropHealthAnalyzer(sensorData, kmeans_model, crop_health_model);
            results.soil_condition = SoilConditionAnalyzer(sensorData);
            results.pest_risk = PestRiskDetector(sensorData, pest_risk_model);
            
            ReportGenerator(results);
        catch ME
            fprintf('Error in MATLAB script: %s\n', ME.message);
            for i = 1:length(ME.stack)
                fprintf('File: %s, Name: %s, Line: %d\n', ME.stack(i).file, ME.stack(i).name, ME.stack(i).line);
            end
            exit(1);
        end
        exit(0);
        