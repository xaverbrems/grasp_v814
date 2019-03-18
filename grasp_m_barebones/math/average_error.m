function average = average_error(values)

%Values is a list e.g. [x1,errx1; x2,errx2 ....etc.]

l = size(values);
no_values = l(1);

%Average
average(1) = sum(values(:,1))/no_values;
%Average error, add errors in quadrature
average(2) = sqrt(sum(values(:,2).*values(:,2)))/no_values;


if size(values,2)==3
average(3) = sqrt(sum(values(:,3).*values(:,3)))/no_values;
end