function sigma_square = myVar(x)

% myVar compute the variance
% 
% function sigma_square = myVar(X)
%
% compute the (unweighted) variance of a random variable
% variance is defined as the squared sum of deviations 
% divided by the number of observations minus 1.
% For a weighted variance the squared sum of deviations
% has to be divided by the sum of X
%
% replaces: var.m
%
% requires:
%
% see also: myStd.m myCov.m myCorrCoef autoCorr.m

% $Log$


% check number of input arguments
error(nargchk(1,1,nargin))

% check number of out arguments
error(nargoutchk(0,1,nargout))

sigma_square = sum((x - mean(x)) .^2) / (length(x) -1);
