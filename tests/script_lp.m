clear
close all
clc

root = fileparts(fileparts(mfilename('fullpath')));
addpath( fullfile(root,'classes') );

% load the network and build the lp
net= Network();
lp = LP(net,'ic_given');
ctm = CTM(net,stngs);

% solve it
lp.solve;

% check solution
if ~ctm.check(lp.X)
    warning('The solution is not CTM-like')
else
    lp.X.plotme
end
