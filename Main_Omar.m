clearvars;
cd('C:\Users\moissene\Documents\Professionnel\publications\articles\1- en cours\Galarraga - 2021\Data\');

load('Static.mat');
for i = 1:5
    Segment(i).Q   = Static(1).Segment(i).Q.smooth;
    Segment(i).rM  = Static(1).Segment(i).rM.smooth;
    Segment(i).rM0 = Static(1).Segment(i).rM.smooth; % Store as initial posture before correction
end
j = 6;
for i = 9:-1:7    
    Segment(j).Q          = Static(1).Segment(i).Q.smooth;
    Segment(j).Q(4:6,:,:) = Static(1).Segment(i).Q.smooth(7:9,:,:); % Exchange rP and rD to get a continuous kinematic chain from right foot to left foot
    Segment(j).Q(7:9,:,:) = Static(1).Segment(i).Q.smooth(4:6,:,:);
    Segment(j).rM         = Static(1).Segment(i).rM.smooth;
    Segment(j).rM0        = Static(1).Segment(i).rM.smooth; % Store as initial posture before correction
    j                     = j+1;
end
n = size(Segment(2).rM,3);
Joint(1).Kk = [];

% -------------------------------------------------------------------------
% Model parameters
% -------------------------------------------------------------------------

% Initialisation
Segment(1).L = NaN; % No value for segment 1 (Forceplate)
Segment(1).alpha = NaN; % No value for segment 1 (Forceplate)
Segment(1).beta = NaN; % No value for segment 1 (Forceplate)
Segment(1).gamma = NaN; % No value for segment 1 (Forceplate)

% Mean segment geometry and markers coordinates
for i = 2:5 % From i = 2 (Foot) to i = 5 (Pelvis)
    
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

% -------------------------------------------------------------------------
% Joint parameters and initial guess
% -------------------------------------------------------------------------

% Initial guess for Lagrange multipliers
lambdakA = zeros(3,1,n);
lambdakK = zeros(3,1,n);

% Hip virtual marker mean coordinates (rV1 = rP4)
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
% Initial guess for Lagrange multipliers
lambdakH = zeros(3,1,n);

% -------------------------------------------------------------------------
% Run optimisation
% -------------------------------------------------------------------------

for i = 1:5
    Segment(i).Q   = Static(3).Segment(i).Q.smooth;
    Segment(i).rM  = Static(3).Segment(i).rM.smooth;
end
j = 6;
for i = 9:-1:7    
    Segment(j).Q          = Static(3).Segment(i).Q.smooth;
    Segment(j).Q(4:6,:,:) = Static(3).Segment(i).Q.smooth(7:9,:,:); % Exchange rP and rD to get a continuous kinematic chain from right foot to left foot
    Segment(j).Q(7:9,:,:) = Static(3).Segment(i).Q.smooth(4:6,:,:);
    Segment(j).rM         = Static(3).Segment(i).rM.smooth;
    j                     = j+1;
end
n = size(Segment(2).rM,3);
Joint(1).Kk = [];

% Initial guess for Lagrange multipliers
lambdar = zeros(24,1,n); % 4 segments x 6 constraints per segment

% Initial value of the objective function
F = 1;
% Iteration number
step = 0;

% -------------------------------------------------------------------------
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
    
    % Ankle
    % Vector of kinematic constraints
    % rD3 - rP2 = 0
    phikA = Segment(3).Q(7:9,1,:) - Segment(2).Q(4:6,1,:);
    % Jacobian of kinematic constraints
    KkA = zeros(3,4*12,n); % Initialisation
    KkA(1:3,4:6,:) = repmat(-eye(3),[1,1,n]);
    KkA(1:3,19:21,:) = repmat(eye(3),[1,1,n]);
    % Joint structure
    Joint(2).Kk = KkA;
    % Partial derivative of Jacobian * Lagrange multipliers
    dKlambdakAdQ = zeros(4*12,4*12,n);
            
    % Knee
    % Vector of kinematic constraints
    % rD4 - rP3 = 0
    phikK = Segment(4).Q(7:9,1,:) - Segment(3).Q(4:6,1,:);
    % Jacobian of kinematic constraints
    KkK = zeros(3,4*12,n); % Initialisation
    KkK(1:3,16:18,:) = repmat(-eye(3),[1,1,n]);
    KkK(1:3,31:33,:) = repmat(eye(3),[1,1,n]);
    % Joint structure
    Joint(3).Kk = KkK;
    % Partial derivative of Jacobian * Lagrange multipliers
    dKlambdakKdQ = zeros(4*12,4*12,n);
    
    % Hip
    % Vector of kinematic constraints
    % rV15 - rP4 = 0
    phikH = Mprod_array3(repmat(NV15,[1,1,n]),Segment(5).Q) - ...
        Segment(4).Q(4:6,1,:);
    % Jacobian of kinematic constraints
    KkH = zeros(3,4*12,n); % Initialisation
    KkH(1:3,28:30,:) = repmat(-eye(3),[1,1,n]);
    KkH(1:3,37:48,:) = repmat(NV15,[1,1,n]);
    % Joint structure
    Joint(4).Kk = KkH;
    % Partial derivative of Jacobian * Lagrange multipliers
    dKlambdakHdQ = zeros(4*12,4*12,n); % Initialisation
    
   % Assembly
    phik = [phikA;phikK;phikH];
    Kk = [KkA;KkK;KkH];
    lambdak = [lambdakA;lambdakK;lambdakH];
    dKlambdakdQ = dKlambdakAdQ + dKlambdakKdQ + dKlambdakHdQ;
    
    
    % ---------------------------------------------------------------------
    % Rigid body constraints and driving constraints
    for i = 2:5 % From i = 2 (Foot) to i = 5 (Pelvis)
                
        % Vector of rigid body constraints
        phiri = zeros(6,1,n);       
        % Jacobian of rigid body constraints
        Kri = zeros(6,4*12,n);
        % Segment structure
        Segment(i).Kr = Kri;        
        % Partial derivative of Jacobian * Lagrange multipliers
        dKlambdaridQ = zeros(12,4*12,n);
        
        % Vector and Jacobian of driving constraints
        Kmi = zeros(size(Segment(i).rM,2)*3,4*12,n); % Initialisation
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
    
    
    % ---------------------------------------------------------------------
    % Solution
    
    % Compute dX
    % dX = inv(-dF/dx)*F(X)
    % F(X) = [Km'*phim + [Kk;Kr]'*[lambdak;lambdar];[phik;phir]]
    % X = [Q;[lambdak;lambdar]]
    F = [Mprod_array3(permute(Km,[2,1,3]),phim) + ...
        Mprod_array3(permute([Kk],[2,1,3]), [lambdak]); ...
        [phik]]; % with transpose = permute( ,[2,1,3])
    dKlambdadQ = dKlambdakdQ;
    dFdX = [Mprod_array3(permute(Km,[2,1,3]),Km) + ...
        dKlambdadQ, permute([Kk],[2,1,3]); ...
        [Kk],zeros(size([Kk],1),size([Kk],1),n)];
    dX = Mprod_array3(Minv_array3(-dFdX),F);
    
    
    % ---------------------------------------------------------------------
    % Extraction from X
    Segment(2).Q = Segment(2).Q + dX(1:12,1,:);
    Segment(3).Q = Segment(3).Q + dX(13:24,1,:);
    Segment(4).Q = Segment(4).Q + dX(25:36,1,:);
    Segment(5).Q = Segment(5).Q + dX(37:48,1,:);
    
    lambdakA = lambdakA + dX(49:51,1,:);
    lambdakK = lambdakK + dX(52:54,1,:);
    lambdakH = lambdakH + dX(55:57,1,:);
%     lambdar = lambdar + dX(58:81,1,:);
    
end

figure;
hold on;
axis equal;
for i = 2:5
    for j = 1:size(Segment(i).rM,2)
        NMij = [Segment(i).nM(1,j)*eye(3),...
            (1 + Segment(i).nM(2,j))*eye(3), ...
            - Segment(i).nM(2,j)*eye(3), ...
            Segment(i).nM(3,j)*eye(3)];
        Segment(i).rM2(:,j) = Mprod_array3(repmat(NMij,[1,1,n]),Segment(i).Q);
        plot3(Segment(i).rM0(1,j),Segment(i).rM0(2,j),Segment(i).rM0(3,j),...
              'Marker','o','Color','black');
        plot3(Segment(i).rM(1,j),Segment(i).rM(2,j),Segment(i).rM(3,j),...
              'Marker','o','Color','red');
        plot3(Segment(i).rM2(1,j),Segment(i).rM2(2,j),Segment(i).rM2(3,j),...
              'Marker','x','Color','blue');
          
        error(:,j,i) = Segment(i).rM2(:,j)-Segment(i).rM(:,j);
    end
end
