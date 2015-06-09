classdef Stngs
    
    properties
        sim_dt
        Kdem
        Kcool 
        etha
        K
    end
    
    methods
        function [obj]=Stngs()
            obj.sim_dt = 3; 
            obj.Kdem = 20;
            obj.Kcool = 20;
            obj.etha = 0.1;
            obj.K = obj.Kdem + obj.Kcool;
        end
    end
    
end

