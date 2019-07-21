A = [0.874 0.866 0.843 0.834 0.836 0.824 0.826 0.746 0.681 0.303;
     0.838 0.834 0.820 0.809 0.794 0.791 0.793 0.746 0.598 0.236;
     0.813 0.825 0.770 0.773 0.770 0.737 0.705 0.590 0.526 0.199;
     0.707 0.722 0.708 0.655 0.655 0.611 0.564 0.440 0.337 0.190;
     0.363 0.351 0.369 0.347 0.336 0.272 0.297 0.222 0.202 0.132;
     0.084 0.106 0.100 0.104 0.116 0.115 0.090 0.127 0.102 0.123];
 
 figure
 plot(A(1,end:-1:1),'r-^','MarkerFaceColor','r')
 hold on
 plot(A(2,end:-1:1),'b-o','MarkerFaceColor','b')
 hold on
 plot(A(3,end:-1:1),'g-s','MarkerFaceColor','g')
 hold on
 plot(A(4,end:-1:1),'m-d','MarkerFaceColor','m')
 hold on
 plot(A(5,end:-1:1),'c-v','MarkerFaceColor','c')
 hold on
 plot(A(6,end:-1:1),'k-h','MarkerFaceColor','k')
 legend('N = 60','N = 50','N = 40','N = 30','N = 20','N = 10')
 ylim([0 0.9])
%  xlim([0 10])
 set(gca,'xticklabel',5:5:50)
 xlabel('Value of maximum iterations (weak learners)')
 ylabel('R^2')
 title('Effects of value of maximum iterations on model performance')