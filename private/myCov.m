function covxy = myCov(x,varargin)

% myCov compute (auto-) covariance
%
% function covxy = myCov(x[,y])
%
% by defintion covxy == var(X) for X == Y 
% since the function is called by myCorrcoef, the
% covariance is computed as : 
% sum((x-mean(x)).*(y-mean(y)) ) / (nx -1)
% which is the definition for random variables. The
% general definition would be : mean((x-mx).*(y-my))
%
% The above definition is used to ensure that 
% myCorrcoef(X,X) == 1
%
% For computing covariance and correlation maxtrices
% see cov.m corrcoef.m (Statistics Package)
%
% replaces: cov.m
%
% requires: 
%
% see also: myStd.m myVar.m myCorrcoef.m autoCorr.m 

% $Log$

% check number of input arguments
error(nargchk(1,2,nargin))

% check number of out arguments
error(nargoutchk(0,1,nargout))

if isempty(varargin),
	covxy = myVar(x);
else
	y = varargin{1};
	nx = numel(x);
	ny = numel(y);
	mx = mean(x);
	my = mean(y);
	if nx ~= ny,
		error('The lengths of x and y must match.');
	end

	covxy = sum( (x-mx).*(y-my) ) / (nx -1);
	% general definition
	% covxy  = mean((x-mx).*(y-my));
end 

