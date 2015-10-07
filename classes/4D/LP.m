classdef LP < handle
    
    properties
        
        % setup
        Net
        ic_given
        n0
        l0
        
        % lp
        horizon
        etha
        
        % sdvar
        cost
        cnst
        n
        f
        l
        r
        
        X           % class Trajectory
        diag
        
    end
    
    methods( Access = public )
        
        function [obj] = LP(net,horizon,etha,n0,l0)
            obj.Net = net;
            obj.horizon = horizon;
            obj.etha = etha;
            obj.ic_given = nargin>3;
            if(obj.ic_given)
                obj.n0 = n0;
                obj.l0 = l0;
            end
            [obj.X,obj.n,obj.f,obj.l,obj.r,obj.cost,obj.cnst] = obj.buildLp();
        end
        
        function [obj] = solve(obj)
            ops = sdpsettings('solver','linprog');
            diagnosis = optimize(obj.cnst,obj.cost,ops);
            obj.X = Trajectory(obj.horizon);
            obj.diag = diagnosis;
            
            if diagnosis.problem == 0
                obj.X.n = double(obj.n);
                obj.X.f = double(obj.f);
                obj.X.l = double(obj.l);
                obj.X.r = double(obj.r);
                obj.X.u = obj.X.r;
                disp('Feasible')
            elseif diagnosis.problem == 1
                disp('Infeasible')
            else
                disp('Something else happened')
            end
            
        end
        
        function [X]=get_solution(obj)
            obj.X.evaluate_cost(obj.etha);
            X = obj.X;
        end

    end
    
    methods( Access = private )
        
        function [X,n,f,l,r,cost,cnst] = buildLp(obj)

            net = obj.Net;
            [v1,v2,w2,~,~,nb1,nb2,F1,F2,bbar,rb1,rb2,~,Gamma,xi1,xi2,vramp]=obj.Net.get_short_names;
            
            K = obj.horizon;
            
            % variables
            n = sdpvar(2,K+1);
            f = sdpvar(2,K);
            l = sdpvar(2,K+1);
            r = sdpvar(2,K);
            
            X = Trajectory(K);
            
            % cost
            cost = sum(sum(n + l)) - obj.etha * (sum(sum(r + f)));
            
            cnst = [];
            
            % initial condition
            if obj.ic_given
                cnst = [cnst, n(:,1) == obj.n0 ];
                cnst = [cnst, l(:,1) == obj.l0 ];
            else
                cnst = [cnst, 0 <= n(1,1) <= nb1 , ...
                    0 <= n(2,1) <= nb2 ];
                cnst = [cnst, l(:,1) == [0;0] ];
            end;
                        
            % mainline capacity
            cnst = [cnst, f(1,:) <= F1];
            cnst = [cnst, f(2,:) <= F2];
            
            % onramp capacity
            cnst = [cnst, 0 <= r(1,:) <= rb1];
            cnst = [cnst, 0 <= r(2,:) <= rb2];
            
            for k = 1:K
                
                % get demand
                [dor,dml] = net.demand_for_time_step(k);
                
                % mainline conservation
                cnst = [cnst, ...
                    n(1,k+1) == n(1,k) - (bbar^-1)*f(1,k) + dml + r(1,k) ];
                
                cnst = [cnst, ...
                    n(2,k+1) == n(2,k) - f(2,k) + f(1,k) + r(2,k) ];
                
                % onramp conservation
                cnst = [cnst, l(:,k+1) == l(:,k) - r(:,k) + dor];
                
                % mainline freeflow
                cnst = [cnst, ...
                    f(1,k) <= bbar * v1 * n(1,k) ...
                            + bbar * v1 * Gamma * r(1,k) ];
                
                cnst = [cnst, ...
                    f(2,k) <= v2 * n(2,k) ...
                            + v2 * Gamma * r(2,k) ];
                    
                % mainline congestion
                cnst = [cnst, ...
                    f(1,k) <= w2 * nb2 ...
                            - w2 * n(2,k) ...
                            - w2 * Gamma * r(2,k) ];
                
                % onramp freeflow
                cnst = [cnst, r(:,k) <= vramp * ( dor + l(:,k) ) ];
                
                % onramp congestion
                cnst = [cnst, r(1,k) <= xi1 * ( nb1 - n(1,k) ) ];
                cnst = [cnst, r(2,k) <= xi2 * ( nb2 - n(2,k) ) ];
                
            end
            
        end
        
    end
    
end

