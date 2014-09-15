function varargout=opCalc(X,dim,tau)

%OPCALC -- Encode time series as a order patterns
%
% function [patterns] = opCalc(X,dim,tau)
%
% Encode time series as series of symbols based on ranks 
% of elements. The function uses different encoding schemes,
% depending on the number of elements forming the pattern.  
% 
% Note: There are two different implentations on how to form 
% the acutal order patterns. For a dimension > 10 a slightly
% slower routine has to used. See source for explanations. 
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
%
% see also: opcrp.m opcrqa.m 



%% debug settings
% debug = 0;
% if debug;warning('on','all');else warning('off','all');end

%% check input
if nargin<3
	error('Usage:[patterns] = opCalc(X,dim,tau)');
end

if dim < 2;
	error('Too few time instances. Need at least tau=2'),
end

if  tau < 1;
	error('Delay must be positive integer >= 1'),
end

if length(X) < (dim-1)*tau;
	error('Time series too short. Need a least (dim-1)*tau');
end



% allocate mem for output
pattern = zeros(numel(X)-(dim-1)*tau,1);

% switch between fixed and flexible
% base encoding. 
if dim < 10
	for i = 1:numel(X)-(dim-1)*tau
		
		% sort the data
		[a b] = sort(X(i:tau:i+tau*dim-1));
		
		% we start with 10^0 
		calcPow = 0;

		% loop over order in reverse
		for j = numel(b):-1:1
			pattern(i) = pattern(i) + b(j)*10^calcPow;
			
			%increase power: since we only use 
			% it for dim < 10, its always just + 1
			calcPow = calcPow + 1;
			% if b(j) > 9;
			% 	calcPow = calcPow +2;
			% else 
			% 	calcPow = calcPow + 1;
			% end
		
		end	% j  
	end % i 

else
	
	%pre-compute mask
	mask = cumprod( [1 dim(ones(1,dim-1))] )';

	for i=1:numel(X)-(dim-1)*tau
		% sort data
		[a b] = sort(X(i:tau:i+tau*dim-1));

		% multiply with mask and sum
		pattern(i) = sum( b .*mask);

	end % i
end %if dim 

%% assign output
varargout{1}=pattern;

% why are there two distinct algorithms: 
% The algorithm used for dim < 11 is the faster one (timings below),
% but breaks whenever the dimension is large 11 for the following 
% reason. Using a fixed base (10) will yield ambiguities under certain
% boundary conditions. If for example the sorting routine returns
% b = [1 2 12 3:10] this gives the pattern 1212345678910 which cannot
% be distinguished from b = [ 12 1 2 3:10] which also returns the
% sequence 1212345678910. 
% Using a flexible base for the number system avoids this, but increases
% computing time. On the other hand, with dim < 10 the difference becomes
% neglibile and the second implementation eventually is even faster. It is
% indeed rather constant in runtime. See hex2dec.m for 
%
% Timings of the 2 routines. Shown are the average runtimes of 100
% runs in seconds. Apart from being wrong, the fixed base routine
% also is slower for dim > 13 The fist runtime
% Dim 02 -> match. Timing: 0.0089/0.0120
% Dim 03 -> match. Timing: 0.0090/0.0119
% Dim 04 -> match. Timing: 0.0092/0.0120
% Dim 05 -> match. Timing: 0.0096/0.0121
% Dim 06 -> match. Timing: 0.0098/0.0120
% Dim 07 -> match. Timing: 0.0098/0.0117
% Dim 08 -> match. Timing: 0.0099/0.0115
% Dim 09 -> match. Timing: 0.0102/0.0115
% Dim 10 -> match. Timing: 0.0103/0.0115
% Dim 11 -> match. Timing: 0.0106/0.0115
% Dim 12 -> match. Timing: 0.0108/0.0117
% Dim 13 -> match. Timing: 0.0109/0.0115
% Dim 14 -> match. Timing: 0.0110/0.0115
% Dim 15 -> match. Timing: 0.0113/0.0111
% Dim 16 -> match. Timing: 0.0113/0.0113
% Dim 17 -> match. Timing: 0.0116/0.0110
% Dim 18 -> match. Timing: 0.0116/0.0112
% Dim 19 -> match. Timing: 0.0115/0.0107
% Dim 20 -> match. Timing: 0.0117/0.0107
	
