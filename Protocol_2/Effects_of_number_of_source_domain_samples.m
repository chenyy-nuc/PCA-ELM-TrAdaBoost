clear all
clc

load R_10.mat
A = r2; % 5:5:60

load R_20.mat
B = r2; % 5:5:50

load R_30.mat
C = r2; % 5:5:40

load R_40.mat
D = r2; % 5:1:30

load R_50.mat
E = r2; % 5:1:20

load R_60.mat
F = r2; % 5:1:10

figure
subplot(3,2,1)
plot(5:5:60,A,'r-d','MarkerFaceColor','b')
xlim([5 60])
ylim([0 1])
set(gca,'xtick',5:10:60)
set(gca,'xticklabel',5:10:60)
ylabel('R^2')
title('N = 10','fontweight','normal','fontsize',10)

subplot(3,2,2)
plot(5:5:50,B,'r-d','MarkerFaceColor','b')
xlim([5 50])
ylim([0 1])
set(gca,'xtick',5:10:50)
set(gca,'xticklabel',5:10:50)
ylabel('R^2')
title('N = 20','fontweight','normal','fontsize',10)

subplot(3,2,3)
plot(5:5:40,C,'r-d','MarkerFaceColor','b')
xlim([5 40])
ylim([0 1])
set(gca,'xtick',5:10:40)
set(gca,'xticklabel',5:10:40)
ylabel('R^2')
title('N = 30','fontweight','normal','fontsize',10)

subplot(3,2,4)
plot(5:5:30,D(1:5:26),'r-d','MarkerFaceColor','b')
xlim([5 30])
ylim([0 1])
set(gca,'xtick',5:5:30)
set(gca,'xticklabel',5:5:30)
ylabel('R^2')
title('N = 40','fontweight','normal','fontsize',10)

subplot(3,2,5)
plot(5:5:20,E(1:5:16),'r-d','MarkerFaceColor','b')
xlim([5 20])
ylim([0 1])
set(gca,'xtick',5:5:20)
set(gca,'xticklabel',5:5:20)
ylabel('R^2')
title('N = 50','fontweight','normal','fontsize',10)

subplot(3,2,6)
plot(5:10,F(1:6),'r-d','MarkerFaceColor','b')
xlim([5 10])
ylim([0 1])
set(gca,'xtick',5:10)
set(gca,'xticklabel',5:10)
ylabel('R^2')
title('N = 60','fontweight','normal','fontsize',10)

text(1.5,-0.4,'Number of source domain samples')
text(-1.2,4.4,'Effects of number of source domain samples on model performance','fontsize',10,'fontweight','bold')

% figure
% subplot(2,1,1)
% plot(A,'r-d','MarkerFaceColor','b')
% ylim([0.4 0.7])
% legend('N = 20')
% set(gca,'xticklabel',5:5:50)
% ylabel('R^2')
% title('Effects of number of source domain samples on model performance','fontsize',10)
% subplot(2,1,2)
% plot(B,'r-.o','MarkerFaceColor','b')
% xlim([1 16])
% legend('N = 50')
% set(gca,'xticklabel',5:5:20)
% xlabel('Number of source domain samples')
% ylabel('R^2')