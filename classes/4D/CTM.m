classdef CTM < handle
    
    properties
        Net
        Stngs
    end
    
    methods( Access = public )
        
        function [obj] = CTM(net,stngs)
            obj.Net = net;
            obj.Stngs = stngs;
        end
        
        % X is a Trajectory
        function [allgood,is_CTM_flw,is_CTM_density]=check(obj,X)
            
            net = obj.Net;
            eps = 0.001;
            
            is_CTM_flw = true(2,obj.Stngs.K);
            is_CTM_density = true(2,obj.Stngs.K+1);
            for k = 1:obj.Stngs.K
                
                nk = X.n(:,k);
                lk = X.l(:,k);
                dk = net.demand_for_time_step(k);
                uk = X.u(:,k);
                [~,fk] = obj.compute_flow(nk,lk,dk,uk);
                is_CTM_flw(:,k) = abs( fk - X.f(:,k) ) <= eps;
            end
            
            is_CTM_density(1,:) = X.n(1,:)>=-eps & X.n(1,:)>=0 <= net.n1_jam+eps;
            is_CTM_density(2,:) = X.n(2,:)>=-eps & X.n(2,:)>=0 <= net.n2_jam+eps;
            
            allgood = all(all([is_CTM_flw is_CTM_density]));
        end
        
        function [X]=run_no_control(obj)
            X = obj.run_with_controller(ControllerNoControl);
        end
        
        function [X]=run_with_controller(obj,C)
            net = obj.Net;
            K = obj.Stngs.K;
            X = Trajectory(obj.Stngs,net.n0,net.l0);            
            for k = 1:K
                obj.one_step(k,X,C.get_control(k,X))
            end
            X.evaluate_cost;
        end
        
    end
    
    methods( Access = private )
        
        function [] = one_step(obj,k,X,uk)
            nk = X.n(:,k);
            lk = X.l(:,k);
            dk = obj.Net.demand_for_time_step(k);
            X.u(:,k) = uk;
            [rk,fk] = obj.compute_flow(nk,lk,dk,uk);
            [nkp,lkp] = obj.compute_density(nk,lk,fk,rk,dk);
            X.n(:,k+1) = nkp;
            X.l(:,k+1) = lkp;
        end
        
        function [rk,fk,sk] = compute_flow(obj,nk,lk,dk,uk)
            
            net = obj.Net;
            rk = nan(2,1);
            fk = nan(2,1);
            sk = nan(2,1);
                        
            % onramp flow
            rk(1) = min([ lk(1) + dk(2) ; net.xi1 * ( net.n1_jam - nk(1) ) ; net.r1_bar ; uk(1) ]);
            rk(2) = min([ lk(2) + dk(3) ; net.xi2 * ( net.n2_jam - nk(2) ) ; net.r2_bar ; uk(2) ]);
            
            % mainline flow
            fk(1) = min([ net.beta1_bar * net.v1 * ( nk(1) + net.Gamma * rk(1)) ; ...
                          net.w2 * ( net.n2_jam - nk(2) - net.Gamma * rk(2) ) ; ...
                          net.f1_bar ]);
            
            fk(2) = min([ net.beta2_bar * net.v2 * ( nk(2) + net.Gamma * rk(2) ) ; ...
                          net.f2_bar ]);
            
            % offramp flow
            sk(1) = ( net.beta1 / net.beta1_bar ) * fk(1);
            sk(2) = ( net.beta2 / net.beta2_bar ) * fk(2);
            
        end
        
        function [nkp,lkp] = compute_density(obj,nk,lk,fk,rk,dk)
            
            % mainline conservation
            nkp(1) = nk(1) + dk(1) + rk(1) - fk(1)/obj.Net.beta1_bar;
            nkp(2) = nk(2) + fk(1) + rk(2) - fk(2)/obj.Net.beta2_bar;
            
            lkp(1) = lk(1) + dk(2) - rk(1);
            lkp(2) = lk(2) + dk(3) - rk(2);
            
        end
        
    end
end