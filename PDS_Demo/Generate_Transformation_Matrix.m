%% Initialization
clear all
clc
warning off

%% Import Data
load corn.mat

L = randperm(80);
% L = 1:80;
master_data = mp5spec.data(L(1:10),:);
slave_data = m5spec.data(L(1:10),:);

%% Calculate Transformation Matrix
k = 30;  % width = 2*k+1
b = [];
% 
for i = 1:700-2*k
    P_train = master_data(:,i:i+2*k);
    T_train = slave_data(:,i+k);
    [Xloadings,Yloadings,Xscores,Yscores,betaPLS,PLSPctVar,MSE,stats] = plsregress(P_train,T_train,5);
    b = [b;betaPLS'];
end

save TransformationMatrix.mat b L