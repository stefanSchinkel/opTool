function varargout=opCalc(X,dim,tau)

%opCalc Encode time series as a symbols based on ranks.
%
% function [patterns] = opCalc(X,dim,tau)
%
% Encode time series as series of symbols based on ranks 
% on elements. the function uses different encoding schemes,
% depending on the number of elements forming the pattern.  
% 
% Note: Limitation for dimension is 10 (due to endoding routine,
% hexadecimal or other base will allow higher)
%
% Input:
% 	X = time series (vector)
% 	dim = dimension (number of points)
% 	tau = time delay (distance between points)
%
% Output:
% 	patterns = encoded time series
%
% requires: 
%
% see also: opcrp.m opcrqa.m CRPtool



%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end

%% check input

if nargin<3
	error('Usage:[patterns] = opCalc(X,dim,tau)');
end

if dim < 2;
	error('Too few time instances. Need at least tau=2'),
% elseif dim > 10;
% 	error('Dimension too large. Max dim supported: 10.');
end
if  tau < 1;
	error('Delay must be positive integer >= 1'),
end

if length(X) < (dim-1)*tau;
	error('Time series too short. Need a least (dim-1)*tau');
end

pattern = zeros(numel(X)-(dim-1)*tau,1);
mask = cumprod( [1 dim(ones(1,dim-1))] )';

for i=1:numel(X)-(dim-1)*tau
	[a b]=sort(X(i:tau:i+tau*dim-1));
	pattern(i) = sum( b .*mask);
end
	


%% assign output
varargout{1}=pattern;

	
