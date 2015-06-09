clear
close all
clc

addpath( fullfile(fileparts(mfilename('fullpath')),'classes') )

% load 
stngs = Settings;
net= Network(stngs);
ctm = CTM(net,stngs);
    
% run ctm
X_no_control = ctm.run_no_control;
X_alinea = ctm.run_with_controller(ControllerAlinea(net));
X_explicit = ctm.run_with_controller(ControllerExplicit([0;0]));

% plot
X_no_control.plotme('no control')
X_alinea.plotme('alinea')
X_explicit.plotme('explicit')