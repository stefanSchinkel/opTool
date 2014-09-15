function varargout = crossCorr(varargin)

% crossCorr compute the crosscorrelation function
%
% function autoCorr(X,Y[,delay])
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


% $Log: crossCorr.m,v $
% Revision 1.1  2007/08/01 13:06:36  schinkel
% Initial Import
%

%% set debug

debug=true;
if debug;warning('on','all');else warning('off','all');end

%% check number of input arguments
error(nargchk(2,3,nargin))

%% check number of out arguments
error(nargoutchk(0,1,nargout))

%% check && assign input
varargin{4} = [];
if ~isvector(varargin{1}),error('X has to be a vector');else 	xVec = varargin{1};	end
if ~isvector(varargin{2}),error('Y has to be a vector');else 	yVec = varargin{1};	end
if length(xVec) ~= length(yVec),error('X and Y have to be of the same length');end
if ~isempty(varargin{3}),maxDelay = varargin{3};
	if length(xVec) < maxDelay,
		error('Sorry not gonna work. Delay longer than ts.');
	end
else 
	maxDelay = length(xVec) - 2;
end	

%% allocate memory
cFW = zeros(1,maxDelay); % shift xVec forward in time
cBW = zeros(1,maxDelay); % shift xVec backward in time

for i = 1 : maxDelay
	cFW(i) = myCorrcoef(xVec(1+i : end),yVec(1 : end - i));
	cBW(i) = myCorrcoef(xVec(1 : end - i),yVec(1+i : end));
end

cross = [cBW(end:-1:1) myCorrcoef(xVec,yVec) cFW ];

if nargout 
	varargout{1} = cross;
else
	figure;	plot(-maxDelay:maxDelay,cross,'k')
	xlabel('Delay'), ylabel('Correlation Coefficient');
	title('Crosscorrelation function','FontWeight','bold');
	grid on
end

