clear all
clc

load moisture_protein.mat
A = r;
load oil_protein.mat
B = r;
load protein_protein.mat
C = r;
load starch_protein.mat
D = r;


figure
plot(A(:,1),'r-^','MarkerFaceColor','r')
hold on 
plot(B(:,1),'b-o','MarkerFaceColor','b')
hold on
plot(C(:,1),'g-s','MarkerFaceColor','g')
hold on
plot(D(:,1),'m-v','MarkerFaceColor','m')
hold on
plot(D(:,2),'k-d','MarkerFaceColor','k')

legend('Moisture','Oil','Protein','Starch','Without calibration transfer')
set(gca,'xticklabel',20:5:60)
xlabel('Number of target domain samples')
ylabel('R^2')
title('Comparison of calibration transfer between different components & instruments','fontsize',10)
