function [ output_args ] = Untitled3( input_args )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
t = 0:.001:.25;
x = sin(2*pi*50*t) + sin(2*pi*120*t);
y = x + 2*randn(size(t));
plot(t,y(1:50))
title('Noisy time domain signal')

end

