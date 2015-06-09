clear
close all
clc

% load the network and build the lp
stngs = Stngs;
net= Network(stngs);
lp = LP(net,stngs,'ic_in_set');
ctm = CTM(net,stngs);

% build and solve MPLP
mplp = MPLP(net,lp,stngs);
mplp = mplp.solve();

% solution.xopt.merge('obj');
% solution.xopt.merge('primal');
% figure; hold on; for i=1:N solution.xopt.Set(i).plot; end;

mplp.plot();

ctm_no_control = ctm.run_no_control;

% plot_compare_run(ddd)
