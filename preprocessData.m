function [X_tab, meta] = preprocessData(T)
% [X_tab, meta] = preprocessData(T)
% Input: table T with numeric sensor/weather columns and timestamp column
% Output: X_tab numeric matrix (rows = samples), meta struct with col names and encoders

% Identify numeric columns (exclude image_filename and non-numeric)
exclude = {'image_filename','image','label'};
varNames = T.Properties.VariableNames;
numericCols = varfun(@isnumeric,T,'OutputFormat','uniform');
numericNames = varNames(numericCols);

% Remove any excluded names
numericNames = setdiff(numericNames, exclude);

if isempty(numericNames)
    error('No numeric sensor/weather columns detected in CSV.');
end

% Convert to matrix
X = table2array(T(:,numericNames));

% 1) Handle missing values: prefer interpolation then median fill
% linear interpolation along rows (for time series-like data)
try
    X = fillmissing(X,'linear',1);
catch
    % fallback
    X = fillmissing(X,'movmedian',5);
end
% Still NaNs? fill with column median
nanIdx = any(isnan(X),1);
if any(nanIdx)
    colMed = nanmedian(X,1);
    for i = 1:size(X,2)
        X(isnan(X(:,i)),i) = colMed(i);
    end
end

% 2) Denoise / smoothing (use robust smoothing)
X = smoothdata(X,'gaussian',5);

% 3) Feature engineering: convert timestamp if present
meta = struct();
if ismember('timestamp',lower(varNames))
    % attempt to parse timestamp column
    timeCol = [];
    for i=1:numel(varNames)
        if strcmpi(varNames{i},'timestamp')
            timeCol = T.(varNames{i});
            break;
        end
    end
    try
        dt = datetime(timeCol);
        % extract hour of day, day of week, month
        hours = hour(dt);
        dow = weekday(dt);
        months = month(dt);
        X = [X, hours, dow, months];
        meta.timeAdded = true;
    catch
        meta.timeAdded = false;
    end
else
    meta.timeAdded = false;
end

% 4) Normalize (z-score)
mu = mean(X,1);
sigma = std(X,[],1);
sigma(sigma==0)=1;
Xnorm = (X - mu) ./ sigma;

% return
X_tab = Xnorm;
meta.numericNames = numericNames;
meta.mu = mu;
meta.sigma = sigma;
end
