% Author       : F. Moissenet
%                Kinesiology Laboratory (K-LAB)
%                University of Geneva
%                https://www.unige.ch/medecine/kinesiology
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : https://github.com/fmoissenet/NSLBP-BIOToolbox
% Reference    : To be defined
% Date         : June 2020
% -------------------------------------------------------------------------
% Description  : To be defined
% Inputs       : To be defined
% Outputs      : To be defined
% -------------------------------------------------------------------------
% Dependencies : None
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function Trial = DefineSegments_KevinData(Session,Participant,Static,Trial)

% -------------------------------------------------------------------------
% Pelvis parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
clear RASI RILC RPSI LPSI LILC LASI S1;
RASI = permute(Trial.Marker(1).Trajectory.smooth,[2,3,1]);
RILC = permute(Trial.Marker(2).Trajectory.smooth,[2,3,1]);
RPSI = permute(Trial.Marker(3).Trajectory.smooth,[2,3,1]);
LPSI = permute(Trial.Marker(4).Trajectory.smooth,[2,3,1]);
LILC = permute(Trial.Marker(5).Trajectory.smooth,[2,3,1]);
LASI = permute(Trial.Marker(6).Trajectory.smooth,[2,3,1]);
S1   = permute(Trial.Marker(7).Trajectory.smooth,[2,3,1]);
% Pelvis axes (Dumas and Wojtusch 2018)
Z5 = Vnorm_array3(RASI-LASI);
Y5 = Vnorm_array3(cross(RASI-(RPSI+LPSI)/2, ...
                        LASI-(RPSI+LPSI)/2));
X5 = Vnorm_array3(cross(Y5,Z5));
% Determination of the lumbar joint centre by regression (Dumas and Wojtusch 2018)
if ~isempty(Static)
    % Determination of the lumbar joint centre by singular value decomposition
    % based on the static record
    RASIs = permute(Static.Marker(1).Trajectory.smooth,[2,3,1]);
    RILCs = permute(Static.Marker(2).Trajectory.smooth,[2,3,1]);
    RPSIs = permute(Static.Marker(3).Trajectory.smooth,[2,3,1]);
    LPSIs = permute(Static.Marker(4).Trajectory.smooth,[2,3,1]);
    LILCs = permute(Static.Marker(5).Trajectory.smooth,[2,3,1]);
    LASIs = permute(Static.Marker(6).Trajectory.smooth,[2,3,1]);
    S1s   = permute(Static.Marker(7).Trajectory.smooth,[2,3,1]);
    LJCs  = permute(Static.Vmarker(9).Trajectory.smooth,[2,3,1]);
    for t = 1:Trial.n1
        [R5,d5,rms5] = soder([RASIs';RPSIs';LPSIs';LASIs';S1s'],...
                             [RASI(:,:,t)';RPSI(:,:,t)';LPSI(:,:,t)';LASI(:,:,t)';S1(:,:,t)']);  
        LJC(:,:,t)   = R5*LJCs+d5;
        clear R5 d5 rms5;
    end
else
    % Pelvis width
    W5 = mean(sqrt(sum((RASI-LASI).^2)));
    % Determination of the lumbar joint centre by regression (Dumas and Wojtusch 2018)
    if strcmp(Participant.gender,'Female')
        LJC(1) = -34.0/100;
        LJC(2) = 4.9/100;
        LJC(3) = 0.0/100;
    elseif strcmp(Participant.gender,'Male')
        LJC(1) = -33.5/100;
        LJC(2) = -3.2/100;
        LJC(3) = 0.0/100;
    end
    LJC = (RASI+LASI)/2 + ...
          LJC(1)*W5*X5 + LJC(2)*W5*Y5 + LJC(3)*W5*Z5;
end
% Store virtual marker
Trial.Vmarker(9).label             = 'LJC';
Trial.Vmarker(9).Trajectory.smooth = permute(LJC,[3,1,2]);  
% Joint centre determination
if ~isempty(Static)
    % Determination of the hip joint centre by singular value decomposition
    % based on the static record
    RASIs = permute(Static.Marker(1).Trajectory.smooth,[2,3,1]);
    RILCs = permute(Static.Marker(2).Trajectory.smooth,[2,3,1]);
    RPSIs = permute(Static.Marker(3).Trajectory.smooth,[2,3,1]);
    LPSIs = permute(Static.Marker(4).Trajectory.smooth,[2,3,1]);
    LILCs = permute(Static.Marker(5).Trajectory.smooth,[2,3,1]);
    LASIs = permute(Static.Marker(6).Trajectory.smooth,[2,3,1]);
    S1s   = permute(Static.Marker(7).Trajectory.smooth,[2,3,1]);
    RHJCs = permute(Static.Vmarker(4).Trajectory.smooth,[2,3,1]);
    LHJCs = permute(Static.Vmarker(8).Trajectory.smooth,[2,3,1]);
    for t = 1:Trial.n1
        [R5,d5,rms5] = soder([RASIs';RPSIs';LPSIs';LASIs';S1s'],...
                             [RASI(:,:,t)';RPSI(:,:,t)';LPSI(:,:,t)';LASI(:,:,t)';S1(:,:,t)']);  
        RHJC(:,:,t)  = R5*RHJCs+d5;  
        LHJC(:,:,t)  = R5*LHJCs+d5;
        clear R5 d5 rms5;
    end
else
    % Determination of the hip joint centre by regression (Dumas and Wojtusch 2018)
    if strcmp(Participant.gender,'Female')
        R_HJC(1) = -13.9/100;
        R_HJC(2) = -33.6/100;
        R_HJC(3) = 37.2/100;
        L_HJC(1) = -13.9/100;
        L_HJC(2) = -33.6/100;
        L_HJC(3) = -37.2/100;
    elseif strcmp(Participant.gender,'Male')
        R_HJC(1) = -9.5/100;
        R_HJC(2) = -37.0/100;
        R_HJC(3) = 36.1/100;
        L_HJC(1) = -9.5/100;
        L_HJC(2) = -37.0/100;
        L_HJC(3) = -36.1/100;
    end
    RHJC = (RASI+LASI)/2 + ...
           R_HJC(1)*W5*X5 + R_HJC(2)*W5*Y5 + R_HJC(3)*W5*Z5;
    LHJC = (RASI+LASI)/2 + ...
           L_HJC(1)*W5*X5 + L_HJC(2)*W5*Y5 + L_HJC(3)*W5*Z5;
end
% Store virtual markers
Trial.Vmarker(4).label             = 'RHJC';
Trial.Vmarker(4).Trajectory.smooth = permute(RHJC,[3,1,2]);  
Trial.Vmarker(8).label             = 'LHJC';
Trial.Vmarker(8).Trajectory.smooth = permute(LHJC,[3,1,2]);  
% Pelvis parameters (Dumas and Chèze 2007) = Pelvis duplicated to manage
% different kinematic chains
rP5                        = LJC;
rD5                        = (RHJC+LHJC)/2;
w5                         = Z5;
u5                         = X5;
Trial.Segment(5).Q.smooth  = [u5;rP5;rD5;w5];
Trial.Segment(10).Q.smooth = [u5;rP5;rD5;w5];
Trial.Segment(14).Q.smooth = [u5;rP5;rD5;w5];

% -------------------------------------------------------------------------
% Right femur parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
clear RHJC RKJC RKNE RTHI;
RTHI = permute(Trial.Marker(9).Trajectory.smooth,[2,3,1]);
RKNE = permute(Trial.Marker(10).Trajectory.smooth,[2,3,1]);
RHJC = permute(Trial.Vmarker(4).Trajectory.smooth,[2,3,1]);
% Joint centre determination
if ~isempty(Static)
    % Determination of the joint centre by singular value decomposition
    % based on the static record
    RTHIs = permute(Static.Marker(9).Trajectory.smooth,[2,3,1]);
    RKNEs = permute(Static.Marker(10).Trajectory.smooth,[2,3,1]);
    RHJCs = permute(Static.Vmarker(4).Trajectory.smooth,[2,3,1]);
    RKJCs = permute(Static.Vmarker(3).Trajectory.smooth,[2,3,1]);
    for t = 1:Trial.n1
        [R4,d4,rms4] = soder([RHJCs';RTHIs';RKNEs'],...
                             [RHJC(:,:,t)';RTHI(:,:,t)';RKNE(:,:,t)']);  
        RKJC(:,:,t)  = R4*RKJCs+d4;  
        clear R4 d4 rms4;
    end
else
    % Compute joint centre (chord function)
    RHJC2 = Trial.Vmarker(4).Trajectory.smooth;
    RTHI2 = Trial.Marker(9).Trajectory.smooth;
    RKNE2 = Trial.Marker(10).Trajectory.smooth;
    RKJC  = chord_func(RHJC2,RTHI2,RKNE2,Participant.RKneeWidth,Session.markerHeight)';
end
% Store virtual markers
Trial.Vmarker(3).label             = 'RKJC';
Trial.Vmarker(3).Trajectory.smooth = permute(RKJC,[3,1,2]); 
% Femur axes (Dumas and Wojtusch 2018)
Y4 = Vnorm_array3(RHJC-RKJC);
X4 = Vnorm_array3(cross(RKNE-RHJC,RKJC-RHJC));
Z4 = Vnorm_array3(cross(X4,Y4));
% Femur parameters (Dumas and Chèze 2007)
rP4                        = RHJC;
rD4                        = RKJC;
w4                         = Z4;
u4                         = X4;
Trial.Segment(4).Q.smooth  = [u4;rP4;rD4;w4];

% -------------------------------------------------------------------------
% Right Tibia/fibula parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
clear RKJC RAJC RANK RTIB;
RANK = permute(Trial.Marker(15).Trajectory.smooth,[2,3,1]);
RTIB = permute(Trial.Marker(14).Trajectory.smooth,[2,3,1]);
RKJC = permute(Trial.Vmarker(3).Trajectory.smooth,[2,3,1]);
% Joint centre determination
if ~isempty(Static)
    % Determination of the joint centre by singular value decomposition
    % based on the static record
    RANKs = permute(Static.Marker(15).Trajectory.smooth,[2,3,1]);
    RTIBs = permute(Static.Marker(14).Trajectory.smooth,[2,3,1]);
    RKJCs = permute(Static.Vmarker(3).Trajectory.smooth,[2,3,1]);
    RAJCs = permute(Static.Vmarker(2).Trajectory.smooth,[2,3,1]);
    for t = 1:Trial.n1
        [R3,d3,rms3] = soder([RKJCs';RTIBs';RANKs'],...
                             [RKJC(:,:,t)';RTIB(:,:,t)';RANK(:,:,t)']);  
        RAJC(:,:,t)  = R3*RAJCs+d3;  
        clear R3 d3 rms3;
    end
else
    % Compute joint centre (chord function)
    RKJC2 = Trial.Vmarker(3).Trajectory.smooth;
    RTIB2 = Trial.Marker(14).Trajectory.smooth;
    RANK2 = Trial.Marker(15).Trajectory.smooth;
    RAJC  = chord_func(RKJC2,RTIB2,RANK2,Participant.RAnkleWidth,Session.markerHeight)';
end
% Store virtual markers
Trial.Vmarker(2).label             = 'RAJC';
Trial.Vmarker(2).Trajectory.smooth = permute(RAJC,[3,1,2]); 
% Tibia/fibula axes (Dumas and Wojtusch 2018)
Y3 = Vnorm_array3(RKJC-RAJC);
X3 = Vnorm_array3(cross(RAJC-RTIB,RKJC-RTIB));
Z3 = Vnorm_array3(cross(X3,Y3));
% Tibia/fibula parameters (Dumas and Chèze 2007)
rP3                        = RKJC;
rD3                        = RAJC;
w3                         = Z3;
u3                         = X3;
Trial.Segment(3).Q.smooth  = [u3;rP3;rD3;w3];

% -------------------------------------------------------------------------
% Right foot parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
RHEE = permute(Trial.Marker(17).Trajectory.smooth,[2,3,1]);
RTOE = permute(Trial.Marker(18).Trajectory.smooth,[2,3,1]);
% Metatarsal joint centre (Dumas and Wojtusch 2018)
RMJC = RTOE;
% Store virtual marker
Trial.Vmarker(1).label             = 'RMJC';
Trial.Vmarker(1).Trajectory.smooth = permute(RMJC,[3,1,2]);  
% Foot axes (Dumas and Wojtusch 2018)
X2 = Vnorm_array3(RMJC-RHEE);
Z2 = Z3;
Y2 = Vnorm_array3(cross(Z2,X2));
% Foot parameters (Dumas and Chèze 2007)
rP2                        = RAJC;
rD2                        = RMJC;
w2                         = Z2;
u2                         = X2;
Trial.Segment(2).Q.smooth  = [u2;rP2;rD2;w2];

% -------------------------------------------------------------------------
% Left femur parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
clear LHJC LKJC LKNE LTHI;
LTHI = permute(Trial.Marker(24).Trajectory.smooth,[2,3,1]);
LKNE = permute(Trial.Marker(25).Trajectory.smooth,[2,3,1]);
LHJC = permute(Trial.Vmarker(8).Trajectory.smooth,[2,3,1]);
% Joint centre determination
if ~isempty(Static)
    % Determination of the joint centre by singular value decomposition
    % based on the static record
    LTHIs = permute(Static.Marker(24).Trajectory.smooth,[2,3,1]);
    LKNEs = permute(Static.Marker(25).Trajectory.smooth,[2,3,1]);
    LHJCs = permute(Static.Vmarker(8).Trajectory.smooth,[2,3,1]);
    LKJCs = permute(Static.Vmarker(7).Trajectory.smooth,[2,3,1]);
    for t = 1:Trial.n1
        [R9,d9,rms9] = soder([LHJCs';LTHIs';LKNEs'],...
                             [LHJC(:,:,t)';LTHI(:,:,t)';LKNE(:,:,t)']);  
        LKJC(:,:,t)  = R9*LKJCs+d9;  
        clear R9 d9 rms9;
    end
else
    % Compute joint centre (chord function)
    LHJC2 = Trial.Vmarker(8).Trajectory.smooth;
    LTHI2 = Trial.Marker(24).Trajectory.smooth;
    LKNE2 = Trial.Marker(25).Trajectory.smooth;
    LKJC  = chord_func(LHJC2,LTHI2,LKNE2,Participant.LKneeWidth,Session.markerHeight)';
end
% Store virtual markers
Trial.Vmarker(7).label             = 'LKJC';
Trial.Vmarker(7).Trajectory.smooth = permute(LKJC,[3,1,2]); 
% Femur axes (Dumas and Wojtusch 2018)
Y9 = Vnorm_array3(LHJC-LKJC);
X9 = -Vnorm_array3(cross(LKNE-LHJC,LKJC-LHJC));
Z9 = Vnorm_array3(cross(X9,Y9));
% Femur parameters (Dumas and Chèze 2007)
rP9                        = LHJC;
rD9                        = LKJC;
w9                         = Z9;
u9                         = X9;
Trial.Segment(9).Q.smooth  = [u9;rP9;rD9;w9];

% -------------------------------------------------------------------------
% Left Tibia/fibula parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
clear LKJC LAJC LANK LTIB;
LANK = permute(Trial.Marker(30).Trajectory.smooth,[2,3,1]);
LTIB = permute(Trial.Marker(29).Trajectory.smooth,[2,3,1]);
LKJC = permute(Trial.Vmarker(7).Trajectory.smooth,[2,3,1]);
% Joint centre determination
if ~isempty(Static)
    % Determination of the joint centre by singular value decomposition
    % based on the static record
    LKJCs = permute(Static.Vmarker(7).Trajectory.smooth,[2,3,1]);
    LAJCs = permute(Static.Vmarker(6).Trajectory.smooth,[2,3,1]);
    LANKs = permute(Static.Marker(30).Trajectory.smooth,[2,3,1]);
    LTIBs = permute(Static.Marker(29).Trajectory.smooth,[2,3,1]);
    for t = 1:Trial.n1
        [R8,d8,rms8] = soder([LKJCs';LTIBs';LANKs'],...
                             [LKJC(:,:,t)';LTIB(:,:,t)';LANK(:,:,t)']);  
        LAJC(:,:,t)  = R8*LAJCs+d8;  
        clear R8 d8 rms8;
    end
else
    % Compute joint centre (chord function)
    LKJC2 = Trial.Vmarker(7).Trajectory.smooth;
    LTIB2 = Trial.Marker(29).Trajectory.smooth;
    LANK2 = Trial.Marker(30).Trajectory.smooth;
    LAJC  = chord_func(LKJC2,LTIB2,LANK2,Participant.LAnkleWidth,Session.markerHeight)';
end
% Store virtual markers
Trial.Vmarker(6).label             = 'LAJC';
Trial.Vmarker(6).Trajectory.smooth = permute(LAJC,[3,1,2]); 
% Tibia/fibula axes (Dumas and Wojtusch 2018)
Y8 = Vnorm_array3(LKJC-LAJC);
X8 = -Vnorm_array3(cross(LAJC-LTIB,LKJC-LTIB));
Z8 = Vnorm_array3(cross(X8,Y8));
% Tibia/fibula parameters (Dumas and Chèze 2007)
rP8                        = LKJC;
rD8                        = LAJC;
w8                         = Z8;
u8                         = X8;
Trial.Segment(8).Q.smooth  = [u8;rP8;rD8;w8];

% -------------------------------------------------------------------------
% Left foot parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
LHEE = permute(Trial.Marker(32).Trajectory.smooth,[2,3,1]);
LTOE = permute(Trial.Marker(33).Trajectory.smooth,[2,3,1]);
% Metatarsal joint centre (Dumas and Wojtusch 2018)
LMJC = LTOE;
% Store virtual marker
Trial.Vmarker(5).label             = 'LMJC';
Trial.Vmarker(5).Trajectory.smooth = permute(LMJC,[3,1,2]);  
% Foot axes (Dumas and Wojtusch 2018)
X7 = Vnorm_array3(LMJC-LHEE);
Z7 = Z8;
Y7 = Vnorm_array3(cross(Z7,X7));
% Foot parameters (Dumas and Chèze 2007)
rP7                        = RAJC;
rD7                        = RMJC;
w7                         = Z7;
u7                         = X7;
Trial.Segment(7).Q.smooth  = [u7;rP7;rD7;w7];

% -------------------------------------------------------------------------
% Lumbar parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
CLAV = permute(Trial.Marker(48).Trajectory.smooth,[2,3,1]);
STRN = permute(Trial.Marker(49).Trajectory.smooth,[2,3,1]);
C7   = permute(Trial.Marker(41).Trajectory.smooth,[2,3,1]);
T8   = permute(Trial.Marker(45).Trajectory.smooth,[2,3,1]);
T12  = permute(Trial.Marker(46).Trajectory.smooth,[2,3,1]); % T10 instead (T12 not recorded)
L1   = permute(Trial.Marker(38).Trajectory.smooth,[2,3,1]);
% Joint centre determination
if ~isempty(Static)
    % Determination of the joint centre by singular value decomposition
    % based on the static record
    CLAVs = permute(Static.Marker(48).Trajectory.smooth,[2,3,1]);
    STRNs = permute(Static.Marker(49).Trajectory.smooth,[2,3,1]);
    C7s   = permute(Static.Marker(41).Trajectory.smooth,[2,3,1]);
    T8s   = permute(Static.Marker(45).Trajectory.smooth,[2,3,1]);
    T12s  = permute(Static.Marker(46).Trajectory.smooth,[2,3,1]); % T10 instead (T12 not recorded)
    L1s   = permute(Static.Marker(38).Trajectory.smooth,[2,3,1]);
    TJCs  = permute(Static.Vmarker(10).Trajectory.smooth,[2,3,1]);
    for t = 1:Trial.n1
        [R11,d11,rms11] = soder([CLAVs';STRNs';C7s';T8s';T12s';L1s'],...
                                [CLAV(:,:,t)';STRN(:,:,t)';C7(:,:,t)';T8(:,:,t)';T12(:,:,t)';L1(:,:,t)']);  
        TJC(:,:,t)     = R11*TJCs+d11;  
        clear R11 d11 rms11;
    end 
else
    % Thorax width (Dumas and Wojtusch 2018)
    W11 = mean(sqrt(sum((CLAV-C7).^2)));
    % Determination of thoracic joint centre by regression (Dumas and Wojtusch 2018)
    tX11 = Vnorm_array3(STRN-T8);
    tY11 = Vnorm_array3(T8-T12);
    tZ11 = cross(tX11,tY11);
    tX11 = cross(tY11,tZ11);
    if strcmp(Participant.gender,'Female')
        angle = 92;
        coeff = 0.50;
    elseif strcmp(Participant.gender,'Male')
        angle = 94;
        coeff = 0.52;
    end
    R11 = [cosd(angle) sind(angle) 0 0; ...
           -sind(angle) cosd(angle) 0 0;
           0 0 1 0; ...
           0 0 0 1];
    TJC = Mprod_array3(Mprod_array3([tX11 tY11 tZ11 T12; ...
                       repmat([0 0 0 1],[1,1,size(T12,3)])], ...
                       repmat(R11,[1,1,size(T12,3)])), ...
                       repmat([0; coeff*W11; 0; 1],[1,1,size(T12,3)]));
    TJC = TJC(1:3,:,:);
end
% Store virtual marker
Trial.Vmarker(10).label             = 'TJC';
Trial.Vmarker(10).Trajectory.smooth = permute(TJC,[3,1,2]);  
% Lumbar axes (Dumas and Wojtusch 2018)
Y11 = Vnorm_array3(TJC-LJC);
Z11 = Z5; % no axial rotation at lumbar joint centre assumed
X11 = Vnorm_array3(cross(Y11,Z11));
% Lumbar parameters
rP11                        = TJC;
rD11                        = LJC;
w11                         = Z11;
u11                         = X11;
Trial.Segment(11).Q.smooth  = [u11;rP11;rD11;w11];
% Trial.Segment(11).rM.smooth = [TJC,RPSI,LPSI]; % no axial rotation at lumbar joint centre assumed

% -------------------------------------------------------------------------
% Thorax parameters
% -------------------------------------------------------------------------
% Joint centre determination
if ~isempty(Static)
    % Determination of the joint centre by singular value decomposition
    % based on the static record
    CLAVs = permute(Static.Marker(48).Trajectory.smooth,[2,3,1]);
    STRNs = permute(Static.Marker(49).Trajectory.smooth,[2,3,1]);
    C7s   = permute(Static.Marker(41).Trajectory.smooth,[2,3,1]);
    T8s   = permute(Static.Marker(45).Trajectory.smooth,[2,3,1]);
    T12s  = permute(Static.Marker(46).Trajectory.smooth,[2,3,1]); % T10 instead (T12 not recorded)
    L1s   = permute(Static.Marker(38).Trajectory.smooth,[2,3,1]);
    CJCs  = permute(Static.Vmarker(11).Trajectory.smooth,[2,3,1]);
    for t = 1:Trial.n1
        [R12,d12,rms12] = soder([CLAVs';STRNs';C7s';T8s';T12s';L1s'],...
                                [CLAV(:,:,t)';STRN(:,:,t)';C7(:,:,t)';T8(:,:,t)';T12(:,:,t)';L1(:,:,t)']);  
        CJC(:,:,t)     = R12*CJCs+d12;  
        clear R12 d12 rms12;
    end
else
    % Thorax width (Dumas and Wojtusch 2018)
    W12 = mean(sqrt(sum((CLAV-C7).^2)));
    % Determination of the cervical joint centre by regression (Dumas and Wojtusch 2018)
    tX12 = Vnorm_array3(CLAV-C7);
    tZ12 = Vnorm_array3(cross(STRN-C7,CLAV-C7));
    tY12 = Vnorm_array3(cross(tZ12,tX12));
    if strcmp(Participant.gender,'Female')
        angle = -14;
        coeff = 0.53;
    elseif strcmp(Participant.gender,'Male')
        angle = -8;
        coeff = 0.55;
    end
    R12 = [cosd(angle) sind(angle) 0 0; ...
           -sind(angle) cosd(angle) 0 0;
           0 0 1 0; ...
           0 0 0 1];
    CJC = Mprod_array3(Mprod_array3([tX12 tY12 tZ12 C7; ...
                       repmat([0 0 0 1],[1,1,size(C7,3)])], ...
                       repmat(R12,[1,1,size(C7,3)])), ...
                       repmat([coeff*W12; 0; 0; 1],[1,1,size(C7,3)]));
    CJC = CJC(1:3,:,:);
end
% Store virtual marker
Trial.Vmarker(11).label             = 'CJC';
Trial.Vmarker(11).Trajectory.smooth = permute(CJC,[3,1,2]);  
% Thorax axes (Dumas and Chèze 2007)
Y12 = Vnorm_array3(CJC-TJC);
Z12 = Vnorm_array3(cross(CLAV-TJC,CJC-TJC));
X12 = Vnorm_array3(cross(Y12,Z12));
% Thorax parameters
rP12                        = CJC;
rD12                        = TJC;
w12                         = Z12;
u12                         = X12;
Trial.Segment(12).Q.smooth  = [u12;rP12;rD12;w12];
% Trial.Segment(12).rM.smooth = [CLAV,C7,STRN,TJC];

% -------------------------------------------------------------------------
% Head with neck parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
RFHD = permute(Trial.Marker(50).Trajectory.smooth,[2,3,1]);
RBHD = permute(Trial.Marker(51).Trajectory.smooth,[2,3,1]);
LFHD = permute(Trial.Marker(52).Trajectory.smooth,[2,3,1]);
LBHD = permute(Trial.Marker(53).Trajectory.smooth,[2,3,1]);
% Head vertex (Dumas and Wojtusch 2018)
VER = (RFHD+RBHD+LFHD+LBHD)/4; % assimilated to the head vertex described in Dumas and Wojtusch 2018
% Store virtual marker
Trial.Vmarker(12).label             = 'VER';
Trial.Vmarker(12).Trajectory.smooth = permute(VER,[3,1,2]);  
% Head axes
Y13 = Vnorm_array3(VER-CJC);
Z13 = Vnorm_array3(cross((RFHD+LFHD)/2-CJC,(RBHD+LBHD)/2-CJC));
X13 = Vnorm_array3(cross(Y13,Z13));
% Head parameters
rP13                        = VER;
rD13                        = CJC;
w13                         = Z13;
u13                         = X13;
Trial.Segment(13).Q.smooth  = [u13;rP13;rD13;w13];
% Trial.Segment(13).rM.smooth = [RFHD,RBHD,LFHD,LBHD];
Trial.Segment(19).Q.smooth  = [u13;rP13;rD13;w13];
% Trial.Segment(19).rM.smooth = [RFHD,RBHD,LFHD,LBHD];

% -------------------------------------------------------------------------
% Lower lumbar parameters (Hidalgo et al. 2012)
% -------------------------------------------------------------------------
% Extract marker trajectories
S1 = permute(Trial.Marker(7).Trajectory.smooth,[2,3,1]);
L3 = permute(Trial.Marker(39).Trajectory.smooth,[2,3,1]);
% Lower lumbar axes
Y15 = Vnorm_array3(L3-S1);
Z15 = Z11;
X15 = cross(Y15,Z15);
% Lower lumbar parameters
rP15                        = L3;
rD15                        = S1;
w15                         = Z15;
u15                         = X15;
Trial.Segment(15).Q.smooth  = [u15;rP15;rD15;w15];
% Trial.Segment(15).rM.smooth = [S1,L3];

% -------------------------------------------------------------------------
% Upper lumbar parameters (Hidalgo et al. 2012)
% -------------------------------------------------------------------------
% Upper lumbar axes
Y16 = Vnorm_array3(T12-L3);
Z16 = Z11;
X16 = cross(Y16,Z16);
% Upper lumbar parameters
rP16                        = T12;
rD16                        = L3;
w16                         = Z16;
u16                         = X16;
Trial.Segment(16).Q.smooth  = [u16;rP16;rD16;w16];
% Trial.Segment(16).rM.smooth = [T12,L3];

% -------------------------------------------------------------------------
% Lower thorax parameters (Hidalgo et al. 2012)
% -------------------------------------------------------------------------
% Lower thorax axes
Y17 = Vnorm_array3(T8-T12);
Z17 = Z12;
X17 = cross(Y17,Z17);
% Lower lumbar parameters
rP17                        = T8;
rD17                        = T12;
w17                         = Z17;
u17                         = X17;
Trial.Segment(17).Q.smooth  = [u17;rP17;rD17;w17];
% Trial.Segment(17).rM.smooth = [T8,T12];

% -------------------------------------------------------------------------
% Upper thorax parameters (Hidalgo et al. 2012)
% -------------------------------------------------------------------------
% Lower thorax axes
Y18 = Vnorm_array3(C7-T8);
Z18 = Z12;
X18 = cross(Y18,Z18);
% Lower lumbar parameters
rP18                        = C7;
rD18                        = T8;
w18                         = Z18;
u18                         = X18;
Trial.Segment(18).Q.smooth  = [u18;rP18;rD18;w18];
% Trial.Segment(18).rM.smooth = [C7,T8];