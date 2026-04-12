% Capacitated Minimum Dominating Set (CMDS) Optimization
% Requires: Optimization Toolbox (intlinprog)
		
clc; clear;
		
% 1. DEFINE DATASETS & PARAMETERS
		
C = 80; % Hardware Capacity Limit
		
		% Floor 1
		floors(1).name = 'Floor 1';
		floors(1).R = 4;
		floors(1).D = 6;
		floors(1).users = [16, 57, 14, 40, 30, 16];
		floors(1).A = [
		1, 1, 1, 1, 1, 1;
		1, 1, 1, 1, 1, 1;
		1, 1, 1, 1, 1, 1;
		1, 1, 1, 1, 1, 1
		];
		
		% Floor 2
		floors(2).name = 'Floor 2';
		floors(2).R = 5;
		floors(2).D = 12;
		floors(2).users = [18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 21]; 
		floors(2).A = [
		1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1;
		1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1;
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
		1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1;
		0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1
		];
		
		% Floor 3
		floors(3).name = 'Floor 3';
		floors(3).R = 6;
		floors(3).D = 10;
		floors(3).users = [16, 16, 16, 16, 16, 16, 16, 16, 16, 17]; 
		floors(3).A = [
		1, 1, 1, 1, 1, 1, 1, 0, 0, 0;
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
		1, 0, 1, 1, 1, 1, 1, 1, 1, 1;
		0, 0, 1, 1, 1, 1, 1, 1, 1, 1
		];
		
		% Floor 4
		floors(4).name = 'Floor 4';
		floors(4).R = 5;
		floors(4).D = 10;
		floors(4).users = [13, 13, 13, 13, 13, 13, 14, 14, 14, 15]; 
		floors(4).A = [
		1, 1, 1, 1, 1, 1, 1, 0, 0, 1;
		1, 1, 1, 1, 1, 1, 1, 0, 0, 1;
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1;
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1
		];
		
		% Floor 6
		floors(5).name = 'Floor 6';
		floors(5).R = 5;
		floors(5).D = 10;
		floors(5).users = [37, 37, 38, 38, 38, 38, 38, 38, 38, 38]; 
		floors(5).A = [
		1, 1, 1, 1, 1, 1, 1, 1, 0, 0;
		1, 1, 1, 1, 1, 1, 1, 1, 1, 0;
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
		0, 1, 1, 1, 1, 1, 1, 1, 1, 1;
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1
		];
		
		total_routers_system = 0;
		disp('Solving the CMDS Model via intlinprog...');
		disp(repmat('=', 1, 50));
		
% 2. BUILD AND SOLVE MATRICES FOR EACH FLOOR
		for k = 1:length(floors)
		R = floors(k).R;
		D = floors(k).D;
		A_mat = floors(k).A;
		users_array = floors(k).users; % Load the specific user array
		
		num_vars = R + (R * D);
		
% Objective: Minimize sum of x_i
		f = [ones(R, 1); zeros(R * D, 1)];
		
% EQUALITY CONSTRAINTS (Aeq * vars = beq)
		Aeq = zeros(D, num_vars);
		beq = ones(D, 1);
		
		for j = 1:D
		for i = 1:R
		y_idx = R + (i-1)*D + j;
		Aeq(j, y_idx) = 1;
		end
		end
		
% INEQUALITY CONSTRAINTS (A_ineq * vars <= b_ineq)
		num_ineq_rows = (R * D) + R;
		A_ineq = zeros(num_ineq_rows, num_vars);
		b_ineq = zeros(num_ineq_rows, 1);
		
		row = 1;
		
% Build Coverage Linking: y_ij - (A_ij * x_i) <= 0
		for i = 1:R
		for j = 1:D
		y_idx = R + (i-1)*D + j;
		A_ineq(row, i) = -A_mat(i, j); % Coefficient for x_i
		A_ineq(row, y_idx) = 1;        % Coefficient for y_ij
		b_ineq(row) = 0;
		row = row + 1;
		end
		end
		
% Build Capacity Limits: sum(u_j * y_ij) - (C * x_i) <= 0
		for i = 1:R
		A_ineq(row, i) = -C; % Coefficient for x_i
		for j = 1:D
		y_idx = R + (i-1)*D + j;
		A_ineq(row, y_idx) = users_array(j); % Uses specific node capacity
		end
		b_ineq(row) = 0;
		row = row + 1;
		end
		
% BOUNDS AND VARIABLE TYPES
		intcon = 1:num_vars; 
		lb = zeros(num_vars, 1); 
		ub = ones(num_vars, 1);  
		
% EXECUTE SOLVER
		options = optimoptions('intlinprog', 'Display', 'off'); 
		
		[sol, fval, exitflag] = intlinprog(f, intcon, A_ineq, b_ineq, Aeq, beq, lb, ub, options);
		
		if exitflag > 0
		installed_idx = find(round(sol(1:R)) == 1); 
		num_installed = length(installed_idx);
		total_routers_system = total_routers_system + num_installed;
		
		router_strings = arrayfun(@(x) sprintf('R%d', x), installed_idx, 'UniformOutput', false);
		installed_str = strjoin(router_strings, ', ');
		
		fprintf('%s: Needs %d routers -> Install at: %s\n', floors(k).name, num_installed, installed_str);
		else
fprintf('%s: INFEASIBLE. Capacity limit too strict or nodes out of range.\n', floors(k).name);
end
end
		
disp(repmat('=', 1, 50));
fprintf('Total Minimum Routers Required for Entire Library: %d\n', total_routers_system);
disp(repmat('=', 1, 50));