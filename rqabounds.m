function  varargout = rqabounds(varargin)

%RQABOUNDS - compute overall confidence bounds of RQA measures
%
% function [cis] = rqabounds(X [,Y],dim,tau,eps,norm [,ws,ss,nBoot,alpha,theiler,minL,minV])
%
% Compute confidence bounds (CI) of RQA measures from an RP
% by bootstrapping the diagonal and vertical lines. The overall 
% two-sided CIs of the suitable measures is computed and returned
% to the caller. CIs are computed only for DET/L/LAM/TT. For other
% measures the method is not appropriate.
%
% Note on method selection: 
% Only use 'rr','fan' or 'op'. Other methods are not appropriate!
%
% Input:
%	X = data
%	Y = data (optional)
%	dim = embedding dimension
%	tau = embedding delay
%	eps = epsilon for RP
%	norm = norm used ('rr','fan','op')
%
% Parameters:
%	ws = window size (def: no windowing)
%	ss = step size (def: no windowing)
% 	nBoot = number of bootstrap samples (def: 500)
% 	alpha = confidence level in % (def: 5-two-sided)
% 	theiler = size of the theiler window (def: 1)
% 	minL = minimal size of diagonal lines in RQA (def: 2)
% 	minV = minimal size of vertical lines in RQA (def: 2)
%
% Output:
%	ci(1,:) = confidence bounds of DET
%	ci(2,:) = confidence bounds of L
%	ci(3,:) = confidence bounds of LAM
%	ci(4,:) = confidence bounds of TT
%
%
% requires: CRPTool, prctile (Statistics Toolbox), lineDists, bootstrap
%
% see also: opTool, rqaci
%
% References: 
% N. Marwan, S. Schinkel, J. Kurths: 
% "Significance for a recurrence based transition analysis",
% Proceedings of the International Symposium on Nonlinear Theory 
% and its Applications (NOLTA2008), Budapest, Budapest, Hungary, 412-415 (2008).

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

debug = false;

%% I/O check
if (nargchk(5,13,nargin)), help(mfilename),error(nargchk(5,13,nargin)); end
if (nargchk(0,2,nargout)), help(mfilename),error(nargchk(0,2,nargout)); end

% aquire parameters
varargin{14} = [];

%for sure
X = varargin{1};

% regular RP
if length(varargin{2}) == 1; 
	Y = X; 
	if ~isempty(varargin{2}), dim = varargin{2}; 		else error('No dimension supplied');end
	if ~isempty(varargin{3}), tau = varargin{3}; 		else error('No time delay(tau) supplied');end
	if ~isempty(varargin{4}), eps = varargin{4}; 		else error('No time epsilon supplied');end
	if ~isempty(varargin{5}), norm = varargin{5}; 		else error('No time norm supplied');end
	if ~isempty(varargin{6}), ws = varargin{6}; 		else ws = [];end
	if ~isempty(varargin{7}), ss = varargin{7}; 		else ss = [];end
	if ~isempty(varargin{8}), nBoot = varargin{8};		else nBoot = 500;end
	if ~isempty(varargin{9}), alpha = varargin{9};		else alpha = 5;end
	if ~isempty(varargin{10}), theiler =  varargin{10};	else theiler = 1;end
	if ~isempty(varargin{11}), minLenDiag = varargin{11};	else minLenDiag = 2;end
	if ~isempty(varargin{12}), minLenVert = varargin{12};	else minLenVert = 2;end
else %CRP
	Y= varargin{2}; 
	if length(X) ~= length(Y),error('X & Y must be of same length');end
	if ~isempty(varargin{3}), dim = varargin{3}; 		else error('No dimension supplied');end
	if ~isempty(varargin{4}), tau = varargin{4}; 		else error('No time delay(tau) supplied');end
	if ~isempty(varargin{5}), eps = varargin{5}; 		else error('No time epsilon supplied');end
	if ~isempty(varargin{6}), norm = varargin{6}; 		else error('No time norm supplied');end
	if ~isempty(varargin{7}), ws = varargin{7}; 		else ws = [];end
	if ~isempty(varargin{8}), ss = varargin{8}; 		else ss = [];end
	if ~isempty(varargin{9}), nBoot = varargin{9};		else nBoot = 500;end
	if ~isempty(varargin{10}), alpha = varargin{10};		else alpha = 5;end
	if ~isempty(varargin{11}), theiler =  varargin{11};	else theiler = 1;end
	if ~isempty(varargin{12}), minLenDiag = varargin{12};	else minLenDiag = 2;end
	if ~isempty(varargin{13}), minLenVert = varargin{13};	else minLenVert = 2;end
end

% necessary params
nElems = length(X);
confBounds = [ alpha/2 100-alpha/2 ];

%only window if wanted
if isempty(ws)  || isempty(ss) || ws == nElems

	RP = crp(X,Y,dim,tau,eps,norm,'sil');
	[diagLines vertLines] = lineDists(RP,theiler,1,1);

else

	diagLines = [];
	vertLines = [];
	
	for i=1:ss:nElems-ws;
		
		%compute RP
		RP = crp(X(i:i+ws-1),Y(i:i+ws-1),dim,tau,eps,norm,'sil');

		% we extract all lines, even those of only length 1
		[tmpDiag tmpVert] = lineDists(RP,theiler,1,1);

		diagLines = cat(1,diagLines, tmpDiag);
		vertLines = cat(1,vertLines, tmpVert);

	end

end
	
% alloc memory of bootstrapped values
bsDET = zeros(1,nBoot);
bsL = zeros(1,nBoot);
bsLAM = zeros(1,nBoot);
bsTT = zeros(1,nBoot);

for i=1:nBoot

	% draw a sample
	bsDiagLines = bootstrap(diagLines,1);
	bsVertLines = bootstrap(vertLines,1);
	
	% from the lines we take the total number of
	% points in line structures
	sumDiagLines = sum(bsDiagLines);
	sumVertLines = sum(bsVertLines);

	% now we exclude the short ones
	bsDiagLines(bsDiagLines < minLenDiag) = [];
	bsVertLines(bsVertLines < minLenVert) = [];

	% based on that, compute RQA-measures
	% only makes sense for DET/L/LAM/TT
	bsDET(i) = sum(bsDiagLines)/sumDiagLines;
	bsL(i)  = mean(bsDiagLines);
	bsLAM(i) = sum(bsVertLines)/sumVertLines;
	bsTT(i) = mean(bsVertLines);
end

% get percentiles
ci(1,:) = prctile(bsDET,confBounds);
ci(2,:) = prctile(bsL,confBounds);
ci(3,:) = prctile(bsLAM,confBounds);
ci(4,:) = prctile(bsTT,confBounds);

varargout{1} = ci;

