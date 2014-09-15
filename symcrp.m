function varargout = symcrp(varargin)

%symcrp Coloured Order Patterns (Cross) Recurrence Plot
%
% function [rp] = symcrp(X,[Y],dim,tau)
%
% Input:
%	X = time series 
%	Y = time series (optional)
%	dim = dimension 
%	tau = time delay
%
% Output:
%	rp = coloured (cross) recurrence plot 
%
% requires: opTool
%
% see also: pop_crp.m opcrqa.m 
%
% Note: The maximal supported dimension is 13.
%

% Copyright (C) 2008 Stefan Schinkel, University of Potsdam
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


% $Log$


%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end

%% check number of input arguments
if(nargchk(3,4,nargin)), 
	disp(sprintf('ERROR OCCURRED:\t%s\n',nargchk(3,4,nargin)));	help(mfilename)
end

if(nargchk(0,1,nargout))
	disp(sprintf('ERROR OCCURRED:\t%s\n',nargchk(0,1,nargout)));help(mfilename)
end

%% check && assign input

varargin{5}=[];	
X = varargin{1};

if length(varargin{2}) == 1  % RP
	calcMode = 1;	
	dim = varargin{2};
	tau = varargin{3};
else % CRP
	calcMode = 2; 
	Y = varargin{2};
	dim = varargin{3};
	if isempty(varargin{4}),
		error('No time delay(tau) supplied');
	else	
		tau = varargin{4};
	end
end


if calcMode == 1 %% RP 
	symX = opCalc(X,dim,tau);
	symY = symX';
elseif calcMode == 2 %% CRP 

	lenX = length(X);
	lenY = length(Y);
	if lenX ~= lenY, error('X and Y must have the same length');end
	symX = opCalc(X,dim,tau);
	symY = opCalc(Y,dim,tau);
	symY = symY';
end

%% construct rp
rp =  uint8(symX(:,ones(1,length(symX)),:) == symY(ones(1,length(symY)),:,:))';	

%replace sym by integers
ops = possiblePatterns(dim);

for i=1:length(ops)
	symX(symX == ops(i)) = i;
end
% symMatrix to match
symX = uint8(symX');
symMatrix = repmat(uint8(symX),size(rp,1),1);

% colourise
symRP = rp.*symMatrix;

% build colourmap




if nargout
	varargout{1} = symRP;
else
	figHandle = figure;
	axHandle = axes('Parent',figHandle);
	axes(axHandle);
	imagesc(symRP); 
	set(gca,'YDir','normal');
	cmap = colormap(jet(length(unique(symX))));
	cmap(length(cmap)+1,:) = 1;
	cmap = flipud(cmap);
	colormap(cmap);
end

