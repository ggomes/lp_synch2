clear
close all
clc

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'classes')) 

% load the network and build the lp
stngs = Stngs;
net= Network(stngs);
lp = LP(net,stngs,'ic_in_set');

% build and solve MPLP
tic 
mplp = MPLP(net,lp,stngs);
mplp = mplp.solve();
toc