clear
close all
clc

addpath( fullfile(fileparts(mfilename('fullpath')),'classes') )

% load the network and build the lp
stngs = Stngs;
net= Network(stngs);
lp = LP(net,stngs,'ic_given');
ctm = CTM(net,stngs);

% solve it
lp.solve;

% check solution
if ~ctm.check(lp.X)
    warning('The solution is not CTM-like')
else
    lp.X.plotme
end
