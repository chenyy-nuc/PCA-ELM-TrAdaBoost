%% 清空环境变量
clear all
clc
warning off

%% 导入数据
load corn.mat
% k = randperm(80);
% k = 1:80;
r = [];
for m2 = 20:5:60
    R2_transfer = 0;
    R2_no_transfer = 0;
    for n = 1:100
        k = randperm(80);
    m1 = 10;
    m3 = 10;
    % 目标领域训练样本
    P_train_target = mp5spec.data(k(1:m2),1:2:end);
    T_train_target = propvals.data(k(1:m2),3);  % protein component
    m2 = size(T_train_target,1);
    % 目标领域测试样本
    P_test_target = mp5spec.data(k(m2+1:m2+m3),1:2:end);
    T_test_target = propvals.data(k(m2+1:m2+m3),3);
    m3 = size(T_test_target,1);
    % 源领域训练样本（辅助训练样本）
    P_train_source = m5spec.data(k(m2+m3+1:m2+m3+m1),1:2:end);
    T_train_source = propvals.data(k(m2+m3+1:m2+m3+m1),1);
    T_train_source = mapminmax(T_train_source',7,10);
    T_train_source = T_train_source';
    m1 = size(T_train_source,1);
    X = [P_train_source;P_train_target;P_test_target];
    [~,PCAScores,~] = pca(X);
    
%     figure
%     plot(PCAScores(1:m1,1),PCAScores(1:m1,2),'ro','MarkerFaceColor','r')
%     hold on
%     plot(PCAScores(m1+1:end,1),PCAScores(m1+1:end,2),'bs','MarkerFaceColor','b')
%     %     hold on
%     %     plot(PCAScores(m1+m2+1:end,1),PCAScores(m1+m2+1:end,2),'ks','MarkerFaceColor','k')
%     
%     xlabel('The 1^s^t principal component')
%     ylabel('The 2^n^d principal component')
%     title('PCA results of source and target domains')
%     legend('Source domain','Target domain','location','best')
%     
    %% TrAdaboost-PCA
    max_iteration = 10;
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
%     Y_Predict = zeros(max_iteration, 10);
    for i = 1:max_iteration
        p = weights / sum(weights);
        W{i} = p;
        % 建立PCA-weighted-ELM模型
        P = PCAScores(1:m1+m2,1:10);    % 选取前5个主成分
        T_sim = [T_train_source;T_train_target];
        [IW{i},B{i},LW{i},TF,TYPE] = elmtrain(P',T_sim',20,'sig',0,diag(p));
        Y = elmpredict(PCAScores(1:m1+m2,1:10)',IW{i},B{i},LW{i},TF,TYPE);
        %         Y_Predict(i,:) = elmpredict(PCAScores(m1+m2+1:end,1:10)',IW{i},B{i},LW{i},TF,TYPE);
        error = [(Y(1:m1)'-T_sim(1:m1)).^2 / max(abs(Y(1:m1)'-T_sim(1:m1)));...
            (Y(m1+1:m1+m2)'-T_sim(m1+1:m1+m2)).^2 / max(abs(Y(m1+1:m1+m2)'-T_sim(m1+1:m1+m2)))];
        epsilon = sum(error(m1+1:m1+m2) .* p(m1+1:m1+m2));
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
%     beta_new = Beta / sum(Beta);
    beta_new = Beta(1/2*max_iteration+1:max_iteration) / sum(Beta(1/2*max_iteration+1:max_iteration));
    E = zeros(1,max_iteration);
    
    for i = 1:1/2*max_iteration
        temp = elmpredict(PCAScores(m1+m2+1:end,1:10)',IW{i},B{i},LW{i},TF,TYPE);
        E(i) = mse(temp' - T_test_target);
        t_sim = t_sim + beta_new(i) .* temp;
    end
    %% 结果分析
    Result = [t_sim' T_test_target];
    relativeError = abs(t_sim' - T_test_target) ./ T_test_target
    
    %% 对比
    p = 1/m2 * ones(m2,1);
    [iw,b,lw,TF,TYPE] = elmtrain(PCAScores(m1+1:m1+m2,1:10)',T_train_target',20,'sig',0,diag(p));
    t = elmpredict(PCAScores(m1+m2+1:end,1:10)',iw,b,lw,TF,TYPE);
    
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
    
    
    R2_transfer = R2_transfer + (m3 * sum(t_sim' .* T_test_target) - sum(t_sim') * sum(T_test_target))^2 / ((m3 * sum((t_sim').^2) - (sum(t_sim'))^2) * (m3 * sum((T_test_target).^2) - (sum(T_test_target))^2))
    R2_no_transfer = R2_no_transfer + (m3 * sum(t' .* T_test_target) - sum(t') * sum(T_test_target))^2 / ((m3 * sum((t').^2) - (sum(t'))^2) * (m3 * sum((T_test_target).^2) - (sum(T_test_target))^2))
    
    end
    r = [r; R2_transfer/100 R2_no_transfer/100];
end

r

figure
plot(r(:,1),'r-^','MarkerFaceColor','r')
hold on 
plot(r(:,2),'b-o','MarkerFaceColor','b')
legend('With calibration transfer','Without calibration transfer')
set(gca,'xticklabel',20:5:60)
xlabel('Number of target domain samples')
ylabel('R^2')
title('Comparison between with and without calibration transfer')


% A = reshape(cell2mat(W),m1+m2,max_iteration);
% figure
% subplot(2,1,1)
% plot(1:max_iteration,A(1:m1,:)')
% xlabel('Number of iterations')
% title('Trend of weight of source domain samples')
% xlim([1 50])
% set(gca,'xtick',[1 5:5:50])
% subplot(2,1,2)
% plot(1:max_iteration,A(m1+1:m1+m2,:)')
% xlabel('Number of iterations')
% xlim([1 50])
% title('Trend of weight of target domain samples')
% set(gca,'xtick',[1 5:5:50])