%% ��ջ�������
clear all
clc
warning off

%% ��������
load corn.mat
% k = randperm(80);
% k = 1:80;
r = [];
for m2 = 20:5:20
    R2_transfer = 0;
    R2_no_transfer = 0;
    for n = 1:100
        k = randperm(80);
    m1 = 50;
    m3 = 10;
    % Ŀ������ѵ������
    P_train_target = mp5spec.data(k(1:m2),1:2:end);
    T_train_target = propvals.data(k(1:m2),3);  % protein component
    m2 = size(T_train_target,1);
    % Ŀ�������������
    P_test_target = mp5spec.data(k(m2+1:m2+m3),1:2:end);
    T_test_target = propvals.data(k(m2+1:m2+m3),3);
    m3 = size(T_test_target,1);
    % Դ����ѵ������������ѵ��������
    P_train_source = m5spec.data(k(m2+m3+1:m2+m3+m1),1:2:end);
    T_train_source = propvals.data(k(m2+m3+1:m2+m3+m1),3);
    m1 = size(T_train_source,1);
    X = [P_train_source;P_train_target;P_test_target];
    [~,PCAScores,~] = pca(X);
    
    % figure
    % plot(PCAScores(1:m1,1),PCAScores(1:m1,2),'r+')
    % hold on
    % plot(PCAScores(m1+1:m1+m2,1),PCAScores(m1+1:m1+m2,2),'bo')
    % hold on
    % plot(PCAScores(m1+m2+1:end,1),PCAScores(m1+m2+1:end,2),'ks')
    %
    % xlabel('��һ���ɷ�')
    % ylabel('�ڶ����ɷ�')
    % title('Դ��ֺ�Ŀ��������ݼ����ɷַ������')
    % legend('Դ���ѵ����','Ŀ�����ѵ����','Ŀ����ֲ��Լ�','location','best')
    
    %% TrAdaboost-PCA
    max_iteration = 100;
    % ��ʼ��Ȩ��
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
        % ����PCA-weighted-ELMģ��
        P = PCAScores(1:m1+m2,1:10);    % ѡȡǰ5�����ɷ�
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
    
    %% Ԥ��
    t_sim = zeros(1,10);
%     beta_new = Beta / sum(Beta);
beta_new = Beta(51:100) / sum(Beta(51:100));
    E = zeros(1,max_iteration);
    
    for i = 1:max_iteration*0.5
        temp = elmpredict(PCAScores(m1+m2+1:end,1:10)',IW{i},B{i},LW{i},TF,TYPE);
        E(i) = mse(temp' - T_test_target);
        t_sim = t_sim + beta_new(i) .* temp;
    end
    %% �������
    Result = [t_sim' T_test_target];
    relativeError = abs(t_sim' - T_test_target) ./ T_test_target
    
    %% �Ա�
    p = 1/m2 * ones(m2,1);
    [iw,b,lw,TF,TYPE] = elmtrain(PCAScores(m1+1:m1+m2,1:10)',T_train_target',20,'sig',0,diag(p));
    t = elmpredict(PCAScores(m1+m2+1:end,1:10)',iw,b,lw,TF,TYPE);
    
    % figure
    % plot(1:m3,T_test_target,'r-*')
    % hold on
    % plot(1:m3,t_sim,'b:o')
    % hold on
    % plot(1:m3,t,'k-.s')
    % legend('��ʵֵ','Ԥ��ֵ-��ֲ','Ԥ��ֵ-δ��ֲ')
    % xlabel('Ŀ����ֲ��Լ��������')
    % ylabel('�����ͺ���')
    % title('Ŀ����ֲ��Լ�Ԥ����')
    
    
    R2_transfer = R2_transfer + (m3 * sum(t_sim' .* T_test_target) - sum(t_sim') * sum(T_test_target))^2 / ((m3 * sum((t_sim').^2) - (sum(t_sim'))^2) * (m3 * sum((T_test_target).^2) - (sum(T_test_target))^2))
    R2_no_transfer = R2_no_transfer + (m3 * sum(t' .* T_test_target) - sum(t') * sum(T_test_target))^2 / ((m3 * sum((t').^2) - (sum(t'))^2) * (m3 * sum((T_test_target).^2) - (sum(T_test_target))^2))
    
    end
    r = [r; R2_transfer/100 R2_no_transfer/100];
end

figure
plot(r(:,1),'r-^','MarkerFaceColor','r')
hold on 
plot(r(:,2),'b-o','MarkerFaceColor','b')
legend('With calibration transfer','Without calibration transfer')
set(gca,'xticklabel',20:5:60)
xlabel('Number of target domain samples')
ylabel('R^2')
title('Calibration transfer between different instruments')


A = reshape(cell2mat(W),m1+m2,max_iteration);
figure
subplot(2,1,1)
plot(1:max_iteration,A(1:m1,:)')
xlabel('Number of iterations')
title('Trend of weight of source domain samples')
subplot(2,1,2)
plot(1:max_iteration,A(m1+1:m1+m2,:)')
xlabel('Number of iterations')
title('Trend of weight of target domain samples')
