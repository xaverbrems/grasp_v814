function [y] = circle_kernel_1d(x0,radius,intint,x,dx)

%Normalised Tophat function 
y = zeros(size(x)); %Empty Array
temp = find(x>=(x0-radius) & x<=(x0+radius));
y(temp) =  sqrt(radius.^2 - (x(temp)-x0).^2);
y = intint*y/(sum(y)*dx);


%figure
%plot(x,y,'.')
%sum(y.*dx)
% asdasdas