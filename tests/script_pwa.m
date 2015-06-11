clear
close all
clc

root = fileparts(fileparts(mfilename('fullpath')));
addpath( fullfile(root,'classes') );

horizon = 5;
rfact = 2;

% load the network and build the lp
stngs = Stngs;
net= Network(stngs);

% build and solve MPLP
pwa = PWA(net,stngs,horizon,'V',rfact);
pwa.plot_P;

tic
pwa.build_explicit;
toc

save aaa