function varargout = possiblePatterns(dim)

%possiblePatterns = all possible patterns for dim
%
% function [patterns] = possiblePatterns(dim)
%
% Computes all possible patterns in dimension dim.
% 
% Needed as input for wordstatN since for d >=4 not
% all possible patterns necessarily occur in one epoch
% and we have to search for the patterns by hand using
% for i=1:numel(patterns) wstat(i)  = find(X == patterns(i));end
% -> which of course sucks ...
% 
% Note: Limitation for dimension is 9 (due to memory restrictions)
%
% Input:
% 	dim = dimension (number of points)
%
% Output:
% 	patterns = all possible patterns 
%
% requires: 
%
% see also: opTool

% Copyright (C) 2008 Stefan Schinkel, University of Potsdam
% http://www.agnld.uni-potsdam.de/~schinkel/ 

%% check input
if nargin<1,error('Usage:[patterns] = possiblePatterns(dim)');end

if dim < 2;
	error('Too few time instances. Need at least tau=2'),
elseif dim >= 10 ;
	error('Dimension too large. Dim > 9 kills your box.');
end

%% all possible permutations
possPerms = perms(1:dim);

%% allocate output
patterns = zeros(factorial(dim),1);

for i=1:factorial(dim)

	calcPow = 0;
	for j = dim:-1:1
		patterns(i) = patterns(i) + possPerms(i,j)*10^calcPow;
		calcPow = calcPow + 1;
	end	
end

%% assign output
varargout{1} = patterns;
