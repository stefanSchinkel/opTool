function [p z x]=histX(x,nBinsX)

%histX compute histogram.
%
% function [p z x]=histX(x,nBinsX)
% 
% The functions computes the probabilites and the histogram
% of the distribution and returns them in p and z. If no output 
% is specified, the histogram is plotted. 
%
% The bin size for X is optional. If none given, it defaults 
% to 10. 
%
% Input:
%	X = data
%	bins = number of bins
%
% Output
%
%	p = probability of bin
%	z = histogramm
%	x = matrix indicating bin of element in X
%
%	requires: 
%
%	See also: shannon.m mutualInfo.m 
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



% $Log: histX.m,v $
% Revision 1.5  2007/08/10 09:35:07  schinkel
% Added GPL note
%
% Revision 1.4  2007/07/31 12:11:24  schinkel
% Properly adjusted for Doc for m2html
%
% Revision 1.3  2007/07/31 12:01:58  schinkel
% Adjusted for Doc for m2html
%
% Revision 1.2  2007/07/25 09:19:49  schinkel
% Fixed bug occuring when Xmin==Xmax
%
% Revision 1.1  2007/07/24 09:13:05  schinkel
% Moved to opTool



% ToDO : return spread of bins and plot those ?


debug=true;
if debug;warning('on','all');else warning('off','all');end

% check number of input arguments
error(nargchk(1,2,nargin))

% check number of out arguments
error(nargoutchk(0,3,nargout))

% check additional arguments
if nargin < 2, nBinsX = 10; end

% find minima and maxima for binning 
Xmin = min(x); Xmax = max(x);

%% add one more eps for x==Xmin==Xmax to not divide by zero
x = fix( ( (x - Xmin) / ((Xmax - Xmin) + eps) )*nBinsX  - nBinsX*eps );x = x + 1;

% compute the distribution

n = version;
if n(1) >= 7,
	z = full(sparse(x,1,1));
else
	z = accumarray(x, 1);
end

% from the histogram we compute the probabilties (nonzero only)

p = z(z ~= 0)/length(x);

if nargout == 0,
	figure; bar(z); title('Histogram of X');axis tight;
end
