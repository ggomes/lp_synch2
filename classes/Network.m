classdef Network < handle
    
    properties
        
        Kdem
        v_ramp
%         l1_jam
%         l2_jam
        
        Gamma
        beta1
        dml
        d1
        d2
        beta1_bar
        xi1
        xi2
        v1
        v2
        w2
        n1_jam
        n2_jam
        f1_bar
        f2_bar
        r1_bar
        r2_bar
        n1_crit
        n2_crit

    end
    
    methods( Access = public ) 
        
        % load small network
        function [obj] = Network(Kdem,beta,rbar)
            
            if(nargin<1)
                obj.Kdem = Inf;
            else
                obj.Kdem = Kdem;
            end
            
            if(nargin<2) 
                obj.beta1 = 0.05;
            else
                obj.beta1 = beta;
            end
            
            L = 0.5;                    % mile
            dt = 20/3600;                % hr
            
            obj.dml = 0 * dt;          % vph, normalized
            obj.d1 = 1.1 * rbar * dt;          % vph, normalized
            obj.d2 = 1.1 * rbar * dt;          % vph, normalized
            
            obj.v1 = 60 * dt / L;       % mph, normalized
            obj.v2 = 60 * dt / L;       % mph, normalized
            obj.w2 = 15 * dt / L;       % mph, normalized
            
            obj.f1_bar = 1800 * dt;     % vph, normalized
            obj.f2_bar = 1800 * dt;     % vph, normalized
            
            obj.r1_bar = rbar * dt;      % vph, normalized
            obj.r2_bar = rbar * dt;      % vph, normalized
            
            obj.xi1 = 1;
            obj.xi2 = 1-obj.w2;
            obj.beta1_bar = 1-obj.beta1;
            obj.Gamma = 0.5;
            obj.v_ramp = 1;
            
%             obj.l1_jam = inf;
%             obj.l2_jam = inf;

            if ~obj.check_CFL
                error('CFL condition violated')
            end
            
            if ~obj.check_high_demand
                error('Demand is not high')
            end
        end
        
        function [dor,dml]=demand_for_time_step(obj,k)
            if k > obj.Kdem
                dor = [0;0];
                dml = 0;
            else
                dor = [obj.d1;obj.d2];
                dml = obj.dml;
            end
        end
        
        function [dor,dml]=demand_for_time_up_to(obj,K)
            dor = [obj.d1;obj.d2]*ones(1,K);
            dml = obj.dml*ones(1,K);
            
            if(K>obj.Kdem)
                dor(:,obj.Kdem:end) = 0;
                dml(:,obj.Kdem:end) = 0;
            end
        end
        
        function [v1,v2,w2,nc1,nc2,nb1,nb2,F1,F2,bbar,rb1,rb2,dml,Gamma,xi1,xi2,vramp]=get_short_names(obj)
            v1 = obj.v1;
            v2 = obj.v2;
            w2 = obj.w2;
            nc1 = obj.f1_bar / obj.v1 / obj.beta1_bar;
            nc2 = obj.f2_bar / obj.v2;
            [nb1,nb2] = obj.get_n_jam();
            F1 = obj.f1_bar;
            F2 = obj.f2_bar;
            bbar = obj.beta1_bar;
            rb1 = obj.r1_bar;
            rb2 = obj.r2_bar;
            dml = obj.dml;
            Gamma = obj.Gamma;
            xi1 = obj.xi1;
            xi2 = obj.xi2;
            vramp = obj.v_ramp;
            
        end
        
        function [nb1,nb2] = get_n_jam(obj)
            nb2 = obj.f2_bar * ( 1/obj.v2 + 1/obj.w2 );
            nb1 = nb2;
        end
        
        function [n1ss,n2ss,r1ss,r2ss,f1ss,f2ss] = get_steady_state(obj)
            r1ss = obj.r1_bar;
            r2ss = obj.r2_bar;
            z1 = r1ss*(1-obj.v1*obj.Gamma);
            z2 = r2ss*(1-obj.v2*obj.Gamma);
            n1ss = ( z1 + obj.dml )/obj.v1;
            f1ss = obj.beta1_bar*obj.v1*(n1ss+obj.Gamma*r1ss);
            n2ss = ( z2 + f1ss ) / obj.v2;
            f2ss = f1ss + r2ss;
        end
            
        function [y]=check_CFL(obj)
            x=[obj.v1 obj.v2 obj.w2 obj.xi1 obj.xi2];
            y = all([x>0 x<=1]);
        end
        
        function [y]=check_high_demand(obj)
            y = obj.d1>=obj.r1_bar & obj.d2>=obj.r2_bar;
        end
          
    end
    
end

