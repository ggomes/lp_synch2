classdef LP < handle
    
    properties
        
        % setup
        Net
        Stngs
        ic_given_or_set
        
        % lp
        
        % sdvar
        cost
        cnst
        n
        f
        l
        r
        
        X           % class Trajectory
        
    end
    
    methods( Access = public )
        
        function [obj] = LP(net,stngs,ic_given_or_set)
            obj.Net = net;
            obj.Stngs = stngs;
            obj.ic_given_or_set = ic_given_or_set;
            [obj.X,obj.n,obj.f,obj.l,obj.r,obj.cost,obj.cnst] = obj.buildLp();
        end
        
        function [obj] = solve(obj)
            diag = solvesdp(obj.cnst,obj.cost);
            obj.X = Trajectory(obj.Stngs);
            if diag.problem ~= 0
                error('The problem is infeasible')
            else
                obj.X.n = double(obj.n);
                obj.X.f = double(obj.f);
                obj.X.l = double(obj.l);
                obj.X.r = double(obj.r);
                obj.X.u = obj.X.r;
                obj.X.evaluate_cost;
            end
        end

    end
    
    methods( Access = private )
        
        function [X,n,f,l,r,cost,cnst] = buildLp(obj)

            net = obj.Net;
            K = obj.Stngs.K;
            etha = obj.Stngs.etha;
            
            % variables
            n = sdpvar(2,K+1);
            f = sdpvar(2,K);
            l = sdpvar(2,K+1);
            r = sdpvar(2,K);
            
            X = Trajectory(obj.Stngs,net.n0,net.l0);
            
            % cost
            cost = sum(sum(n + l)) - etha * (sum(sum(r + f)));
            
            cnst = [];
            
            % mainline initial condition
            if strcmp(obj.ic_given_or_set,'ic_given')
                cnst = [cnst, n(:,1) == net.n0];
            elseif strcmp(obj.ic_given_or_set,'ic_in_set')
                cnst = [cnst, 0 <= n(1,1) <= net.n1_jam , ...
                              0 <= n(2,1) <= net.n2_jam ];
            end;
            
            % onramp initial condition
            cnst = [cnst, l(:,1) == net.l0 ];
            
            % mainline capacity
            cnst = [cnst, f(1,:) <= net.f1_bar];
            cnst = [cnst, f(2,:) <= net.f2_bar];
            
            % onramp capacity
            cnst = [cnst, 0 <= r(1,:) <= net.r1_bar];
            cnst = [cnst, 0 <= r(2,:) <= net.r2_bar];
            
            for k = 1:K
                
                % get demand
                dk = net.demand_for_time_step(k);
                
                % mainline conservation
                cnst = [cnst, ...
                    n(1,k+1) == n(1,k) - (net.beta1_bar^-1)*f(1,k) + dk(1) + r(1,k) ];
                
                cnst = [cnst, ...
                    n(2,k+1) == n(2,k) - (net.beta2_bar^-1)*f(2,k) + f(1,k) + r(2,k) ];
                
                % onramp conservation
                cnst = [cnst, l(:,k+1) == l(:,k) - r(:,k) + dk(2:3)];
                
                % mainline freeflow
                cnst = [cnst, ...
                    f(1,k) <= net.beta1_bar * net.v1 * n(1,k) ...
                            + net.beta1_bar * net.v1 * net.Gamma * r(1,k) ];
                
                cnst = [cnst, ...
                    f(2,k) <= net.beta2_bar * net.v2 * n(2,k) ...
                            + net.beta2_bar * net.v2 * net.Gamma * r(2,k) ];
                    
                % mainline congestion
                cnst = [cnst, ...
                    f(1,k) <= net.w2 * net.n2_jam ...
                            - net.w2 * n(2,k) ...
                            - net.w2 * net.Gamma * r(2,k) ];
                
                % onramp freeflow
                cnst = [cnst, r(:,k) <= net.v_ramp * ( dk(2:3) + l(:,k) ) ];
                
                % onramp congestion
                cnst = [cnst, r(1,k) <= net.xi1 * ( net.n1_jam - n(1,k) ) ];
                cnst = [cnst, r(2,k) <= net.xi2 * ( net.n2_jam - n(2,k) ) ];
                
            end
            
        end
        
    end
    
end

