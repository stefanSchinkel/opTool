function [entropy] = shannon2(X)

%shannon2 compute shannon entropy of a probability distribution
%
% function [entropy] = shannon2(X)
%
% Compute the Shannon entropy of a probability distribution
% For computation of normalised entropy or computation from
% time series see shannon.m 
%
% requires: 
% 
% see also: histX.m histXY.m shannon.m mutualInfo.m
%

% $Log: shannon2.m,v $
% Revision 1.3  2007/07/31 12:11:24  schinkel
% Properly adjusted for Doc for m2html
%
% Revision 1.2  2007/07/31 12:01:59  schinkel
% Adjusted for Doc for m2html
%
% Revision 1.1  2007/07/30 11:39:51  schinkel
% Initial Import
%


%% set debug
debug=false;
if debug;
	warning('on','all');
else 
	warning('off','all');
end

% check number of input arguments
error(nargchk(1,1,nargin))

% check number of out arguments
error(nargoutchk(0,1,nargout))

% not normalised entropy
entropy =  - sum(X.* log(X));

