function [clusterIdx, distToCentroid] = predictCluster(sampleRow, modelDir)
% [clusterIdx, distToCentroid] = predictCluster(sampleRow, modelDir)
% sampleRow: 1xF normalized feature vector
% modelDir: folder containing kmeansModel.mat or equivalent
tmp = load(fullfile(modelDir,'kmeansModel.mat'));
fn = fieldnames(tmp);
kmeansModel = tmp.(fn{1});

C = kmeansModel.Centroids;
% assign to nearest centroid
dists = sqrt(sum((C - sampleRow).^2,2));
[distToCentroid, clusterIdx] = min(dists);
end
