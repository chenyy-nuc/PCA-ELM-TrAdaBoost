%% Initialization
clear all
clc
warning off

%% Import Data
load corn.mat
load TransformationMatrix.mat
% Split master and slave datasets
master_data = m5spec.data(L(1:10),31:670);
slave_data = mp5spec.data(L(11:end),:);

%% Establish ELM model using master dataset
P_train = master_data;
T_train = propvals.data(L(1:10),1);
[T_train, ps_output] = mapminmax(T_train',0,1);

[IW,B,LW,TF,TYPE] = elmtrain(P_train',T_train,100,'sig',0);

%% Predict slave dataset directly without PDS
P_test_1 = slave_data(:,31:670);
T_test = propvals.data(L(11:end),1);
T_test = T_test';
t_sim_1 = elmpredict(P_test_1',IW,B,LW,TF,TYPE);
T_sim_1 = mapminmax('reverse',t_sim_1,ps_output);

%% Predict slave dataset after PDS
P_test_2 = slave_data;
P_test_new = PDS(P_test_2);
t_sim_2 = elmpredict(P_test_new',IW,B,LW,TF,TYPE);
T_sim_2 = mapminmax('reverse',t_sim_2,ps_output);

figure
plot(T_test,'r-*')
hold on
plot(T_sim_1,'b-o')
hold on
plot(T_sim_2,'k:s')

Error_1 = mse(T_test - T_sim_1);
Error_2 = mse(T_test - T_sim_2);

N = length(T_test);

R2_1 = (N * sum(T_sim_1 .* T_test) - sum(T_sim_1) * sum(T_test))^2 / ((N * sum((T_sim_1).^2) - (sum(T_sim_1))^2) * (N * sum((T_test).^2) - (sum(T_test))^2));
R2_2 = (N * sum(T_sim_2 .* T_test) - sum(T_sim_2) * sum(T_test))^2 / ((N * sum((T_sim_2).^2) - (sum(T_sim_2))^2) * (N * sum((T_test).^2) - (sum(T_test))^2));

result = [T_test' T_sim_1' T_sim_2']
E = [Error_1 Error_2 R2_1 R2_2]
