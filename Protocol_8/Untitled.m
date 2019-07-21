load octane_moisture.mat 
A = r;
load octane_oil.mat
B = r;
load octane_protein.mat
C = r;
load octane_starch.mat
D = r;

figure
plot(A(:,1),'r-^','MarkerFaceColor','r')
hold on 
plot(B(:,1),'b-o','MarkerFaceColor','b')
hold on
plot(C(:,1),'g-s','MarkerFaceColor','g')
hold on
plot(D(:,1),'m-d','MarkerFaceColor','m')
legend('Moisture','Oil','Protein','Starch')
set(gca,'xticklabel',20:5:60)
xlabel('Number of target domain samples')
ylabel('R^2')
title('Comparison of calibration transfer between different objects')

