function [delay] = estDelay(X,varargin)

%estDelay compute embedding delay.
%
% function [delay] = estDelay(X [,Y,nBins])
%
% The function computes the embedding delay of vector X (and Y)
% needed to compute an Order Patterns Recurrence Plot based on 
% (auto-) mutual information. The number of bins used for  the 
% histograms can be passed as nBins . 
%
% The lag is increased until an appropriate delay is found, or 
% the time series reached its end. 
%
% requires: mutualInformation.m localMin.m  
% 
% see also: shannon.m histX.m opcrp.m opcrqa.m
%

% $Log: estDelay.m,v $
% Revision 1.5  2007/08/10 08:38:20  schinkel
% Fixed bug if var(X) == 0
%
% Revision 1.4  2007/08/01 13:29:36  schinkel
% Fixed Bug (minima estimation)
%
% Revision 1.3  2007/07/31 12:11:23  schinkel
% Properly adjusted for Doc for m2html
%
% Revision 1.2  2007/07/31 12:01:58  schinkel
% Adjusted for Doc for m2html
%
% Revision 1.1  2007/07/31 08:33:59  schinkel
% Initial import
%

%% set debug

debug=true;
if debug;warning('on','all');else warning('off','all');end

% check number of input arguments
error(nargchk(1,3,nargin))

% check number of out arguments
error(nargoutchk(0,1,nargout))

%% prevent indexation errors
varargin{4} = [];

if  ~isempty(varargin{1}) && length(varargin) > 1, 
	Y = varargin{1};
	if ~isempty(varargin{2}), nBins = varargin{2};else nBins = 10;end
else
	Y = X;
	if ~isempty(varargin{2}), nBins = varargin{2};else nBins = 10;end
end

%% stat at lag 20 and increase until local minima is found. 
lag = 20;
while true

	mi = mutualInfo(X,Y,lag,nBins);
	minima = localMin(mi);
	if ~isempty(minima)
		delay =  minima(1); break;
	else
		lag = lag + lag;
		if lag >= length(X) || lag >=length(Y);

			error('Cannot find minima in MI. Using default (10).Check Data!');
			lag = 1;
		end
	end
end
