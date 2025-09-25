function models = loadModels(modelDir)
% models = loadModels(modelDir)
% Loads ocsvmModel and kmeansModel and meta

models = struct();
kdata = load(fullfile(modelDir,'kmeansModel.mat'));
kfields = fieldnames(kdata);
models.kmeans = kdata.(kfields{1});

oc = load(fullfile(modelDir,'ocsvmModel.mat'));
ocfields = fieldnames(oc);
models.ocsvm = oc.(ocfields{1});

meta = load(fullfile(modelDir,'pipeline_meta.mat'));
models.meta = meta.meta;
end
