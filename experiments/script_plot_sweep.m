clear
close all

root = fileparts(fileparts(mfilename('fullpath')));
rmpath(fullfile(root,'classes','2D'))
addpath(fullfile(root,'classes','4D'))
addpath(fullfile(root,'classes'))

results_folder = fullfile(root,'results');
d = dir(results_folder);
d([d.isdir]) = [];

% gather useful files
keep = [];
for i=1:length(d)
    filename = d(i).name;
    a=sscanf(filename,'%d_%d_%d_%d.mat');
    if numel(a)~=4
        continue
    end
    keep = [keep {filename}];
end
clear d filename

% allocate
feas = false(1,length(keep));
n1 = nan(1,length(keep));
n2 = nan(1,length(keep));
r1 = nan(1,length(keep));
r2 = nan(1,length(keep));
beta = nan(1,length(keep));

% extract information
for i=1:length(keep)
    load(fullfile(results_folder,keep{i}))     % loads lp
    n1(i) = lp.X.n(1,1);
    n2(i) = lp.X.n(2,1);
    r1(i) = lp.X.r(1,1);
    r2(i) = lp.X.r(2,1);
    feas(i) = lp.diag.problem==0;
    
    a=sscanf(keep{i},'%d_%d_%d_%d.mat');
    rbar(i) = a(1);
    beta(i) = a(2);
end

% plot feasibility
figure
plot(n1(feas),n2(feas), ...
    'Marker','.',...
    'LineStyle','none',...
    'MarkerEdgeColor','b',...
    'MarkerSize',10);
hold on
plot(n1(~feas),n2(~feas),...
    'Marker','o',...
    'LineStyle','none',...
    'MarkerEdgeColor','r',...
    'MarkerSize',10);
xlabel('n1')
ylabel('n2')
title(sprintf('feasible lps, percent feasible = %.0f%%',100*sum(feas)/numel(feas)))
grid

% keep only feasible
n1 = n1(feas);
n2 = n2(feas);
r1 = r1(feas);
r2 = r2(feas);
beta = beta(feas);
rbar = rbar(feas);

% get unique betas
u_beta = unique(beta);
u_rbar = unique(rbar);

% loop through betas, plot control for each
for i=1:length(u_rbar)
    
    for j=1:length(u_beta)
        
        ind = beta==u_beta(j) & rbar==u_rbar(i);
        
        % plot control
        figure
        set(cline(n1(ind),n2(ind),r2(ind)),'Marker','.',...
            'LineStyle','none',...
            'MarkerSize',10);
        xlabel('n1')
        ylabel('n2')
        title(sprintf('rbar=%d, beta=%.0f%%',u_rbar(i),u_beta(j)));
        grid
        
    end
    
end

