%%%Generates 10 mm marker misplacements 

%function Trial = GenerateMarkerMisplacement(Session,Participant,Static,Trial)
addpath('./dependencies/Toolbox_Kinematics_Inverse_Dynamics')
addpath('./dependencies/btk')
%pathprin = 'C:\Users\Omar\Documents\StaticVariability\DataTest\';
pathprin = 'C:\Users\mordj\Documents\Projet_stage_UGECAM\Static-Marker-Variability\Static-Marker-Variability-dev_IK\Data_misplacement_10mm';
c3dbase=btkReadAcquisition([pathprin 'StaticOmar1.c3d']);

%Knee marker simulated misplacement
Markers=btkGetMarkersValues(c3dbase);
Markers=Markers*1e-3;
plot3(mean(Markers(:, 1:3:135)), mean(Markers(:,2:3:135)), mean(Markers(:, 3:3:135)), 'r');
hold on;
axis equal

M = btkGetMarkers(c3dbase);
FF = btkGetFirstFrame(c3dbase);
LF = btkGetLastFrame(c3dbase) - FF + 1;
%-------------------------------------------------------------------------
% Pelvis parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
RASI = permute(mean(M.RASI)*1e-3,[2,3,1]); 
RPSI = permute(mean(M.RPSI)*1e-3,[2,3,1]);
LPSI = permute(mean(M.LPSI)*1e-3,[2,3,1]);
LASI = permute(mean(M.LASI)*1e-3,[2,3,1]);
% Pelvis axes (Dumas and Wojtusch 2018)
Z5 = Vnorm_array3(RASI-LASI);
Y5 = Vnorm_array3(cross(RASI-(RPSI+LPSI)/2, ...
                        LASI-(RPSI+LPSI)/2));
X5 = Vnorm_array3(cross(Y5,Z5));
% Pelvis width
W5 = mean(sqrt(sum((RASI-LASI).^2)));
% Determination of the lumbar joint centre by regression (Dumas and Wojtusch 2018)
%if strcmp(Participant.gender,'Female')
%    LJC(1) = -34.0/100;
%    LJC(2) = 4.9/100;
%    LJC(3) = 0.0/100;
%elseif strcmp(Participant.gender,'Male')
    LJC(1) = -33.5/100;
    LJC(2) = -3.2/100;
    LJC(3) = 0.0/100;
%end
LJC = (RASI+LASI)/2 + ...
      LJC(1)*W5*X5 + LJC(2)*W5*Y5 + LJC(3)*W5*Z5;
% Determination of the hip joint centre by regression (Dumas and Wojtusch 2018)
%if strcmp(Participant.gender,'Female')
%    R_HJC(1) = -13.9/100;
%    R_HJC(2) = -33.6/100;
%    R_HJC(3) = 37.2/100;
%    L_HJC(1) = -13.9/100;
%    L_HJC(2) = -33.6/100;
%    L_HJC(3) = -37.2/100;
%elseif strcmp(Participant.gender,'Male')
    R_HJC(1) = -9.5/100;
    R_HJC(2) = -37.0/100;
    R_HJC(3) = 36.1/100;
    L_HJC(1) = -9.5/100;
    L_HJC(2) = -37.0/100;
    L_HJC(3) = -36.1/100;
%end
RHJC = (RASI+LASI)/2 + ...
       R_HJC(1)*W5*X5 + R_HJC(2)*W5*Y5 + R_HJC(3)*W5*Z5;
LHJC = (RASI+LASI)/2 + ...
       L_HJC(1)*W5*X5 + L_HJC(2)*W5*Y5 + L_HJC(3)*W5*Z5;

% Store segment coordinate system
midASIS = permute((RASI+LASI)/2,[3,1,2]); 
PELVIC_X = permute((RASI+LASI)/2+X5*10e-2,[3,1,2]);
PELVIC_Y = permute((RASI+LASI)/2+Y5*10e-2,[3,1,2]);
PELVIC_Z = permute((RASI+LASI)/2+Z5*10e-2,[3,1,2]); 

%% Pelvis Misplacents (RASI)
h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'RASI'));
%Markers2 = Markers;

%Misplacement in y
Markers2 = Markers;
dir=(PELVIC_Y- LJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), 'y');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RASIYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir=(LJC'-PELVIC_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '-y');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RASI-YMisplacement.c3d']);

%Misplacement in z
Markers2 = Markers;
dir=(PELVIC_Z- LJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RASIZMisplacement.c3d']);

%Misplacement in -z
Markers2 = Markers;
dir=(LJC'-PELVIC_Z);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RASI-ZMisplacement.c3d']);

%Misplacement in yz
Markers2=Markers;
dir=(PELVIC_Y- LJC')+(PELVIC_Z- LJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), 'xy');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RASIYZMisplacement.c3d']);

%Misplacement in -yz
Markers2=Markers;
dir=(LJC'-PELVIC_Y)+(LJC'-PELVIC_Z);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '-xy');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RASI-YZMisplacement.c3d']);


%% Pelvis Misplacents (LASI)
h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'LASI'));
Markers2 = Markers;

%Misplacement in y
Markers2 = Markers;
dir=(PELVIC_Y- LJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), 'y');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LASIYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir=(LJC'-PELVIC_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '-y');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LASI-YMisplacement.c3d']);

%Misplacement in z
Markers2 = Markers;
dir=(PELVIC_Z- LJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LASIZMisplacement.c3d']);

%Misplacement in -z
Markers2 = Markers;
dir=(LJC'-PELVIC_Z);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LASI-ZMisplacement.c3d']);

%Misplacement in yz
Markers2=Markers;
dir=(PELVIC_Y- LJC')+(PELVIC_Z- LJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LASIYZMisplacement.c3d']);

%Misplacement in -yz
Markers2=Markers;
dir=(LJC'-PELVIC_Y)+(LJC'-PELVIC_Z);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LASI-YZMisplacement.c3d']);

%% Pelvis Misplacents (RPSI)
h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'RPSI'));
Markers2 = Markers;

%Misplacement in y
Markers2 = Markers;
dir=(PELVIC_Y- LJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RPSIYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir=(LJC'-PELVIC_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RPSI-YMisplacement.c3d']);

%Misplacement in z
Markers2 = Markers;
dir=(PELVIC_Z- LJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RPSIZMisplacement.c3d']);

%Misplacement in -z
Markers2 = Markers;
dir=(LJC'-PELVIC_Z);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RPSI-ZMisplacement.c3d']);

%Misplacement in yz
Markers2=Markers;
dir=(PELVIC_Y- LJC')+(PELVIC_Z- LJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RPSIYZMisplacement.c3d']);

%Misplacement in -yz
Markers2=Markers;
dir=(LJC'-PELVIC_Y)+(LJC'-PELVIC_Z);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RPSI-YZMisplacement.c3d']);


%% Pelvis Misplacements (LPSI)
h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'LPSI'));
Markers2 = Markers;

%Misplacement in y
Markers2 = Markers;
dir=(PELVIC_Y- LJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LPSIYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir=(LJC'-PELVIC_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LPSI-YMisplacement.c3d']);

%Misplacement in z
Markers2 = Markers;
dir=(PELVIC_Z- LJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LPSIZMisplacement.c3d']);

%Misplacement in -z
Markers2 = Markers;
dir=(LJC'-PELVIC_Z);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LPSI-ZMisplacement.c3d']);

%Misplacement in yz
Markers2=Markers;
dir=(PELVIC_Y- LJC')+(PELVIC_Z- LJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LPSIYZMisplacement.c3d']);

%Misplacement in -yz
Markers2=Markers;
dir=(LJC'-PELVIC_Y)+(LJC'-PELVIC_Z);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LPSI-YZMisplacement.c3d']);




%% Right femur parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
%RGTR = permute(Trial.Marker(5).Trajectory.smooth,[2,3,1]);
RKNE = permute(mean(M.RKNE)*1e-3,[2,3,1]);
RKNM = permute(mean(M.RKNM)*1e-3,[2,3,1]);
RGTR = permute(mean(M.RGTR)*1e-3,[2,3,1]);
% Knee joint centre
RKJC = (RKNE+RKNM)/2;

% Femur axes (Dumas and Wojtusch 2018)
Y4 = Vnorm_array3(RHJC-RKJC);
X4 = Vnorm_array3(cross(RKNE-RHJC,RKJC-RHJC));
Z4 = Vnorm_array3(cross(X4,Y4));
% Store segment coordinate system
RFEMUR_X = permute(RHJC+X4*10e-2,[3,1,2]);
RFEMUR_Y = permute(RHJC+Y4*10e-2,[3,1,2]);
RFEMUR_Z = permute(RHJC+Z4*10e-2,[3,1,2]); 



%% Right Knee Misplacents (RKNE)
h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'RKNE'));
Markers2 = Markers;

%Misplacement in +x 
amp = 0.01; % 10 mm
dir = (RFEMUR_X - RHJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RKNEXMisplacement.c3d']); 

%Misplacement in -x
Markers2 = Markers;
dir = RHJC' - RFEMUR_X;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RKNE-XMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = RFEMUR_Y - RHJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RKNEYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = RHJC' - RFEMUR_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RKNE-YMisplacement.c3d']);

%Misplacement in xy
Markers2=Markers;
dir=(RFEMUR_X - RHJC')+(RFEMUR_Y - RHJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RKNEXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(RHJC' - RFEMUR_X)+(RHJC' - RFEMUR_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RKNE-XYMisplacement.c3d']);


%% Right Knee Misplacents (RGTR)
h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'RGTR'));
Markers2 = Markers;

%Misplacement in +x 
amp = 0.01; % 10 mm
dir = (RFEMUR_X - RHJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RGTRXMisplacement.c3d']); 

%Misplacement in -x
Markers2 = Markers;
dir = RHJC' - RFEMUR_X;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '+');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RGTR-XMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = RFEMUR_Y - RHJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RGTRYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = RHJC' - RFEMUR_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RGTR-YMisplacement.c3d']);

%Misplacement in xy
Markers2=Markers;
dir=(RFEMUR_X - RHJC')+(RFEMUR_Y - RHJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RGTRXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(RHJC' - RFEMUR_X)+(RHJC' - RFEMUR_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RGTR-XYMisplacement.c3d']);

%% Right Knee Misplacents (RKNM)
h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'RKNM'));
Markers2 = Markers;
%Misplacement in +x 
amp = 0.01; % 10 mm
dir = (RFEMUR_X - RHJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), 'x');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RKNMXMisplacement.c3d']); 

%Misplacement in -x
Markers2 = Markers;
dir = RHJC' - RFEMUR_X;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '+');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RKNM-XMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = RFEMUR_Y - RHJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RKNMYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = RHJC' - RFEMUR_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RKNM-YMisplacement.c3d']);


%Misplacement in xy
Markers2=Markers;
dir=(RFEMUR_X - RHJC')+(RFEMUR_Y - RHJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RKNMXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(RHJC' - RFEMUR_X)+(RHJC' - RFEMUR_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RKNM-XYMisplacement.c3d']);



%% Left femur parameters
% -------------------------------------------------------------------------
% Extract marker trajectories


LGTR = permute(mean(M.LGTR)*1e-3,[2,3,1]);
LKNE = permute(mean(M.LKNE)*1e-3,[2,3,1]);
LKNM = permute(mean(M.LKNM)*1e-3,[2,3,1]);

% Knee joint centre
LKJC = (LKNE+LKNM)/2;

% Femur axes (Dumas and Wojtusch 2018)
Y9 = Vnorm_array3(LHJC-LKJC);
X9 = -Vnorm_array3(cross(LKNE-LHJC,LKJC-LHJC));
Z9 = Vnorm_array3(cross(X9,Y9));
% Store segment coordinate system
LFEMUR_X = permute(LHJC+X9*10e-2,[3,1,2]);
LFEMUR_Y = permute(LHJC+Y9*10e-2,[3,1,2]);
LFEMUR_Z = permute(LHJC+Z9*10e-2,[3,1,2]);


%% Left Knee Misplacents (LGTR)
h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'LGTR'));
Markers2 = Markers;

%Misplacement in +x 
amp = 0.01; % 10 mm
dir = (LFEMUR_X - LHJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), 'x');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LGTRXMisplacement.c3d']); 

%Misplacement in -x
Markers2 = Markers;
dir = LHJC' - LFEMUR_X;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '+');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LGTR-XMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = LFEMUR_Y - LHJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LGTRYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = LHJC' - LFEMUR_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LGTR-YMisplacement.c3d']);

%Misplacement in xy
Markers2=Markers;
dir=(LFEMUR_X - LHJC')+(LFEMUR_Y - LHJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LGTRXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(LHJC' - LFEMUR_X)+(LHJC' - LFEMUR_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LGTR-XYMisplacement.c3d']);



%% Left Knee Misplacents (LKNE)
h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'LKNE'));
Markers2 = Markers;

%Misplacement in +x 
amp = 0.01; % 10 mm
dir = (LFEMUR_X - LHJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), 'x');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LKNEXMisplacement.c3d']); 

%Misplacement in -x
Markers2 = Markers;
dir = LHJC' - LFEMUR_X;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LKNE-XMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = LFEMUR_Y - LHJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LKNEYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = LHJC' - LFEMUR_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LKNE-YMisplacement.c3d']);

%Misplacement in xy
Markers2=Markers;
dir=(LFEMUR_X - LHJC')+(LFEMUR_Y - LHJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LKNEXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(LHJC' - LFEMUR_X)+(LHJC' - LFEMUR_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LKNE-XYMisplacement.c3d']);


%% Left Knee Misplacents (LKNM)
h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'LKNM'));
Markers2 = Markers;

%Misplacement in +x 
amp = 0.01; % 10 mm
dir = (LFEMUR_X - LHJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LKNMXMisplacement.c3d']); 

%Misplacement in -x
Markers2 = Markers;
dir = LHJC' - LFEMUR_X;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LKNM-XMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = LFEMUR_Y - LHJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LKNMYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = LHJC' - LFEMUR_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LKNM-YMisplacement.c3d']);

%Misplacement in xy
Markers2=Markers;
dir=(LFEMUR_X - LHJC')+(LFEMUR_Y - LHJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LKNMXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(LHJC' - LFEMUR_X)+(LHJC' - LFEMUR_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LKNM-XYMisplacement.c3d']);



%% Right Tibia/fibula parameters

% Extract marker trajectories
RFAX = permute(mean(M.RFAX)*1e-3,[2,3,1]);
RTTA = permute(mean(M.RTTA)*1e-3,[2,3,1]);
RANK = permute(mean(M.RANK)*1e-3,[2,3,1]);
RMED = permute(mean(M.RMED)*1e-3,[2,3,1]);

% Ankle joint centre
RAJC = (RANK+RMED)/2;

% Tibia/fibula axes (Dumas and Wojtusch 2018)
Y3 = Vnorm_array3(RKJC-RAJC);
if isempty(RFAX)
    X3 = Vnorm_array3(cross(RAJC-RKNE,RKJC-RKNE));
else
    X3 = Vnorm_array3(cross(RAJC-RFAX,RKJC-RFAX));
end
Z3 = Vnorm_array3(cross(X3,Y3));
% Store segment coordinate system
RTIBIA_X=permute(RKJC+X3*10e-2,[3,1,2]);
RTIBIA_Y=permute(RKJC+Y3*10e-2,[3,1,2]);
RTIBIA_Z=permute(RKJC+Z3*10e-2,[3,1,2]);


%% Right Ankle Misplacement (RFAX)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'RFAX'));
Markers2 = Markers;

%Misplacement in +x 
amp = 0.01; % 10 mm
dir = (RTIBIA_X- RKJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RFAXXMisplacement.c3d']); 

%Misplacement in -x
Markers2 = Markers;
dir = RKJC' - RTIBIA_X;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RFAX-XMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = RTIBIA_Y - RKJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RFAXYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = RKJC' - RTIBIA_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RFAX-YMisplacement.c3d']);

%Misplacement in xy
Markers2=Markers;
dir=(RTIBIA_X - RKJC')+(RTIBIA_Y - RKJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RFAXXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(RKJC' - RTIBIA_X)+(RKJC' - RTIBIA_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RFAX-XYMisplacement.c3d']);



%% Right Ankle Misplacement (RTTA)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'RTTA'));
Markers2 = Markers;

%Misplacement in +z 
amp = 0.01; % 10 mm
dir = (RTIBIA_Z - RKJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RTTAZMisplacement.c3d']); 

%Misplacement in -z
Markers2 = Markers;
dir = RKJC' - RTIBIA_Z;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RTTA-ZMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = RTIBIA_Y - RKJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RTTAYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = RKJC' - RTIBIA_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RTTA-YMisplacement.c3d']);

%Misplacement in yz
Markers2=Markers;
dir=(RTIBIA_Y - RKJC')+(RTIBIA_Z - RKJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RTTAYZMisplacement.c3d']);

%Misplacement in -yz
Markers2=Markers;
dir=(RKJC' - RTIBIA_Y)+(RKJC' - RTIBIA_Z);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RTTA-YZMisplacement.c3d']);




%% Right Ankle Misplacement (RANK)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'RANK'));
Markers2 = Markers;

%Misplacement in +x 
amp = 0.01; % 10 mm
dir = (RTIBIA_X - RKJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RANKXMisplacement.c3d']); 
%Misplacement in -x
Markers2 = Markers;
dir = RKJC' - RTIBIA_X;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RANK-XMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = RTIBIA_Y - RKJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RANKYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = RKJC' - RTIBIA_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RANK-YMisplacement.c3d']);


%Misplacement in xy
Markers2=Markers;
dir=(RTIBIA_X - RKJC')+(RTIBIA_Y - RKJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RANKXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(RKJC' - RTIBIA_X)+(RKJC' - RTIBIA_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RANK-XYMisplacement.c3d']);


%% Right Ankle Misplacement (RMED)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'RMED'));
Markers2 = Markers;

%Misplacement in +x
amp = 0.01; % 10 mm
dir = (RTIBIA_X - RKJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RMEDXMisplacement.c3d']); 

%Misplacement in -x
Markers2 = Markers;
dir = RKJC' - RTIBIA_X;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RMED-XMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = RTIBIA_Y - RKJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RMEDYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = RKJC' - RTIBIA_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RMED-YMisplacement.c3d']);

%Misplacement in xy
Markers2=Markers;
dir=(RTIBIA_X - RKJC')+(RTIBIA_Y - RKJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RMEDXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(RKJC' - RTIBIA_X)+(RKJC' - RTIBIA_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RMED-XYMisplacement.c3d']);



%% Left Tibia/fibula parameters

% Extract marker trajectories
LFAX = permute(mean(M.LFAX)*1e-3,[2,3,1]);
LTTA = permute(mean(M.LTTA)*1e-3,[2,3,1]);
LANK = permute(mean(M.LANK)*1e-3,[2,3,1]);
LMED = permute(mean(M.LMED)*1e-3,[2,3,1]);


% Ankle joint centre
LAJC = (LANK+LMED)/2;

% Tibia/fibula axes (Dumas and Wojtusch 2018)
Y8 = Vnorm_array3(LKJC-LAJC);
if isempty(LFAX)
    X8 = -Vnorm_array3(cross(LAJC-LKNE,LKJC-LKNE));
else
    X8 = -Vnorm_array3(cross(LAJC-LFAX,LKJC-LFAX));
end
Z8 = Vnorm_array3(cross(X8,Y8));
% Store segment coordinate system
LTIBIA_X=permute(RKJC+X3*10e-2,[3,1,2]);
LTIBIA_Y=permute(RKJC+Y3*10e-2,[3,1,2]);
LTIBIA_Z=permute(RKJC+Z3*10e-2,[3,1,2]);


%% Left Ankle Misplacement (LFAX)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'LFAX'));
Markers2 = Markers;

%Misplacement in +x 
amp = 0.01; % 10 mm
dir = (LTIBIA_X - LKJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LFAXXMisplacement.c3d']); 

%Misplacement in -x
Markers2 = Markers;
dir = LKJC' - LTIBIA_X;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LFAX-XMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = LTIBIA_Y - LKJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LFAXYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = LKJC' - LTIBIA_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LFAX-YMisplacement.c3d']);

%Misplacement in xy
Markers2=Markers;
dir=(LTIBIA_X - LKJC')+(LTIBIA_Y - LKJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LFAXXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(LKJC' - LTIBIA_X)+(LKJC' - LTIBIA_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LFAX-XYMisplacement.c3d']);




%% Left Ankle Misplacement (LTTA)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'LTTA'));
Markers2 = Markers;

%Misplacement in +z
amp = 0.01; % 10 mm
dir = (LTIBIA_Z - LKJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LTTAZMisplacement.c3d']); 

%Misplacement in -z
Markers2 = Markers;
dir = LKJC' - LTIBIA_Z;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LTTA-ZMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = LTIBIA_Y - LKJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LTTAYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = LKJC' - LTIBIA_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LTTA-YMisplacement.c3d']);

%Misplacement in yz
Markers2=Markers;
dir=(LTIBIA_Y - LKJC')+(LTIBIA_Z - LKJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LTTAYZMisplacement.c3d']);

%Misplacement in -yz
Markers2=Markers;
dir=(LKJC' - LTIBIA_Y)+(LKJC' - LTIBIA_Z);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LTTA-YZMisplacement.c3d']);


%% Left Ankle Misplacement (LANK)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'LANK'));
Markers2 = Markers;

%Misplacement in +x 
amp = 0.01; % 10 mm
dir = (LTIBIA_X - LKJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LANKXMisplacement.c3d']); 

%Misplacement in -x
Markers2 = Markers;
dir = LKJC' - LTIBIA_X;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LANK-XMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = LTIBIA_Y - LKJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LANKYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = LKJC' - LTIBIA_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LANK-YMisplacement.c3d']);

%Misplacement in xy
Markers2=Markers;
dir=(LTIBIA_X - LKJC')+(LTIBIA_Y - LKJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LANKXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(LKJC' - LTIBIA_X)+(LKJC' - LTIBIA_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LANK-XYMisplacement.c3d']);



%% Left Ankle Misplacement (LMED)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'LMED'));
Markers2 = Markers;

%Misplacement in +x
amp = 0.01; % 10 mm
dir = (LTIBIA_X - LKJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LMEDXMisplacement.c3d']); 

%Misplacement in -x
Markers2 = Markers;
dir = LKJC' - LTIBIA_X;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LMED-XMisplacement.c3d']); 

%Misplacement in y
Markers2 = Markers;
dir = LTIBIA_Y - LKJC';
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LMEDYMisplacement.c3d']);

%Misplacement in -y
Markers2 = Markers;
dir = LKJC' - LTIBIA_Y;
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LMED-YMisplacement.c3d']);

%Misplacement in xy
Markers2=Markers;
dir=(LTIBIA_X - LKJC')+(LTIBIA_Y - LKJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LMEDXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(LKJC' - LTIBIA_X)+(LKJC' - LTIBIA_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LMED-XYMisplacement.c3d']);



%% Right foot parameters

% Extract marker trajectories
RHEE = permute(mean(M.RHEE)*1e-3,[2,3,1]);
RFMH = permute(mean(M.RFMH)*1e-3,[2,3,1]);
RVMH = permute(mean(M.RVMH)*1e-3,[2,3,1]);


% Metatarsal joint centre (Dumas and Wojtusch 2018)
RMJC = (RFMH+RVMH)/2;

% Foot axes (Dumas and Wojtusch 2018)
X2 = Vnorm_array3(RMJC-RHEE);
Y2 = Vnorm_array3(cross(RVMH-RHEE,RFMH-RHEE));
Z2 = Vnorm_array3(cross(X2,Y2));

% Store segment coordinate system
RFOOT_X=permute(RAJC+X2*10e-2,[3,1,2]);
RFOOT_Y=permute(RAJC+Y2*10e-2,[3,1,2]);
RFOOT_Z=permute(RAJC+Z2*10e-2,[3,1,2]);


%% Right Metatarsal Misplacement (RHEE)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'RHEE'));
Markers2 = Markers;

%Misplacement in z 

amp = 0.01; % 10 mm
dir = (RFOOT_Z - RAJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RHEEZMisplacement.c3d']); 

%Misplacement in -z 

amp = 0.01; % 10 mm
dir = (RAJC' - RFOOT_Z);
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RHEE-ZMisplacement.c3d']); 


%Misplacement in y

amp = 0.01; % 10 mm
dir = (RFOOT_Y - RAJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RHEEYMisplacement.c3d']); 


%Misplacement in -y

amp = 0.01; % 10 mm
dir = (RAJC' - RFOOT_X);
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RHEE-YMisplacement.c3d']); 

%Misplacement in yz
Markers2=Markers;
dir=(RFOOT_Y - RAJC')+(RFOOT_Z - RAJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RHEEYZMisplacement.c3d']);

%Misplacement in -yz
Markers2=Markers;
dir=(RAJC' - RFOOT_Y)+(RAJC' - RFOOT_Z);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RHEE-YZMisplacement.c3d']);






%% Right Metatarsal Misplacement (RFMH)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'RFMH'));
Markers2 = Markers;

%Misplacement in y 

amp = 0.01; % 10 mm
dir = (RFOOT_Y- RAJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RFMHYMisplacement.c3d']); 

%Misplacement in -y

amp = 0.01; % 10 mm
dir = (RAJC' - RFOOT_Y);
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RFMH-YMisplacement.c3d']); 


%Misplacement in x

amp = 0.01; % 10 mm
dir = (RFOOT_X - RAJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RFMHXMisplacement.c3d']); 


%Misplacement in -x

amp = 0.01; % 10 mm
dir = (RAJC' - RFOOT_X);
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RFMH-XMisplacement.c3d']);


%Misplacement in xy
Markers2=Markers;
dir=(RFOOT_X - RAJC')+(RFOOT_Y - RAJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RFMHXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(RAJC' - RFOOT_X)+(RAJC' - RFOOT_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RFMH-XYMisplacement.c3d']);

%% Right Metatarsal Misplacement (RVMH)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'RVMH'));
Markers2 = Markers;

%Misplacement in y

amp = 0.01; % 10 mm
dir = (RFOOT_Y - RAJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RVMHYMisplacement.c3d']); 

%Misplacement in -y

amp = 0.01; % 10 mm
dir = (RAJC' - RFOOT_Y);
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RVMH-YMisplacement.c3d']); 


%Misplacement in x

amp = 0.01; % 10 mm
dir = (RFOOT_X - RAJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RVMHXMisplacement.c3d']); 


%Misplacement in -x

amp = 0.01; % 10 mm
dir = (RAJC' - RFOOT_X);
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RVMH-XMisplacement.c3d']); 


%Misplacement in xy
Markers2=Markers;
dir=(RFOOT_X - RAJC')+(RFOOT_Y - RAJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RVMHXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(RAJC' - RFOOT_X)+(RAJC' - RFOOT_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1RVMH-XYMisplacement.c3d']);


%% Left foot parameters

% Extract marker trajectories

LHEE = permute(mean(M.LHEE)*1e-3,[2,3,1]);
LFMH = permute(mean(M.LFMH)*1e-3,[2,3,1]);
LVMH = permute(mean(M.LVMH)*1e-3,[2,3,1]);


% Metatarsal joint centre (Dumas and Wojtusch 2018)
LMJC = (LFMH+LVMH)/2;

% Foot axes (Dumas and Wojtusch 2018)
X7 = Vnorm_array3(LMJC-LHEE);
Y7 = -Vnorm_array3(cross(LVMH-LHEE,LFMH-LHEE));
Z7 = Vnorm_array3(cross(X7,Y7));

% Store segment coordinate system
LFOOT_X=permute(LAJC+X7*10e-2,[3,1,2]);
LFOOT_Y=permute(LAJC+Y7*10e-2,[3,1,2]);
LFOOT_Z=permute(LAJC+Z7*10e-2,[3,1,2]);


%% Left Metatarsal Misplacement (LHEE)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'LHEE'));
Markers2 = Markers;

%Misplacement in y

amp = 0.01; % 10 mm
dir = (LFOOT_Y -LAJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LHEEYMisplacement.c3d']); 

%Misplacement in -y

amp = 0.01; % 10 mm
dir = (LAJC' - LFOOT_Y);
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LHEE-YMisplacement.c3d']); 


%Misplacement in z

amp = 0.01; % 10 mm
dir = (LFOOT_Z - LAJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LHEEZMisplacement.c3d']); 


%Misplacement in -z

amp = 0.01; % 10 mm
dir = (LAJC' - LFOOT_Z);
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LHEE-ZMisplacement.c3d']); 

%Misplacement in yz
Markers2=Markers;
dir=(LFOOT_Y - LAJC')+(LFOOT_Z - LAJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LHEEYZMisplacement.c3d']);

%Misplacement in -yz
Markers2=Markers;
dir=(LAJC' - LFOOT_Y)+(LAJC' - LFOOT_Z);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LHEE-YZMisplacement.c3d']);



%% Left Metatarsal Misplacement (LFMH)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'LFMH'));
Markers2 = Markers;

%Misplacement in y

amp = 0.01; % 10 mm
dir = (LFOOT_Y -LAJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LFMHYMisplacement.c3d']); 

%Misplacement in -y

amp = 0.01; % 10 mm
dir = (LAJC' - LFOOT_Y);
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LFMH-YMisplacement.c3d']); 


%Misplacement in x

amp = 0.01; % 10 mm
dir = (LFOOT_X - LAJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LFMHXMisplacement.c3d']); 


%Misplacement in -x

amp = 0.01; % 10 mm
dir = (LAJC' - LFOOT_X);
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LFMH-XMisplacement.c3d']); 


%Misplacement in xy
Markers2=Markers;
dir=(LFOOT_X - LAJC')+(LFOOT_Y - LAJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LFMHXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(LAJC' - LFOOT_X)+(LAJC' - LFOOT_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LFMH-XYMisplacement.c3d']);



%% Left Metatarsal Misplacement (LVMH)

h=btkCloneAcquisition(c3dbase);
MarkerName = fields(M);
indm = find(strcmp(MarkerName, 'LVMH'));
Markers2 = Markers;

%Misplacement in y

amp = 0.01; % 10 mm
dir = (LFOOT_Y -LAJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LVMHYMisplacement.c3d']); 

%Misplacement in -y

amp = 0.01; % 10 mm
dir = (LAJC' - LFOOT_Y);
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LVMH-YMisplacement.c3d']); 


%Misplacement in x

amp = 0.01; % 10 mm
dir = (LFOOT_X - LAJC');
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), 'x');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LVMHXMisplacement.c3d']); 


%Misplacement in -x

amp = 0.01; % 10 mm
dir = (LAJC' - LFOOT_X);
udir = dir/norm(dir);
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LVMH-XMisplacement.c3d']); 

%Misplacement in xy
Markers2=Markers;
dir=(LFOOT_X - LAJC')+(LFOOT_Y - LAJC');
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LVMHXYMisplacement.c3d']);

%Misplacement in -xy
Markers2=Markers;
dir=(LAJC' - LFOOT_X)+(LAJC' - LFOOT_Y);
udir = dir/norm(dir);
amp = 0.01; % 10 mm
Markers2(:,(indm-1)*3+(1:3)) = Markers2(:,(indm-1)*3+(1:3)) + repmat(amp*udir, size(Markers2,1), 1);
plot3(mean(Markers2(:, 1:3:135)), mean(Markers2(:,2:3:135)), mean(Markers2(:, 3:3:135)), '^');
btkSetMarkersValues(h,Markers2*1e3);
btkWriteAcquisition(h,[pathprin 'StaticOmar1LVMH-XYMisplacement.c3d']);




btkCloseAcquisition(c3dbase); 
btkCloseAcquisition(h);
