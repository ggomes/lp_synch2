clear
close all
clc

root = fileparts(fileparts(mfilename('fullpath')));
rmpath(fullfile(root,'classes','4D')) 
addpath(fullfile(root,'classes','2D')) 
addpath(fullfile(root,'classes','control')) 

% load 
net= Network();
ctm = CTM(net);
    
% run ctm
K = 10;
x0 = [6;6];
X_no_control = ctm.run_no_control(x0,K);
X_alinea = ctm.run_with_controller(ControllerAlinea(net),x0,K);
X_explicit = ctm.run_with_controller(ControllerExplicit([0;0]),x0,K);

% plot
X_no_control.plotme('no control')
X_alinea.plotme('alinea')
X_explicit.plotme('explicit')