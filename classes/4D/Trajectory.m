classdef Trajectory < handle
    
    properties
        
        K
        n
        l
        r
        f
        u
        cost
        
    end
    
    methods
        
        function [obj]=Trajectory(K,n0,l0)
            obj.K = K;
            obj.n = zeros(2,K+1);
            obj.f = zeros(2,K);
            obj.l = zeros(2,K+1);
            obj.r = zeros(2,K);
            obj.u = zeros(2,K);
            if nargin>=2
                obj.n(:,1) = n0;
                obj.l(:,1) = l0;
            end
        end
        
        function [obj]=evaluate_cost(obj,etha)
            obj.cost = sum(sum(obj.n + obj.l)) - etha * sum(sum(obj.f + obj.r));
        end
        
        function []=plotme(obj,name,Kdem)
            
            if nargin<2
                name = '';
            end
            if nargin<3
                Kdem = NaN;
            end
            
            time0 = 0:obj.K-1;
            time1 = 0:obj.K;
            
            figure
            subplot(211)
            plot(time0,obj.f,'LineWidth',2)
            set(gca,'XLim',[0 obj.K])
            line([Kdem Kdem],get(gca,'YLim'),'Color','k','LineStyle','--')
            legend('f1','f2')
            grid
            title(['mainline ' name])
            subplot(212)
            plot(time1,obj.n,'LineWidth',2)
            set(gca,'XLim',[0 obj.K])
            line([Kdem Kdem],get(gca,'YLim'),'Color','k','LineStyle','--')
            legend('n1','n2')
            grid
            
            figure
            subplot(211)
            plot(time0,obj.r,'LineWidth',2)
            set(gca,'XLim',[0 obj.K])
            line([Kdem Kdem],get(gca,'YLim'),'Color','k','LineStyle','--')
            legend('r1','r2')
            grid
            title(['onramps ' name])
            subplot(212)
            plot(time1,obj.l,'LineWidth',2)
            set(gca,'XLim',[0 obj.K])
            line([Kdem Kdem],get(gca,'YLim'),'Color','k','LineStyle','--')
            legend('l1','l2')
            grid
            
            figure
            plot(time0,obj.u,'LineWidth',2)
            set(gca,'XLim',[0 obj.K])
            line([Kdem Kdem],get(gca,'YLim'),'Color','k','LineStyle','--')
            legend('u1','u2')
            title(['control ' name])
            grid
        end
        
    end
    
end

