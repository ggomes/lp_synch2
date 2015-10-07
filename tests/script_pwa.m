clear
close all
clc

root = fileparts(fileparts(mfilename('fullpath')));
addpath( fullfile(root,'classes') );

horizon = 1;
rfact = 2;

% load the network and build the lp
stngs = Stngs;
net= Network(stngs);

% build and solve MPLP
pwa = PWA(net,horizon,'V',rfact);

runs(1).x0 = [6;6];
runs(1).u = zeros(2,10);
runs(2).x0 = [7;7];
runs(2).u = zeros(2,10);
runs(3).x0 = [8;8];
runs(3).u = zeros(2,10);
runs(4).x0 = [9;9];
runs(4).u = zeros(2,10);

pwa.simulate(runs)

% pwa.build_explicit();

% save aaa