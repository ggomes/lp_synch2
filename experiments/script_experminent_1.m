clear
close all
clc

addpath(fullfile(fileparts(mfilename('fullpath')),'src') ) 
addpath(fullfile(fileparts(mfilename('fullpath')),'src','classes') ) 

% load the network and build the lp
stngs = load_simulation_settings;
net= Network(stngs);
lp = LP(net,stngs,'ic_given');
ctm = CTM(net,stngs);

% ranges of parameters

% build and solve MPLP
mplp = MPLP(net,lp,stngs);
mplp = mplp.solve();
