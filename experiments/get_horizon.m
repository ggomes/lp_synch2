function [Kdem,cooldown,T] = get_horizon(beta,rbar,Kdem0,cooldown0,etha,step,thresh)

fprintf('------ get horizon beta=%.2f, rbar=%.0f\n',beta,rbar)

Kdem = Kdem0;
cooldown = cooldown0;
% horizon = Kdem + cooldown;

net= Network(Kdem0,beta,rbar);

[~,~,~,~,~,nb1,nb2] = net.get_short_names;
n0 =[nb1-0.1;nb2-0.1];
l0 = [0;0];
[n1ss,n2ss] = net.get_steady_state;

c = 0;
while(c<5)
    
    horizon = Kdem + cooldown;

    c = c + 1;
    
%     KdemAll(c) = Kdem;
    
    % solve lp
    net= Network(Kdem,beta,rbar);
    lp = LP(net,horizon,etha,n0,l0);
    lp.solve;
    T(c) = lp.get_solution;  
    
%     % plot
%     f=pwa.plot_P;
%     figure(f);
%     hold on
%     plot(T(c).n(1,:),T(c).n(2,:),'k.','LineWidth',1)
%     plot(T(c).n(1,1),T(c).n(2,1),'ko','MarkerSize',6)
%     plot(T(c).n(1,Kdem),T(c).n(2,Kdem),'c*','MarkerSize',8)
%     plot(T(c).n(1,end),T(c).n(2,end),'k.','MarkerSize',20)
%     plot(n1ss,n2ss,'co')

    % evaluate done
    reached_ss = abs(T(c).n(1,Kdem)-n1ss)<thresh && abs(T(c).n(2,Kdem)-n2ss)<thresh;
    reached_zero = abs(T(c).n(1,end))<thresh && abs(T(c).n(2,end))<thresh;

    if(~reached_zero)
        fprintf('%d: zero not reached, Kdem=%d, cooldown=%d\n',c,Kdem,cooldown)
        cooldown = cooldown + step;
        continue
    end
    
    if(~reached_ss)
        fprintf('%d: ss not reached, Kdem=%d, cooldown=%d\n',c,Kdem,cooldown)
        Kdem = Kdem + step;
        continue
    end
    
    break

end

% K = max([T.K])+1;
% C = length(T);
% n1 = nan(C,K);
% l1 = nan(C,K);
% f1 = nan(C,K);
% r1 = nan(C,K);
% 
% n2 = nan(C,K);
% l2 = nan(C,K);
% f2 = nan(C,K);
% r2 = nan(C,K);
% 
% for c=1:length(T)
%     k = T(c).K+1;
%     n1(c,1:k) = T(c).n(1,:);
%     l1(c,1:k) = T(c).l(1,:);
%     f1(c,1:k-1) = T(c).f(1,:);
%     r1(c,1:k-1) = T(c).r(1,:);
%     
%     n2(c,1:k) = T(c).n(2,:);
%     l2(c,1:k) = T(c).l(2,:);
%     f2(c,1:k-1) = T(c).f(2,:);
%     r2(c,1:k-1) = T(c).r(2,:);   
% end

% figure('Position',[1017 931 560 564])
% leg = num2str([T.K]');
% subplotf(4,1,'f1','',1:K,f1,'1','.-',leg,1); hold on
% setstuff(K,KdemAll,f1ss)
% subplotf(4,2,'n1','',1:K,n1,'1','.-',leg,1); 
% setstuff(K,KdemAll,n1ss)
% subplotf(4,3,'r1','',1:K,r1,'1','.-',leg,1); 
% setstuff(K,KdemAll,r1ss)
% subplotf(4,4,'l1','',1:K,l1,'1','.-',leg,1); 
% setstuff(K,KdemAll)
% 
% figure('Position',[1604         929         560         573])
% leg = num2str([T.K]');
% subplotf(4,1,'f2','',1:K,f2,'2','.-',leg,1); 
% setstuff(K,KdemAll,f2ss)
% subplotf(4,2,'n2','',1:K,n2,'2','.-',leg,1); 
% setstuff(K,KdemAll,n2ss)
% subplotf(4,3,'r2','',1:K,r2,'2','.-',leg,1); 
% setstuff(K,KdemAll,r2ss)
% subplotf(4,4,'l2','',1:K,l2,'2','.-',leg,1); 
% setstuff(K,KdemAll)
% 
% figure
% cost = 1*(n1 + n2 + l1 + l2) - etha * (f1 + f2 + r1 + r2);
% subplotf(2,1,'cost','',1:K,cost,'','-',leg,2); 
% setstuff(K,KdemAll)
% subplotf(2,2,'cum cost','',1:K,cumsum(cost'),'','-',leg,2); 
% setstuff(K,KdemAll)

