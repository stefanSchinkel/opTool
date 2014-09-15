function [mi] = mutualInfo(X,varargin)

%mutualInfo Compute the (auto) mutual information 
%
% function [mi] = mutualInfo(X,[Y,lag,nBins])
%
% The function computes the (auto) mutual information of X or
% the mutual information of X and Y, if Y is given. 
% The lag and the number of bins can be passed as parameters in 
% lag and nBins . If no lag is given, no shifting takes places.
% If no number if bins in provided, nBins defaults to 10.
%
% requires: histX.m histXY.m shannon2.m
% 
% see also: histX.m histXY.m shannon.m
%

% Copyright (C) 2007 Stefan Schinkel, University of Potsdam
% http://www.agnld.uni-potsdam.de 
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


% $Log: mutualInfo.m,v $
% Revision 1.9  2007/08/23 13:42:06  schinkel
% Mlint cleaning
%
% Revision 1.8  2007/08/10 09:35:07  schinkel
% Added GPL note
%
% Revision 1.7  2007/08/09 09:04:58  schinkel
% Fixed bug in error check
%
% Revision 1.6  2007/07/31 12:11:23  schinkel
% Properly adjusted for Doc for m2html
%
% Revision 1.5  2007/07/31 12:01:58  schinkel
% Adjusted for Doc for m2html
%
% Revision 1.4  2007/07/31 08:33:08  schinkel
% Bugfix in parameter check
%
% Revision 1.3  2007/07/30 12:34:37  schinkel
% Fixed Doc. Tightened up code.
%
% Revision 1.2  2007/07/30 12:33:15  schinkel
% Added windowing. Changing input order
%
% Revision 1.1  2007/07/24 09:13:05  schinkel
% Moved to opTool
%
% Revision 1.1  2007/07/23 13:41:43  schinkel
% Initial Import from helper
%

%% set debug

debug=true;
if debug;warning('on','all');else warning('off','all');end

% check number of input arguments
error(nargchk(1,4,nargin))

% check number of out arguments
error(nargoutchk(0,1,nargout))

%% prevent indexation errors
varargin{4} = [];

if  ~isempty(varargin) && length(varargin{1}) > 1, 
	Y = varargin{1};
	if ~isempty(varargin{2}), lag = varargin{2};else lag = 0;end
	if ~isempty(varargin{3}), nBins = varargin{3};else nBins = 10;end
else
	Y = X;
	if ~isempty(varargin{1}), lag = varargin{1};else lag = 0;end
	if ~isempty(varargin{2}), nBins = varargin{2};else nBins = 10;end
end
%% check if lag is not to big (cf. estDelay)

if lag > length(X) || lag > length(Y);
	error('Lag to large for time series');
end

% get the probablity distributions
pX = histX(X,nBins);
pY = histX(Y,nBins);
pXY = histXY(X,Y,nBins,nBins);

% get the entropy
entropyX = shannon2(pX);
entropyY = shannon2(pY);
entropyXY = shannon2(pXY);

mi = entropyX + entropyY - entropyXY;

if lag > 0
	for i = 1:lag
		Xtmp = X(i+1:end);Ytmp = Y(1:end-i);
		pX = histX(Xtmp,nBins);pY = histX(Ytmp,nBins);pXY = histXY(Xtmp,Ytmp,nBins,nBins);
		entropyX = shannon2(pX);entropyY = shannon2(pY);entropyXY = shannon2(pXY);
		mi(i+1) = entropyX + entropyY - entropyXY;
	end
end

if ~nargout && lag > 0 
	figure;plot(-lag:lag,[mi(end:-1:2) mi(1) mi(2:end)],'k');
	xlabel('Delay'), ylabel('Mutual Information');
	title('Mutual Information','FontWeight','bold');
	grid on;
end
