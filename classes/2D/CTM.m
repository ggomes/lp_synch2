classdef CTM < handle
    
    properties
        Net
    end
    
    methods( Access = public )
        
        function [obj] = CTM(net)
            obj.Net = net;
        end
        
        % X is a Trajectory
        function [allgood,is_CTM_flw,is_CTM_density]=check(obj,X)
            
            net = obj.Net;
            eps = 0.001;
            K = size(X,2);
            
            is_CTM_flw = true(2,K);
            is_CTM_density = true(2,K+1);
            for k = 1:K
                
                nk = X.n(:,k);
                dk = net.demand_for_time_step(k);
                uk = X.u(:,k);
                [~,fk] = obj.compute_flow(nk,lk,dk,uk);
                is_CTM_flw(:,k) = abs( fk - X.f(:,k) ) <= eps;
            end
            
            is_CTM_density(1,:) = X.n(1,:)>=-eps & X.n(1,:)>=0 <= net.n1_jam+eps;
            is_CTM_density(2,:) = X.n(2,:)>=-eps & X.n(2,:)>=0 <= net.n2_jam+eps;
            
            allgood = all(all([is_CTM_flw is_CTM_density]));
        end
        
        function [X]=run_no_control(obj,x0,K)
            X = obj.run_with_controller(ControllerNoControl,x0,K);
        end
        
        function [X]=run_with_controller(obj,C,x0,K)
            X = Trajectory(x0,K);            
            for k = 1:K
                obj.one_step(k,X,C.get_control(k,X))
            end
        end
        
    end
    
    methods( Access = private )
        
        function [] = one_step(obj,k,X,uk)
            nk = X.n(:,k);
            [~,dml] = obj.Net.demand_for_time_step(k);
            X.u(:,k) = uk;
            [rk,fk] = obj.compute_flow(nk,uk);
            nkp = obj.compute_density(nk,fk,rk,dml);
            X.n(:,k+1) = nkp;
        end
        
        function [rk,fk,sk] = compute_flow(obj,nk,uk)
            
            net = obj.Net;
            rk = nan(2,1);
            fk = nan(2,1);
            sk = nan(2,1);
                        
            % onramp flow
            rk(1) = min([ net.xi1 * ( net.n1_jam - nk(1) ) ; net.r1_bar ; uk(1) ]);
            rk(2) = min([ net.xi2 * ( net.n2_jam - nk(2) ) ; net.r2_bar ; uk(2) ]);
            
            % mainline flow
            fk(1) = min([ net.beta1_bar * net.v1 * ( nk(1) + net.Gamma * rk(1)) ; ...
                          net.w2 * ( net.n2_jam - nk(2) - net.Gamma * rk(2) ) ; ...
                          net.f1_bar ]);
            
            fk(2) = min([ net.v2 * ( nk(2) + net.Gamma * rk(2) ) ; ...
                          net.f2_bar ]);
            
            % offramp flow
            sk(1) = ( net.beta1 / net.beta1_bar ) * fk(1);
            
        end
        
        function [nkp] = compute_density(obj,nk,fk,rk,dml)
            
            % mainline conservation
            nkp(1) = nk(1) + dml + rk(1) - fk(1)/obj.Net.beta1_bar;
            nkp(2) = nk(2) + fk(1) + rk(2) - fk(2);
            
        end
        
    end
end