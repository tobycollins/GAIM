function Y = homoMult(M,X)
%homoMult - function to perform homogeneous multiplication of a set of
%points.
% Syntax: Y = homoMult(M,X)
%
% Inputs:
%    M - square multiplication matrix. Of size d*d, where d is the
%    dimensions of the points.
%    X - data to be multiplied. of size n*d, where n is the number of
%    points. Note that this is not defined in homogeneous coordinates.

% Outputs:
% Y - output of size n*d
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

dims = size(M,1)-1;
Y = M*[X';ones(1,size(X,1))];Y=Y';
Y(:,1:dims) = Y(:,1:dims)./repmat(Y(:,dims+1),1,dims);
Y = Y(:,1:dims);


    