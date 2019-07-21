clear all
clc

load octane_protein.mat
A = r;

path = 'D:\NUC\Chen_Yuanyuan\Papers\Calibration Transfer\Codes\';
load([path 'raw_r.mat'])
B = R;

figure
figure
plot(A(:,1),'r-^','MarkerFaceColor','r')
hold on 
plot(A(:,2),'b-o','MarkerFaceColor','b')
hold on 
plot(B,'k-s','MarkerFaceColor','k')

legend('With calibration transfer','Without calibration transfer(combine)','Without calibration transfer(separate)')
set(gca,'xticklabel',20:5:60)
xlabel('Number of target domain samples')
ylabel('R^2')
title('Comparison of calibration transfer between different objects')
