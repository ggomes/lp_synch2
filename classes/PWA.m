classdef PWA < handle
    
    properties
        
        % setup
        net
        
        P
        sys
        pwa
        horizon
        mpc
        empc
        
    end
    
    methods ( Access = public )
        
        % constructor
        function [obj] = PWA(net,horizon,polyrep,rfact)
            obj.net = net;
            
            % check condition
            if abs(net.n2_jam - net.f1_bar / net.w2 - net.f2_bar / net.v2)>1e-5
                error('condition for 4 regions (instead of 6) is not met')
            end
            
            [v1,v2,w2,~,~,nb1,nb2,F1,F2,bbar,rb1,rb2,dml]=net.get_short_names;

            % I : FF1 | FF2
            sys1 = LTISystem( ...
                'A', [   1-v1    0 ; ...
                       v1*bbar  1-v2 ], ...
                'B', eye(2), ...
                'f', [ dml ; 0 ] );  
            
            % II : FF1 | CP2 
            sys2 = LTISystem( ...
                'A', [   1-v1   0 ; ...
                       v1*bbar  1 ], ...
                'B', eye(2), ...
                'f', [ dml ; -F2 ] );  
            
            % III : CP1 | FF2 
            sys3 = LTISystem( ...
                'A', [ 1   0 ; ...
                       0 1-v2], ...
                'B', eye(2), ...
                'f', [ -F1/bbar + dml ; F1 ] );  
            
            % IV : CG1 | CP2
            sys4 = LTISystem( ...
                'A', [ 1 w2/bbar ; 0 1-w2 ], ...
                'B', eye(2), ...
                'f', [dml-w2*nb2/bbar ; w2*nb2 - F2 ] );  

            % set regions
            obj.P = obj.get_poly(polyrep);
            sys1.setDomain('x',obj.P(1));
            sys2.setDomain('x',obj.P(2));
            sys3.setDomain('x',obj.P(3));
            sys4.setDomain('x',obj.P(4));
            
            % save to obj, create pwa object
            obj.sys = [sys1 sys2 sys3 sys4];
            obj.pwa = PWASystem(obj.sys);
            
            % add constraints
            obj.pwa.x.min = [0;0];
            obj.pwa.x.max = [nb1;nb2];
            obj.pwa.u.min = [0;0];
            obj.pwa.u.max = [rb1;rb2];

            % define online mpc controller
%             obj.pwa.x.with('terminalSet');
%             obj.pwa.x.terminalSet = obj.P(1);
            obj.horizon = horizon;
            obj.mpc = MPCController(obj.pwa, horizon);
            
            % Set panalties used in the cost function:
%             obj.mpc.model.x.penalty = OneNormFunction(eye(2));
            obj.mpc.model.u.penalty = OneNormFunction(-rfact*eye(2));
            
        end
        
        function [obj]=build_explicit(obj)            
            obj.empc = obj.mpc.toExplicit();            
        end
        
        function [C]=get_explicit_mpc_for_ic(x0)
            C = obj.empc.evaluate(x0);
        end
        
        function [C]=get_mpc_for_ic(x0)
            C = obj.mpc.evaluate(x0);
        end
        
        function [P] = get_poly(obj,polyrep)
            switch polyrep
                case 'H'
                    P = obj.get_poly_H;
                case 'V'
                    P = obj.get_poly_V;
                otherwise
                    error('bad parameter')
            end
        end
        
        function [f]=plot_P(obj)
            f=figure;
            plot(obj.P);
            view(90,-90)
            xlabel('n1')
            ylabel('n2')
            title('(f1,f2) regions')
        end
        
        function []=simulate(obj,runs)
            % runs is an array with fields x0 and u
            
            for i=1:length(runs)
                obj.pwa.initialize(runs(i).x0);
                Z(i) = obj.pwa.simulate(runs(i).u);
            end
            
            f=obj.plot_P;
            figure(f);
            hold on
            for i=1:length(Z)
                plot(Z(i).X(1,:),Z(i).X(2,:),'k','LineWidth',1)
                plot(Z(i).X(1,1),Z(i).X(2,1),'ko','MarkerSize',6)
                plot(Z(i).X(1,end),Z(i).X(2,end),'k.','MarkerSize',20)
            end
            
        end
        
        function [u1,u2,feasible,openloop]=evaluate_mpc_on_grid(obj,N1,N2)
            x1 = length(N1);
            x2 = length(N2);
            feasible = false(x1,x2);
            openloop = repmat(struct('cost',nan,'U',nan,'X',nan,'Y',nan),x1,x2);
            u1 = nan(x1,x2);
            u2 = nan(x1,x2);
            for i=1:length(N1)
                for j=1:length(N2)
                    disp([i j])
                    [U,f,o] = obj.mpc.evaluate([N1(i);N2(j)]);
                    feasible(i,j) = f;
                    openloop(i,j) = o;
                    u1(i,j) = U(1);
                    u2(i,j) = U(2);
                end
            end
        end

    end
    
    methods (Access = private)
        
        function [P] = get_poly_H(obj)
            
            [~,~,~,nc1,nc2,nb1,nb2] = obj.net.get_short_names;
            
            P(1) = Polyhedron( ...
                'A' , [-1 0;1 0;0 -1;0 1] , ...
                'b' , [0 nc1 0 nc2]' );
            
            P(2) = Polyhedron( ...
                'A' , [-1 0;0 -1;nb2-nc2 nc1] , ...
                'b' , [0 -nc2 nc1*nb2]' );
            
            P(3) = Polyhedron( ...
                'A' , [-1 0;1 0;0 -1;0 1] , ...
                'b' , [-nc1 nb1 0 nc2]' );
            
            P(4) = Polyhedron( ...
                'A' , [-nb2+nc2 -nc1;1 0;0 -1;0 1] , ...
                'b' , [-nc1*nb2 nb1 -nc2 nb2]' );
        end
        
        function [P] = get_poly_V(obj)
            
            [~,~,~,nc1,nc2,nb1,nb2] = obj.net.get_short_names;
            
            V1 = [0     0];
            V2 = [nc1   0];
            V3 = [nb1   0];
            V4 = [0     nc2];
            V5 = [nc1   nc2];
            V6 = [nb1   nc2];
            V7 = [0     nb2];
            V8 = [nb1   nb2];
            
            P(1) = Polyhedron('V',[V1;V2;V5;V4],'irredundantVRep',true);
            P(2) = Polyhedron('V',[V4;V5;V7],'irredundantVRep',true);
            P(3) = Polyhedron('V',[V2;V3;V6;V5],'irredundantVRep',true);
            P(4) = Polyhedron('V',[V5;V6;V8;V7],'irredundantVRep',true);
            
        end
        
        
    end
    
end

