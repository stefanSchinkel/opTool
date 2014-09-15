function [p z]=histXY(x,y,nBinsX,nBinsY)

%histXY Compute joint histogram.
%
% function [p z]=histXY(x,y,nBinsX,nBinsY)
%
% The functions computes the joint probabilites and the histogram
% of the joint distribution and returns them in p and z. If no output
% is specified, the histogram is plotted.
%
% The bin sizes for X and Y are optional. If none given, both default
% to 10. If only one bin size is given, the second defaults to the first
% bin size.
%
% requires:
%
% See also: histX.m shannon.m mutualInfo.m
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

% $Log: histXY.m,v $
% Revision 1.5  2007/08/10 09:35:07  schinkel
% Added GPL note
%
% Revision 1.4  2007/07/31 12:11:24  schinkel
% Properly adjusted for Doc for m2html
%
% Revision 1.3  2007/07/31 12:01:59  schinkel
% Adjusted for Doc for m2html
%
% Revision 1.2  2007/07/25 09:21:24  schinkel
% Fixed bug occuring when Xmin==Xmax/Ymin==Ymax
%
% Revision 1.1  2007/07/24 09:13:05  schinkel
% Moved to opTool
%
% Revision 1.1  2007/07/23 13:41:43  schinkel
% Initial Import from helper
%
% Revision 1.1  2007/06/05 15:05:46  schinkel
% Initial Import
%

% NOTE:
% usually one would bin the data using sth. like the following: 
%
% x = floor((x - Xmin)/ (Xmax - Xmin + eps) * nBins); x = x + 1;
% y = floor((y - Ymin)/ (Ymax - Ymin + eps) * nBins); y = y + 1;
%
% due to the weird behaviour of floor this is not possible
% adding nBins*eps ensures that the bins have an upper limit of nBins-1
% but results in using the bin '-1' since floor rounds towards -Inf
% while fix rounds towards 0 


debug=true;
if debug;warning('on','all');else warning('off','all');end

%% check number of input arguments
error(nargchk(2,4,nargin))

%% check number of out arguments
error(nargoutchk(0,2,nargout))

%% check obligatory input

if ~isvector(x),error('x needs to be a vector');end
if ~isvector(y),error('y needs to be a vector');end

if length(x) ~= length(y)
	error('histxy requires vectors to be of the same size');
end

% check additional arguments
if nargin < 3, nBinsX = 10; end
if nargin < 4, nBinsY = nBinsX;end

%% find minima and maxima for binning 
Xmin = min(x); Xmax = max(x); Ymin = min(y); Ymax = max(y); 

% bin the data from 0 to nBins-1 
% the added nBins*eps ensures that for x = Xmax the result is .999...
% using fix and then adding 1 gives the correct distribution
% contrary to floor, fix rounds towards 0 not +/- Inf
% hence only nBins are used. floor uses nBins + 1 are used
% we have to add nBins*eps otherwise Matlab ignores eps

x = fix( ( (x - Xmin) / ((Xmax - Xmin) + eps) )*nBinsX  - nBinsX*eps );x = x + 1;
y = fix( ( (y - Ymin) / ((Ymax - Ymin) + eps) )*nBinsY  - nBinsY*eps );y = y + 1;

% compute the joint distribution
% depending on the matlab version use full(sparse()) or accumarray 

n = version;
if n(1) >= 7,
	z = full(sparse(x,y,1));
else
	z = accumarray({x y}, 1);
end

% from the histogram we compute the probabilties (nonzero only)

p = z(z ~= 0)/length(x);

if nargout == 0,
	figure; bar3(z); title('Joint histogram of X and Y');axis tight;
end
