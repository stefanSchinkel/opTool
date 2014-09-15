function varargout = autoCorr(varargin)

% autoCorr compute the autocorrelation function
%
% function autoCorr(X[,delay])
%	
% The function computes the autocorrelation function (acf) 
% of a time series provided in X. The maxmimal delay can 
% be passed as a second argument. If none is given, the acf 
% is computed from X(-n+2) to X(n-2). If no output is specified,
% the acf is plotted. 
%
% requires: myCorrcoef.m
% 
% see also: crossCorr.m


% $Log: autoCorr.m,v $
% Revision 1.1  2007/08/01 13:06:37  schinkel
% Initial Import
%

%% set debug

debug=true;
if debug;warning('on','all');else warning('off','all');end

%% check number of input arguments
error(nargchk(1,2,nargin))

%% check number of out arguments
error(nargoutchk(0,1,nargout))

%% check && assign input
varargin{3} = [];
if ~isvector(varargin{1}),error('X has to be a vector');else 	xVec = varargin{1};	end
if ~isempty(varargin{2}),
	maxDelay = varargin{2};
	if length(xVec) < maxDelay,
		error('Sorry not gonna work. Delay longer than ts.');
	end
else 
	maxDelay = length(xVec) - 5;
end

%% preallocate memory
c = zeros(1,maxDelay);
for i = 1 : maxDelay
	c(i) = myCorrcoef(xVec(1 + i : end),xVec(1 : end - i));
end

auto = [c(end:-1:1) myCorrcoef(xVec) c ];

if nargout 
	varargout{1} = auto;
else
	figure;	plot(-maxDelay:maxDelay,auto,'k')
	xlabel('Delay'), ylabel('Correlation Coefficient');
	title('Autocorrelation function','FontWeight','bold');
	grid on
end

