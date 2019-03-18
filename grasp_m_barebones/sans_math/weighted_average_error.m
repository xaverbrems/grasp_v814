function average = weighted_average_error(values, weight)

%Values is a list e.g. [x1,errx1; x2,errx2 ....etc.]

l = size(values);
normweight=sum(weight);

%Average
average(1) = sum(weight.*values(:,1))/normweight;
%Average error, add errors in quadrature
average(2) = sqrt(sum(weight.*values(:,2).^2))/normweight;
