function [  ] = sweep_beta(  )


root = fileparts(fileparts(mfilename('fullpath')));
rmpath(fullfile(root,'classes','2D'))
addpath(fullfile(root,'classes','4D'))
addpath(fullfile(root,'classes'))
results_folder = fullfile(root,'results');

clc
close all

N = 9;
Beta = [0.9 0.5 0.2 0.05 0.02];
Rbar = [1500 1300 1100 900];

cfgstruct = struct('beta',nan,'rbar',nan,'Kdem',nan,'cooldown',nan,'etha',0.1);
filename = fullfile(results_folder,'fullcfg');
if exist([filename '.mat'],'file')
    load(filename)
else
    cfg = repmat(cfgstruct,1,0);
end

% initial populate
for r=1:length(Rbar)
    for b=1:length(Beta)
        if(isempty(cfg) || ~any([cfg.beta]==Beta(b) & [cfg.rbar]==Rbar(r)))
            c = cfgstruct;
            c.beta = Beta(b);
            c.rbar = Rbar(r);
            cfg(end+1) = c;
        end
    end
end

for r=1:length(Rbar)
    Kdem = 500;
    cooldown = 100;
    for b=1:length(Beta)
        beta = Beta(b);
        rbar = Rbar(r);
        ind = [cfg.beta]==Beta(b) & [cfg.rbar]==Rbar(r);
        if(any(ind) && isnan(cfg(ind).Kdem))
            [Kdem,cooldown] = get_horizon(beta,rbar,Kdem,cooldown,cfg(ind).etha,100,1e-3);
            cfg(ind).Kdem = Kdem;
            cfg(ind).cooldown = cooldown;
            save(filename,'cfg')
        end
    end
end

for i=1:length(cfg)
    sweep_lp(cfg(i),N);
end
