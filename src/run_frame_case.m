function out = run_frame_case(I_factors, Fh_total, q_beam)

    %% GEOMETRY
    L = 5.0;
    H = 3.0;

    nodes = [ ...
        0 0;
        0 H;
        L H;
        L 0];

    nNodes = size(nodes,1);
    ndof = 3*nNodes;

    elems = [ ...
        1 2;
        2 3;
        4 3];

    nElem = size(elems,1);

    %% MATERIAL / SECTION
    E = [30e9; 30e9; 30e9];

    A = [ ...
        0.30*0.30;
        0.30*0.50;
        0.30*0.30];

    I0 = [ ...
        0.30*0.30^3/12;
        0.30*0.50^3/12;
        0.30*0.30^3/12];

    I = I0 .* I_factors(:);

    %% LOAD VECTOR
    F = zeros(ndof,1);
    F(3*2-2) = F(3*2-2) + Fh_total/2;
    F(3*3-2) = F(3*3-2) + Fh_total/2;

    %% GLOBAL MATRICES
    K = zeros(ndof,ndof);
    F_fixed_global = zeros(ndof,1);

    for e = 1:nElem

        n1 = elems(e,1);
        n2 = elems(e,2);

        x1 = nodes(n1,1); y1 = nodes(n1,2);
        x2 = nodes(n2,1); y2 = nodes(n2,2);

        Le = sqrt((x2-x1)^2 + (y2-y1)^2);
        c = (x2-x1)/Le;
        s = (y2-y1)/Le;

        k_local = frame2D_local_stiffness(E(e), A(e), I(e), Le);
        T = frame2D_transformation(c, s);
        k_global = T' * k_local * T;

        dofs = [3*n1-2,3*n1-1,3*n1,3*n2-2,3*n2-1,3*n2];
        K(dofs,dofs) = K(dofs,dofs) + k_global;

        if e == 2
            fe_local = uniform_load_local(q_beam, Le);
            fe_global = T' * fe_local;
            F_fixed_global(dofs) = F_fixed_global(dofs) + fe_global;
        end
    end

    F_total = F - F_fixed_global;

    %% BOUNDARY CONDITIONS
    fixed_dofs = [1 2 3 10 11 12];
    free_dofs = setdiff(1:ndof, fixed_dofs);

    %% SOLVE
    U = zeros(ndof,1);
    U(free_dofs) = K(free_dofs,free_dofs) \ F_total(free_dofs);

    %% MEMBER END FORCES
    member_end_forces_local = zeros(nElem,6);
    maxMomentOverall = -inf;

    for e = 1:nElem

        n1 = elems(e,1);
        n2 = elems(e,2);

        x1 = nodes(n1,1); y1 = nodes(n1,2);
        x2 = nodes(n2,1); y2 = nodes(n2,2);

        Le = sqrt((x2-x1)^2 + (y2-y1)^2);
        c = (x2-x1)/Le;
        s = (y2-y1)/Le;

        k_local = frame2D_local_stiffness(E(e), A(e), I(e), Le);
        T = frame2D_transformation(c, s);

        dofs = [3*n1-2,3*n1-1,3*n1,3*n2-2,3*n2-1,3*n2];
        u_elem_local = T * U(dofs);

        fe_local = zeros(6,1);
        if e == 2
            fe_local = uniform_load_local(q_beam, Le);
        end

        f_local = k_local*u_elem_local + fe_local;
        member_end_forces_local(e,:) = f_local.';

        x = linspace(0, Le, 100);
        V1 = f_local(2);
        M1 = f_local(3);

        if e == 2
            Mx = M1 + V1*x + 0.5*q_beam*x.^2;
        else
            Mx = M1 + V1*x;
        end

        maxMomentOverall = max(maxMomentOverall, max(abs(Mx)));
    end

    %% FEATURES
    maxUx = max(abs(U(1:3:end)));
    maxUy = max(abs(U(2:3:end)));

    umags = zeros(nNodes,1);
    for i = 1:nNodes
        ux = U(3*i-2);
        uy = U(3*i-1);
        umags(i) = sqrt(ux^2 + uy^2);
    end

    out.maxUx = maxUx;
    out.maxUy = maxUy;
    out.maxUmag = max(umags);
    out.maxMoment = maxMomentOverall;

    out.M_colL_bottom = member_end_forces_local(1,3);
    out.M_colL_top    = member_end_forces_local(1,6);

    out.M_beam_left   = member_end_forces_local(2,3);
    out.M_beam_right  = member_end_forces_local(2,6);

    out.M_colR_bottom = member_end_forces_local(3,3);
    out.M_colR_top    = member_end_forces_local(3,6);

end

function k = frame2D_local_stiffness(E,A,I,L)
    k = [ ...
        A*E/L,           0,             0,        -A*E/L,           0,             0;
        0,        12*E*I/L^3,    6*E*I/L^2,        0,       -12*E*I/L^3,    6*E*I/L^2;
        0,         6*E*I/L^2,     4*E*I/L,         0,        -6*E*I/L^2,     2*E*I/L;
       -A*E/L,           0,             0,         A*E/L,           0,             0;
        0,       -12*E*I/L^3,   -6*E*I/L^2,        0,        12*E*I/L^3,   -6*E*I/L^2;
        0,         6*E*I/L^2,     2*E*I/L,         0,        -6*E*I/L^2,     4*E*I/L];
end

function T = frame2D_transformation(c,s)
    T = [ ...
         c,  s, 0,  0, 0, 0;
        -s,  c, 0,  0, 0, 0;
         0,  0, 1,  0, 0, 0;
         0,  0, 0,  c, s, 0;
         0,  0, 0, -s, c, 0;
         0,  0, 0,  0, 0, 1];
end

function fe = uniform_load_local(q,L)
    fe = [0; q*L/2; q*L^2/12; 0; q*L/2; -q*L^2/12];
end
