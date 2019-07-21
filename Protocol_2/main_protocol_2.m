%% 清空环境变量
clear all
clc
warning off

%% 导入数据
load corn.mat
% k = randperm(80);
k = 1:80;
r1 = [];
r2 = [];
for n = 5:1:10
    m1 = n;
    m2 = 60;
    m3 = 10;
    % 目标领域训练样本
    P_train_target = mp5spec.data(k(1:m2),1:2:end);
    T_train_target = propvals.data(k(1:m2),2);  % oil component
    m2 = size(T_train_target,1);
    % 目标领域测试样本
    P_test_target = mp5spec.data(k(m2+1:m2+m3),1:2:end);
    T_test_target = propvals.data(k(m2+1:m2+m3),2);
    m3 = size(T_test_target,1);
    % 源领域训练样本（辅助训练样本）
    P_train_source = m5spec.data(k(m2+m3+1:m2+m3+m1),1:2:end);
    T_train_source = propvals.data(k(m2+m3+1:m2+m3+m1),2);
    m1 = size(T_train_source,1);
    X = [P_train_source;P_train_target;P_test_target];
    [~,PCAScores,latent,~] = pca(X);
    
    % figure
    % plot(PCAScores(1:m1,1),PCAScores(1:m1,2),'r+')
    % hold on
    % plot(PCAScores(m1+1:m1+m2,1),PCAScores(m1+1:m1+m2,2),'bo')
    % hold on
    % plot(PCAScores(m1+m2+1:end,1),PCAScores(m1+m2+1:end,2),'ks')
    %
    % xlabel('第一主成分')
    % ylabel('第二主成分')
    % title('源组分和目标组分数据集主成分分析结果')
    % legend('源组分训练集','目标组分训练集','目标组分测试集','location','best')
    
    %% TrAdaboost-PCA
    max_iteration = 100;
    % 初始化权重
    weights_source = ones(m1,1) / m1;
    weights_target = ones(m2,1) / m2;
    weights = [weights_source; weights_target];
    beta = 1 / (1 + sqrt(2*log(m1/max_iteration)));
    Beta = zeros(max_iteration,1);
    IW = cell(max_iteration,1);
    B = cell(max_iteration,1);
    LW = cell(max_iteration,1);
    W = cell(max_iteration,1);
    Y_Predict = zeros(max_iteration, 10);
    for i = 1:max_iteration
        p = weights / sum(weights);
        W{i} = p;
        % 建立PCA-weighted-ELM模型
        P = PCAScores(1:m1+m2,1:5);    % 选取前5个主成分d45
        T_sim = [T_train_source;T_train_target];
        [IW{i},B{i},LW{i},TF,TYPE] = elmtrain(P',T_sim',20,'sig',0,diag(p));
        Y = elmpredict(PCAScores(1:m1+m2,1:5)',IW{i},B{i},LW{i},TF,TYPE);
%         Y_Predict(i,:) = elmpredict(PCAScores(m1+m2+1:end,1:10)',IW{i},B{i},LW{i},TF,TYPE);
        error = [(Y(1:m1)'-T_sim(1:m1)).^2 / max(abs(Y(1:m1)'-T_sim(1:m1)));...
            (Y(m1+1:m1+m2)'-T_sim(m1+1:m1+m2)).^2 / max(abs(Y(m1+1:m1+m2)'-T_sim(m1+1:m1+m2)))];
        epsilon = sum(error .* p);
        if epsilon >= 0.5
            epsilon = 0.5;
        end
        
        beta = epsilon / (1-epsilon);
        for j = 1:m1+m2
            if j <= m1
                weights(j) = weights(j) * beta^error(j);
            else
                weights(j) = weights(j) * beta^(-1*error(j));
            end
        end
        Beta(i) = beta;
    end
    
    %% 预测
    t_sim = zeros(1,10);
    beta_new = Beta / sum(Beta);
    E = zeros(1,max_iteration);
    
    for i = 1:max_iteration
        temp = elmpredict(PCAScores(m1+m2+1:end,1:5)',IW{i},B{i},LW{i},TF,TYPE);
        E(i) = mse(temp' - T_test_target);
        t_sim = t_sim + beta_new(i) .* temp;
    end
    %% 结果分析
    Result = [t_sim' T_test_target];
    relativeError = abs(t_sim' - T_test_target) ./ T_test_target
    
    %% 对比
    p = 1/m2 * ones(m2,1);
    [iw,b,lw,TF,TYPE] = elmtrain(PCAScores(m1+1:m1+m2,1:5)',T_train_target',20,'sig',0,diag(p));
    t = elmpredict(PCAScores(m1+m2+1:end,1:5)',iw,b,lw,TF,TYPE);
    
    % figure
    % plot(1:m3,T_test_target,'r-*')
    % hold on
    % plot(1:m3,t_sim,'b:o')
    % hold on
    % plot(1:m3,t,'k-.s')
    % legend('真实值','预测值-移植','预测值-未移植')
    % xlabel('目标组分测试集样本编号')
    % ylabel('玉米油含量')
    % title('目标组分测试集预测结果')
    
    
    R2_transfer = (m3 * sum(t_sim' .* T_test_target) - sum(t_sim') * sum(T_test_target))^2 / ((m3 * sum((t_sim').^2) - (sum(t_sim'))^2) * (m3 * sum((T_test_target).^2) - (sum(T_test_target))^2))
%     R2_no_transfer = (m3 * sum(t' .* T_test_target) - sum(t') * sum(T_test_target))^2 / ((m3 * sum((t').^2) - (sum(t'))^2) * (m3 * sum((T_test_target).^2) - (sum(T_test_target))^2))
    r1 = [r1 R2_transfer];
%     r2 = [r2 R2_no_transfer];
end
figure
% subplot(2,1,1)
plot(5:1:10,r1,'r-*')
hold on
plot(5:1:10,r2,'b:s')
legend('transfer','no transfer')
% figure
% plot(T_test_target, T_test_target,'r')
% hold on
% plot(T_test_target,t_sim,'b^')
% hold on
% plot(T_test_target,t,'ks')


% [mse(t_sim-T_test_target) mse(t-T_test_target) R2_transfer R2_no_transfer]

% figure
% plot(E)
% 
% A = reshape(cell2mat(W),80,max_iteration);
% figure
% subplot(2,1,1)
% plot(1:max_iteration,A(1:60,:)')
% subplot(2,1,2)
% plot(1:max_iteration,A(61:end,:)')
% 
% % h = plotyy(1:max_iteration,A(1:60,:)',1:max_iteration,A(61:end,:)')
% xlim([1 100])
% xlabel('迭代次数')
% % ylabel(h(1),'源组分数据集样品权重')
% % ylabel(h(2),'目标组分数据集样品权重')
% title('源组分与目标组分数据集样品权重变化趋势')
% 
% Error_Predict = Y_Predict - repmat(T_test_target',100,1);