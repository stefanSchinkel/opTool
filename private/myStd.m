function sigma = myStd(x)

% myStd compute the starndard deviation
%
% function sigma = myStd(X)
%
% compute the standard deviation (sigma) of a random variable
% the standard deviation is the square root of the variance.
%
% replaces: std.m 
%
% requires: 
%
% see also: myVar.m myCov.m myCorrCoef autoCorr.m 
%

% $Log$


% check number of input arguments
error(nargchk(1,1,nargin))

% check number of out arguments
error(nargoutchk(0,1,nargout))

sigma = sqrt( sum((x - mean(x)) .^2) / (length(x) -1));

