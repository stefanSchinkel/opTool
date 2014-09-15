function [dim] = estDim(X,varargin)

%ESTDELAY estimate embedding dimension
%
% function [dim] = estDim(X,M,T)
%
% The function computes the embedding dimension of vector X
% using the fnn algorithm provided by the CRPtoolbox.
%
% Input:
% 	X = time series (vector)
%
% Parameters:
% 	M = maximal dimension (def: 10)
%	T = lag to use time-lagged estimation (def: 1)
%
% Output:
% 	dim = embedding dimension
%
% requires: CRPtool  
% 
% see also: fnn.m
%


% Copyright (C) 2009 Stefan Schinkel, University of Potsdam
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
%
% $Log$


%% set debug

debug=true;
if debug;warning('on','all');else warning('off','all');end

% I/O check and assingment
error(nargchk(1,3,nargin))
error(nargoutchk(0,1,nargout))

%% prevent indexation errors
varargin{3} = [];
X = double(X); % cast to double, better for EEG data
if ~isempty(varargin{1}), maxDim = varargin{1};else maxDim = 10;end
if ~isempty(varargin{2}), lag = varargin{2};else lag = 1;end

% the acutal thing

e = fnn(X,maxDim,lag,'sil');
[a b] = min(e);
dim = b;
