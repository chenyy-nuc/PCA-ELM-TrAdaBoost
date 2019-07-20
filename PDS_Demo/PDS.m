function Y_new = PDS(Y)

%% Load Transformation Matrix
load TransformationMatrix.mat

%% PDS Calibration transfer
k = 30;
N = size(Y,1);
for i = 1:700-2*k
    Y_new(:,i) = [ones(N,1) Y(:,i:i+2*k)] * b(i,:)';
end