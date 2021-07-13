% Author       : Omar Galarraga
%                Florent Moissenet
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : https://github.com/fmoissenet/NSLBP-BIOToolbox
% Reference    : To be defined
% Date         : July 2020
% -------------------------------------------------------------------------
% Description  : To be defined
% -------------------------------------------------------------------------
% Dependencies : To be defined
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function Segment = Multibody_Optimisation_SSS_Static(Segment)

% Number of frames
n = size(Segment(2).rM,3);
% Initialisation
Joint(1).Kk = [];
% Test if local marker position already defined
test = Segment(2);

if ~isfield(test,'nM')

    %% --------------------------------------------------------------------
    % Model parameters
    % ---------------------------------------------------------------------

    % Initialisation
    Segment(1).L = NaN; % No value for segment 1 (Forceplate)
    Segment(1).alpha = NaN; % No value for segment 1 (Forceplate)
    Segment(1).beta = NaN; % No value for segment 1 (Forceplate)
    Segment(1).gamma = NaN; % No value for segment 1 (Forceplate)

    % Mean segment geometry and markers coordinates
    for i = 2:8 % From i = 2 (Right foot) to i = 8 (Left foot)

        % Segment length
        Segment(i).L = mean(sqrt(sum((Segment(i).Q(4:6,1,:) - ...
            Segment(i).Q(7:9,1,:)).^2)),3);

        % Alpha angle between (rP - rD) and w
        Segment(i).alpha = mean(acosd(dot(Segment(i).Q(4:6,1,:) - ...
            Segment(i).Q(7:9,1,:), Segment(i).Q(10:12,1,:))./...
            sqrt(sum((Segment(i).Q(4:6,1,:) - ...
            Segment(i).Q(7:9,1,:)).^2))),3);

        % Beta angle between u and w
        Segment(i).beta = mean(acosd(dot(Segment(i).Q(10:12,1,:), ...
            Segment(i).Q(1:3,1,:))),3);

        % Gamma angle between u and (rP - rD)
        Segment(i).gamma = mean(acosd(dot(Segment(i).Q(1:3,1,:), ...
            Segment(i).Q(4:6,1,:) - Segment(i).Q(7:9,1,:))./...
            sqrt(sum((Segment(i).Q(4:6,1,:) - ...
            Segment(i).Q(7:9,1,:)).^2))),3);

        % Matrix B from SCS to NSCS (matrix Buv)
        Segment(i).B = [1, ...
            Segment(i).L*cosd(Segment(i).gamma), ...
            cosd(Segment(i).beta); ...
            0, ...
            Segment(i).L*sind(Segment(i).gamma), ...
            (cosd(Segment(i).alpha) - cosd(Segment(i).beta)*cosd(Segment(i).gamma))/sind(Segment(i).gamma); ...
            0, ...
            0, ...
            sqrt(1 - cosd(Segment(i).beta)^2 - ((cosd(Segment(i).alpha) - cosd(Segment(i).beta)*cosd(Segment(i).gamma))/sind(Segment(i).gamma))^2)];

        % Mean coordinates of markers in (u, rP-rD, w)
        for j = 1:size(Segment(i).rM,2)
            % Projection in a non orthonormal coordinate system
            Segment(i).nM(:,j) = mean(Vnop_array3(...
                Segment(i).rM(:,j,:) - Segment(i).Q(4:6,1,:),...
                Segment(i).Q(1:3,1,:),...
                Segment(i).Q(4:6,1,:) - Segment(i).Q(7:9,1,:),...
                Segment(i).Q(10:12,1,:)),3);
        end

    end

end

if isfield(test,'nM')

    %% --------------------------------------------------------------------
    % Joint parameters and initial guess
    % ---------------------------------------------------------------------

    % Initial guess for Lagrange multipliers
    lambdakRA = zeros(3,1,n);
    lambdakRK = zeros(3,1,n);
    lambdakRH = zeros(3,1,n);
    lambdakLH = zeros(3,1,n);
    lambdakLK = zeros(3,1,n);
    lambdakLA = zeros(3,1,n);

    % Right hip virtual marker mean coordinates (rV1 = rP4)
    % Expressed in  in (u5, rP5-rD5, w5)
    Segment(5).nV(:,1) = mean(Vnop_array3(...
        Segment(4).Q(4:6,1,:) - Segment(5).Q(4:6,1,:),...
        Segment(5).Q(1:3,1,:),...
        Segment(5).Q(4:6,1,:) - Segment(5).Q(7:9,1,:),...
        Segment(5).Q(10:12,1,:)),3);
    % Interpolation matrices
    NV15 = [Segment(5).nV(1,1)*eye(3),...
        (1 + Segment(5).nV(2,1))*eye(3), ...
        - Segment(5).nV(2,1)*eye(3), ...
        Segment(5).nV(3,1)*eye(3)];

    % Left hip virtual marker mean coordinates (rV2 = rD6)
    % Expressed in  in (u5, rP5-rD5, w5)
    Segment(5).nV(:,2) = mean(Vnop_array3(...
        Segment(6).Q(7:9,1,:) - Segment(5).Q(4:6,1,:),...
        Segment(5).Q(1:3,1,:),...
        Segment(5).Q(4:6,1,:) - Segment(5).Q(7:9,1,:),...
        Segment(5).Q(10:12,1,:)),3);
    % Interpolation matrices
    NV25 = [Segment(5).nV(1,2)*eye(3),...
        (1 + Segment(5).nV(2,2))*eye(3), ...
        - Segment(5).nV(2,2)*eye(3), ...
        Segment(5).nV(3,2)*eye(3)];


    %% --------------------------------------------------------------------
    % Run optimisation
    % ---------------------------------------------------------------------

    % Initial guess for Lagrange multipliers
    lambdar = zeros(7*6,1,n); % 7 segments x 6 constraints per segment

    % Initial value of the objective function
    F = 1;
    % Iteration number
    step = 0;
    
    % Optimisation weights for marker trajectories
    temp = [];
    for i = 2:8
        temp = [temp,repmat(Segment(i).wM,[1,3])];
    end
    Wm = diag(temp);
    clear temp;

    % ---------------------------------------------------------------------
    % Newton-Raphson
    while max(permute(sqrt(sum(F.^2)),[3,2,1])) > 10e-12 && step < 20

        % Iteration number
        step = step + 1   % Display

        % Initialisation
        phik = []; % Vector of kinematic constraints
        Kk = [];  % Jacobian of kinematic constraints
        phir = []; % Vector of rigid body constraints
        Kr = []; % Jacobian of rigid body constraints
        dKlambdardQ = []; % Partial derivative of Jacobian * Lagrange multipliers
        phim = []; % Vector of driving constraints
        Km = []; % Jacobian of driving constraints

        % Right ankle
        % Vector of kinematic constraints
        % rD3 - rP2 = 0
        phikRA = Segment(3).Q(7:9,1,:) - Segment(2).Q(4:6,1,:);
        % Jacobian of kinematic constraints
        KkRA = zeros(3,7*12,n); % Initialisation
        KkRA(1:3,4:6,:) = repmat(-eye(3),[1,1,n]);
        KkRA(1:3,19:21,:) = repmat(eye(3),[1,1,n]);
        % Joint structure
        Joint(2).Kk = KkRA;
        % Partial derivative of Jacobian * Lagrange multipliers
        dKlambdakRAdQ = zeros(7*12,7*12,n);

        % Right knee
        % Vector of kinematic constraints
        % rD4 - rP3 = 0
        phikRK = Segment(4).Q(7:9,1,:) - Segment(3).Q(4:6,1,:);
        % Jacobian of kinematic constraints
        KkRK = zeros(3,7*12,n); % Initialisation
        KkRK(1:3,16:18,:) = repmat(-eye(3),[1,1,n]);
        KkRK(1:3,31:33,:) = repmat(eye(3),[1,1,n]);
        % Joint structure
        Joint(3).Kk = KkRK;
        % Partial derivative of Jacobian * Lagrange multipliers
        dKlambdakRKdQ = zeros(7*12,7*12,n);

        % Right hip
        % Vector of kinematic constraints
        % rV15 - rP4 = 0
        phikRH = Mprod_array3(repmat(NV15,[1,1,n]),Segment(5).Q) - ...
            Segment(4).Q(4:6,1,:);
        % Jacobian of kinematic constraints
        KkRH = zeros(3,7*12,n); % Initialisation
        KkRH(1:3,28:30,:) = repmat(-eye(3),[1,1,n]);
        KkRH(1:3,37:48,:) = repmat(NV15,[1,1,n]);
        % Joint structure
        Joint(4).Kk = KkRH;
        % Partial derivative of Jacobian * Lagrange multipliers
        dKlambdakRHdQ = zeros(7*12,7*12,n); % Initialisation

        % Left hip
        % Vector of kinematic constraints
        % rV15 - rD6 = 0
        phikLH = Mprod_array3(repmat(NV25,[1,1,n]),Segment(5).Q) - ...
            Segment(6).Q(7:9,1,:);
        % Jacobian of kinematic constraints
        KkLH = zeros(3,7*12,n); % Initialisation
        KkLH(1:3,43:45,:) = repmat(-eye(3),[1,1,n]);
        KkLH(1:3,37:48,:) = repmat(NV25,[1,1,n]);
        % Joint structure
        Joint(5).Kk = KkLH;
        % Partial derivative of Jacobian * Lagrange multipliers
        dKlambdakLHdQ = zeros(7*12,7*12,n); % Initialisation

        % Left knee
        % Vector of kinematic constraints
        % rP6 - rD7 = 0
        phikLK = Segment(6).Q(4:6,1,:) - Segment(7).Q(7:9,1,:);
        % Jacobian of kinematic constraints
        KkLK = zeros(3,7*12,n); % Initialisation
        KkLK(1:3,67:69,:) = repmat(-eye(3),[1,1,n]);
        KkLK(1:3,52:54,:) = repmat(eye(3),[1,1,n]);
        % Joint structure
        Joint(6).Kk = KkLK;
        % Partial derivative of Jacobian * Lagrange multipliers
        dKlambdakLKdQ = zeros(7*12,7*12,n);

        % Left ankle
        % Vector of kinematic constraints
        % rP7 - rD8 = 0
        phikLA = Segment(7).Q(4:6,1,:) - Segment(8).Q(7:9,1,:);
        % Jacobian of kinematic constraints
        KkLA = zeros(3,7*12,n); % Initialisation
        KkLA(1:3,79:81,:) = repmat(-eye(3),[1,1,n]);
        KkLA(1:3,64:66,:) = repmat(eye(3),[1,1,n]);
        % Joint structure
        Joint(7).Kk = KkLA;
        % Partial derivative of Jacobian * Lagrange multipliers
        dKlambdakLAdQ = zeros(7*12,7*12,n);

       % Assembly
        phik = [phikRA;phikRK;phikRH;...
                phikLH;phikLK;phikLA];
        Kk = [KkRA;KkRK;KkRH;...
              KkLH;KkLK;KkLA];
        lambdak = [lambdakRA;lambdakRK;lambdakRH;...
                   lambdakLH;lambdakLK;lambdakLA];
        dKlambdakdQ = dKlambdakRAdQ+dKlambdakRKdQ+dKlambdakRHdQ+...
                      dKlambdakLHdQ+dKlambdakLKdQ+dKlambdakLAdQ;


        % -----------------------------------------------------------------
        % Rigid body constraints and driving constraints
        for i = 2:8 % From i = 2 (Right foot) to i = 8 (Left foot)

            % Vector of rigid body constraints
            ui = Segment(i).Q(1:3,1,:);
            vi = Segment(i).Q(4:6,1,:) - Segment(i).Q(7:9,1,:);
            wi = Segment(i).Q(10:12,1,:);
            phiri = [dot(ui,ui) - ones(1,1,n);...
                dot(ui,vi) - repmat(Segment(i).L*cosd(Segment(i).gamma),[1,1,n]); ...
                dot(ui,wi) - repmat(cosd(Segment(i).beta),[1,1,n]); ...
                dot(vi,vi) - repmat(Segment(i).L^2,[1,1,n]);
                dot(vi,wi) - repmat(Segment(i).L*cosd(Segment(i).alpha),[1,1,n]);
                dot(wi,wi) - ones(1,1,n)];

            % Jacobian of rigid body constraints
            Kri = zeros(6,7*12,n); % Initialisation
            Kri(1:6,(i-2)*12+1:(i-2)*12+12,:) = permute(...
                [    2*ui,       vi,           wi,     zeros(3,1,n),zeros(3,1,n),zeros(3,1,n); ...
                zeros(3,1,n),    ui,      zeros(3,1,n),    2*vi,         wi,     zeros(3,1,n); ...
                zeros(3,1,n),   -ui,      zeros(3,1,n),   -2*vi,        -wi,     zeros(3,1,n); ...
                zeros(3,1,n),zeros(3,1,n),     ui,     zeros(3,1,n),     vi,         2*wi],[2,1,3]);
            % with transpose = permute( ,[2,1,3])
            % Segment structure
            Segment(i).Kr = Kri;

            % Partial derivative of Jacobian * Lagrange multipliers
            dKlambdaridQ = zeros(12,7*12,n); % Initialisation
            lambdari = lambdar((i-2)*6+1:(i-2)*6+6,1,:); % Extraction
            dKlambdaridQ(1:12,(i-2)*12+1:(i-2)*12+12,:) = ...
                [Mprod_array3(lambdari(1,1,:),repmat(2*eye(3),[1,1,n])), ...
                Mprod_array3(lambdari(2,1,:),repmat(eye(3),[1,1,n])), ...
                Mprod_array3(lambdari(2,1,:),repmat(-1*eye(3),[1,1,n])), ...
                Mprod_array3(lambdari(3,1,:),repmat(eye(3),[1,1,n])); ...
                Mprod_array3(lambdari(2,1,:),repmat(eye(3),[1,1,n])), ...
                Mprod_array3(lambdari(4,1,:),repmat(2*eye(3),[1,1,n])), ...
                Mprod_array3(lambdari(4,1,:),repmat(-2*eye(3),[1,1,n])), ...
                Mprod_array3(lambdari(5,1,:),repmat(eye(3),[1,1,n])); ...
                Mprod_array3(lambdari(2,1,:),repmat(-1*eye(3),[1,1,n])), ...
                Mprod_array3(lambdari(4,1,:),repmat(-2*eye(3),[1,1,n])), ...
                Mprod_array3(lambdari(4,1,:),repmat(2*eye(3),[1,1,n])), ...
                Mprod_array3(lambdari(5,1,:),repmat(-1*eye(3),[1,1,n])); ...
                Mprod_array3(lambdari(3,1,:),repmat(eye(3),[1,1,n])), ...
                Mprod_array3(lambdari(5,1,:),repmat(eye(3),[1,1,n])), ...
                Mprod_array3(lambdari(5,1,:),repmat(-1*eye(3),[1,1,n])), ...
                Mprod_array3(lambdari(6,1,:),repmat(2*eye(3),[1,1,n]))];

            % Vector and Jacobian of driving constraints
            Kmi = zeros(size(Segment(i).rM,2)*3,7*12,n); % Initialisation
            phimi = []; % Initialisation
            for j = 1:size(Segment(i).rM,2)
                % Interpolation matrix
                NMij = [Segment(i).nM(1,j)*eye(3),...
                    (1 + Segment(i).nM(2,j))*eye(3), ...
                    - Segment(i).nM(2,j)*eye(3), ...
                    Segment(i).nM(3,j)*eye(3)];
                % Vector of driving constraints
                phimi((j-1)*3+1:(j-1)*3+3,1,:) = Segment(i).rM(:,j,:) ...
                    - Mprod_array3(repmat(NMij,[1,1,n]),Segment(i).Q);
                % Jacobian of driving contraints
                Kmi((j-1)*3+1:(j-1)*3+3,(i-2)*12+1:(i-2)*12+12,:) = ...
                    repmat(-NMij,[1,1,n]);
            end

            % Assembly
            phir = [phir;phiri];
            Kr = [Kr;Kri];
            dKlambdardQ = [dKlambdardQ;dKlambdaridQ];
            phim = [phim;phimi];
            Km = [Km;Kmi];

        end

        % Display errors
        Mean_phik = mean(Mprod_array3(permute(phik,[2,1,3]),phik),3)
        Mean_phir = mean(Mprod_array3(permute(phir,[2,1,3]),phir),3)
        Mean_phim = mean(Mprod_array3(permute(phim,[2,1,3]),phim),3)


        % -----------------------------------------------------------------
        % Solution

        % Compute dX
        % dX = inv(-dF/dx)*F(X)
        % F(X) = [Km'*phim + [Kk;Kr]'*[lambdak;lambdar];[phik;phir]]
        % X = [Q;[lambdak;lambdar]]
        F = [Mprod_array3(permute(Km,[2,1,3]),Mprod_array3(Wm,phim)) + ...
            Mprod_array3(permute([Kk;Kr],[2,1,3]), [lambdak;lambdar]); ...
            [phik;phir]]; % with transpose = permute( ,[2,1,3])
        dKlambdadQ = dKlambdakdQ + dKlambdardQ;
        dFdX = [Mprod_array3(permute(Km,[2,1,3]),Mprod_array3(Wm,Km)) + ...
            dKlambdadQ, permute([Kk;Kr],[2,1,3]); ...
            [Kk;Kr],zeros(size([Kk;Kr],1),size([Kk;Kr],1),n)];
        dX = Mprod_array3(Minv_array3(-dFdX),F);


        % -----------------------------------------------------------------
        % Extraction from X
        Segment(2).Q = Segment(2).Q + dX(1:12,1,:);
        Segment(3).Q = Segment(3).Q + dX(13:24,1,:);
        Segment(4).Q = Segment(4).Q + dX(25:36,1,:);
        Segment(5).Q = Segment(5).Q + dX(37:48,1,:);
        Segment(6).Q = Segment(6).Q + dX(49:60,1,:);
        Segment(7).Q = Segment(7).Q + dX(61:72,1,:);
        Segment(8).Q = Segment(8).Q + dX(73:84,1,:);

        lambdakRA = lambdakRA + dX(85:87,1,:);
        lambdakRK = lambdakRK + dX(88:90,1,:);
        lambdakRH = lambdakRH + dX(91:93,1,:);
        lambdakLH = lambdakLH + dX(94:96,1,:);
        lambdakLK = lambdakLK + dX(97:99,1,:);
        lambdakLA = lambdakLK + dX(100:102,1,:);
        lambdar = lambdar + dX(103:144,1,:);

    end
    
end
