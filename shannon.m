function [entropy entropyNorm] = shannon(X,varargin)

%shannon compute shannon entropy of time series. 
%
% function [entropy entropyNorm] = shannon(X, [nBins])
%
% Compute the Shannon entropy and the normalised entropy of a
% time series provided as vector X based on the histogram of X.
% The number of bins used for the histogram may be provided,
% otherwise nBins defaults to 10.
%
% requires: histX.m
% 
% see also: histX.m histXY.m mutualInfo.m
%

% $Log: shannon.m,v $
% Revision 1.4  2007/07/31 12:11:24  schinkel
% Properly adjusted for Doc for m2html
%
% Revision 1.3  2007/07/31 12:01:59  schinkel
% Adjusted for Doc for m2html
%
% Revision 1.2  2007/07/30 09:49:25  schinkel
% Removed calculation from prob.Dist and added normalised ENT
%
% Revision 1.1  2007/07/24 09:13:05  schinkel
% Moved to opTool
%
% Revision 1.1  2007/07/20 14:06:15  schinkel
% Imported from helper
%
% Revision 1.2  2007/06/05 16:10:16  schinkel
% Added switch for distribution and time series.
%
% Revision 1.1  2007/06/05 15:19:02  schinkel
% Initial Import
%

%% set debug
debug=false;
if debug; warning('on','all');else warning('off','all');end

% check number of input arguments
error(nargchk(1,2,nargin))

% check number of out arguments
error(nargoutchk(0,2,nargout))

% if nBins not given use default == 10
if isempty(varargin), 
	nBins = 10;
else
	if ~isnumeric(varargin{1})
		nBins = 10;
		disp('Number of bins must be a number. Using default (10)');
	else
		nBins = varargin{1};
	end
end

% get the probablity distribution
pX = histX(X,nBins);

% not normalised entropy
entropy =  - sum(pX.* log(pX));
% normalised entropy
entropyNorm =  - sum(pX.* log(pX)) / log(length(X));

