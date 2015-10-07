function []=sweep_lp(cfg,N)

if(nargin==0)
    error('too few arguments')
end

root = fileparts(fileparts(mfilename('fullpath')));
rmpath(fullfile(root,'classes','2D')) 
addpath(fullfile(root,'classes','4D')) 
addpath(fullfile(root,'classes')) 

% load the network and build the lp
fprintf('----- computing horizon, beta=%.2f ------\n',cfg.beta)
horizon = cfg.Kdem + cfg.cooldown;
eps = 0.01;
net= Network(cfg.Kdem,cfg.beta,cfg.rbar);
[~,~,~,~,~,nb1,nb2]=net.get_short_names;
N1 = linspace(0,nb1,N);
N2 = linspace(0,nb2,N);

% problem is infeasible otherwise
N1(1) = eps;
N2(1) = eps;
N1(end) = N1(end)-eps;
N2(end) = N2(end)-eps;

%  sweep initial conditions
c=0;
results_folder = fullfile(root,'results');
for i=1:N
    for j=1:N
        fprintf('----- ic sweep (%.2f,%.2f,%.2f) ------\n',cfg.beta,N1(i),N2(j))
        c = c+1;
        n0 = [N1(i);N2(j)];
        l0 = [0;0];
        
        filename = fullfile(results_folder,sprintf('%.0f_%.0f_%.0f_%.0f',cfg.rbar,cfg.beta*100,N1(i)*100,N2(j)*100));
        
        if exist([filename '.mat'],'file')
           continue    
        end
        
        lp = LP(net,horizon,cfg.etha,n0,l0);
        lp.solve;
        
        warning off
        save(filename,'lp')
        warning on
    end
end 

% Zn = [];
% Zu = [];
% for c=1:length(X)
%     Zn = [Zn X(c).T.n(:,1:Kdem)];
%     Zu = [Zu X(c).T.u(:,1:Kdem)];
% end
% 
% f=pwa.plot_P;
% set(get(gca,'Children'),'FaceAlpha',0)
% ind_maxmax = Zu(1,:)==1.25 & Zu(2,:)==1.25;
% ind_minmin = Zu(1,:)==0 &  Zu(2,:)==0;
% ind_other = ~ind_maxmax & ~ind_minmin;
% figure(f), hold on
% plot(Zn(1,ind_maxmax),Zn(2,ind_maxmax),'r.')
% hold on
% plot(Zn(1,ind_minmin),Zn(2,ind_minmin),'g.')
% plot(Zn(1,ind_other),Zn(2,ind_other),'c.')


% N0 = [X.n0];
% cost = [X.cost];
% U = [X.U];
% T = [X.T];
% 
% N1o = reshape(N0(1,:),N,N)';
% N2o = reshape(N0(2,:),N,N)';
% u1 = reshape(U(1,:),N,N)';
% u2 = reshape(U(2,:),N,N)';
% J = reshape(cost,N,N)';
% 
% f=pwa.plot_P;
% figure(f);
% hold on
% for i=1:length(T)
%     plot(T(i).n(1,1:Kdem),T(i).n(2,1:Kdem),'k','LineWidth',1)
%     plot(T(i).n(1,1),T(i).n(2,1),'ko','MarkerSize',6)
%     plot(T(i).n(1,end),T(i).n(2,end),'k.','MarkerSize',20)
% end
            

% pwa.plot_P;
% set(get(gca,'Children'),'FaceAlpha',0)
% hold on
% h=surf(N1o,N2o,J,'EdgeAlpha',0);
% title('Cost')
% 
% pwa.plot_P;
% set(get(gca,'Children'),'FaceAlpha',0)
% hold on
% surf(N1o,N2o,u1,'EdgeAlpha',0)
% title('u1')
% 
% pwa.plot_P;
% set(get(gca,'Children'),'FaceAlpha',0)
% hold on
% surf(N1o,N2o,u2,'EdgeAlpha',0)
% title('u2')

% 

