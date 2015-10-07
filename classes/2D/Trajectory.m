classdef Trajectory < handle
    
    properties
        
        K
        n
        r
        f
        u
        
    end
    
    methods
        
        function [obj]=Trajectory(n0,K)
            obj.K = K;
            obj.n = zeros(2,K+1);
            obj.f = zeros(2,K);
            obj.r = zeros(2,K);
            obj.u = zeros(2,K);
            if nargin>=2
                obj.n(:,1) = n0;
            end
        end
        
        function [cost]=evaluate_cost(obj,etha)
            cost = sum(sum(obj.n)) - etha * sum(sum(obj.f + obj.r));
        end
        
        function []=plotme(obj,name)
            
            if(nargin<2)
                name = '';
            end
            
            time0 = 0:obj.K-1;
            time1 = 0:obj.K;
            
            figure
            subplot(211)
            plot(time0,obj.f,'LineWidth',2)
            set(gca,'XLim',[0 obj.K])
            line([obj.K obj.K],get(gca,'YLim'),'Color','k','LineStyle','--')
            legend('f1','f2')
            grid
            title(['mainline ' name])
            subplot(212)
            plot(time1,obj.n,'LineWidth',2)
            set(gca,'XLim',[0 obj.K])
            line([obj.K obj.K],get(gca,'YLim'),'Color','k','LineStyle','--')
            legend('n1','n2')
            grid
            
            figure
            subplot(211)
            plot(time0,obj.r,'LineWidth',2)
            set(gca,'XLim',[0 obj.K])
            line([obj.K obj.K],get(gca,'YLim'),'Color','k','LineStyle','--')
            legend('r1','r2')
            grid
            title(['onramps ' name])
            
            figure
            plot(time0,obj.u,'LineWidth',2)
            set(gca,'XLim',[0 obj.K])
            line([obj.K obj.K],get(gca,'YLim'),'Color','k','LineStyle','--')
            legend('u1','u2')
            title(['control ' name])
            grid
        end
        
    end
    
end

