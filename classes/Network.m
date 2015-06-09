classdef Network < handle
    
    properties
        
        sim_dt          
        Kdem
        
        Gamma
        v_ramp
        n0
        l0
        beta1
        beta2
        d1
        d2
        d3
        beta1_bar
        beta2_bar
        xi1
        xi2
        v1
        v2
        w1
        w2
        n1_jam
        n2_jam
        l1_jam
        l2_jam
        f1_bar
        f2_bar
        r1_bar
        r2_bar
        n1_crit
        n2_crit

    end
    
    methods( Access = public ) 
        
        % load small network
        function [obj] = Network(stngs)
            
            obj.sim_dt = stngs.sim_dt;
            obj.Kdem = stngs.Kdem;
            
            obj.Gamma = 1;
            obj.v_ramp = 1;
            
            obj.n0 = [0;0];
            obj.l0 = [0;0];
            
            obj.beta1 = 0.2;
            obj.beta2 = 0;                      % no downstream offramp
            
            obj.d1 = 0*obj.sim_dt;
            obj.d2 = 2.0002;
            obj.d3 = 2.0002;
            
            obj.beta1_bar = 1-obj.beta1;
            obj.beta2_bar = 1-obj.beta2;
            
            obj.v1 = 0.24135 * obj.sim_dt;
            obj.v2 = 0.24135 * obj.sim_dt;
            
            obj.w1 = 0.06034 * obj.sim_dt;
            obj.w2 = 0.06034 * obj.sim_dt;
            
            obj.xi1 = 1-obj.w1;
            obj.xi2 = 1-obj.w2;
            
            obj.n1_jam = 11.51003;
            obj.n2_jam = 11.51003;
            
            obj.l1_jam = inf;
            obj.l2_jam = inf;
            
            obj.f1_bar = 1.2*0.5556 * obj.sim_dt;
            obj.f2_bar = 1.2*0.5556 * obj.sim_dt;
            
            obj.r1_bar = 0.4*0.5556 * obj.sim_dt;
            obj.r2_bar = 0.4*0.5556 * obj.sim_dt;
            
            obj.n1_crit = obj.f1_bar / obj.v1;
            obj.n2_crit = obj.f2_bar / obj.v2;
        end
        
        function [d]=demand_for_time_step(obj,k)
            if k > obj.Kdem
                d = zeros(3,1);
            else
                d = [obj.d1 obj.d2 obj.d3]';
            end
        end
        
    end
    
end

