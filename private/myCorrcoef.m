function r = myCorrcoef(x,varargin)

% myCorrcoef compute the (auto-) correlation coefficient of two variables and return it in r.
%
% function r = myCorrcoef(x,y)
%
% Compute the (auto-) correlation coefficient of two variables.
%
% The correlation coefficient of X and Y equals:
% cov(X,Y) / sqrt(cov(x,x)*cov(y,y))
% since cov(x,x) == var(x) & cov(y,y) == var(y) 
% r = sqrt(cov(x,x)*cov(y,y)) == std(X)*std(Y)
%
% replaces: corrcoef.m
%
% requires:
%
% see also: myStd.m myCov.m autoCorr.m

% $Log$

% check number of input arguments
error(nargchk(1,2,nargin))

% check number of out arguments
error(nargoutchk(0,1,nargout))

if ~isempty(varargin),
	y = varargin{1};
else
	y = x;
end

nx = numel(x);
ny = numel(y);

if nx ~= ny, error('The lengths of x and y must match.');end

r = myCov(x,y) / ( myStd(x)*myStd(y) );

