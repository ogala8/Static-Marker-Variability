% Author       : Omar Galarraga
%                Florent Moissenet
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : https://github.com/ogala8/Static-Marker-Variability
% Reference    : To be defined
% Date         : July 2021
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

function Trial = DefineSegments_CGM24(Session,Participant,Static,Trial)

% -------------------------------------------------------------------------
% Pelvis parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
RASI = permute(Trial.Marker(1).Trajectory.smooth,[2,3,1]);
RPSI = permute(Trial.Marker(2).Trajectory.smooth,[2,3,1]);
LPSI = permute(Trial.Marker(3).Trajectory.smooth,[2,3,1]);
LASI = permute(Trial.Marker(4).Trajectory.smooth,[2,3,1]);
% Pelvis axes (Dumas and Wojtusch 2018)
Z5 = Vnorm_array3(RASI-LASI);
Y5 = Vnorm_array3(cross(RASI-(RPSI+LPSI)/2, ...
                        LASI-(RPSI+LPSI)/2));
X5 = Vnorm_array3(cross(Y5,Z5));
% Determination of the lumbar joint centre by regression (Dumas and Wojtusch 2018)
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
% Store virtual marker
Trial.Vmarker(9).label             = 'LJC';
Trial.Vmarker(9).Trajectory.smooth = permute(LJC,[3,1,2]); 
% Determination of the hip joint centre by regression (Hara et al. 2016)
RHJC(1:3,1,1) = [X5 Y5 Z5]*[(11-0.063*Participant.RLegLength*1e3)*1e-3; ...
                            (-9-0.078*Participant.RLegLength*1e3)*1e-3; ...
                            -(8+0.086*Participant.RLegLength*1e3)*1e-3]+(RASI+LASI)/2;
LHJC(1:3,1,1) = [X5 Y5 Z5]*[(11-0.063*Participant.LLegLength*1e3)*1e-3; ...
                            (-9-0.078*Participant.LLegLength*1e3)*1e-3; ...
                            (8+0.086*Participant.LLegLength*1e3)*1e-3]+(RASI+LASI)/2;
% Store virtual markers
Trial.Vmarker(4).label              = 'RHJC';
Trial.Vmarker(4).Trajectory.smooth  = permute(RHJC,[3,1,2]);  
Trial.Vmarker(8).label              = 'LHJC';
Trial.Vmarker(8).Trajectory.smooth  = permute(LHJC,[3,1,2]);
% Store segment coordinate system
Trial.Vmarker(10).label             = 'midASIS';
Trial.Vmarker(10).Trajectory.smooth = permute((RASI+LASI)/2,[3,1,2]); 
Trial.Vmarker(11).label             = 'PELVIC_X';
Trial.Vmarker(11).Trajectory.smooth = permute((RASI+LASI)/2+X5*10e-2,[3,1,2]);
Trial.Vmarker(12).label             = 'PELVIC_Y';
Trial.Vmarker(12).Trajectory.smooth = permute((RASI+LASI)/2+Y5*10e-2,[3,1,2]);
Trial.Vmarker(13).label             = 'PELVIC_Z';
Trial.Vmarker(13).Trajectory.smooth = permute((RASI+LASI)/2+Z5*10e-2,[3,1,2]); 
% Pelvis parameters (Dumas and Chèze 2007) = Pelvis duplicated to manage
% different kinematic chains
rP5                         = LJC;
rD5                         = (RHJC+LHJC)/2;
w5                          = Z5;
u5                          = X5;
Trial.Segment(5).Q.smooth   = [u5;rP5;rD5;w5];
Trial.Segment(5).rM.smooth  = [RASI,LASI,RPSI,LPSI];
Trial.Segment(5).rM.label   = {'RASI','LASI','RPSI','LPSI'};
Trial.Segment(5).wM         = [Trial.Marker(1).IKweight,...
                               Trial.Marker(2).IKweight,...
                               Trial.Marker(3).IKweight,...
                               Trial.Marker(4).IKweight];

% -------------------------------------------------------------------------
% Right femur parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
RTHAP = permute(Trial.Marker(6).Trajectory.smooth,[2,3,1]);
RTHAD = permute(Trial.Marker(7).Trajectory.smooth,[2,3,1]);
RTHI2 = permute(Trial.Marker(9).Trajectory.smooth,[2,3,1]);
RKNE  = permute(Trial.Marker(10).Trajectory.smooth,[2,3,1]);
RKNM  = permute(Trial.Marker(11).Trajectory.smooth,[2,3,1]);
% Knee joint centre
RHJC2  = Trial.Vmarker(4).Trajectory.smooth;
RTHI22 = Trial.Marker(9).Trajectory.smooth;
RKNE2  = Trial.Marker(10).Trajectory.smooth;
RKJC   = chord_func(RHJC2,RTHI22,RKNE2,Participant.RKneeWidth,Session.markerHeight)';
% Store virtual marker
Trial.Vmarker(3).label             = 'RKJC';
Trial.Vmarker(3).Trajectory.smooth = permute(RKJC,[3,1,2]); 
% Femur axes (Dumas and Wojtusch 2018)
Y4 = Vnorm_array3(RHJC-RKJC);
X4 = Vnorm_array3(cross(RKNE-RHJC,RKJC-RHJC));
Z4 = Vnorm_array3(cross(X4,Y4));
% Store segment coordinate system
Trial.Vmarker(14).label             = 'RFEMUR_X';
Trial.Vmarker(14).Trajectory.smooth = permute(RHJC+X4*10e-2,[3,1,2]);
Trial.Vmarker(15).label             = 'RFEMUR_Y';
Trial.Vmarker(15).Trajectory.smooth = permute(RHJC+Y4*10e-2,[3,1,2]);
Trial.Vmarker(16).label             = 'RFEMUR_Z';
Trial.Vmarker(16).Trajectory.smooth = permute(RHJC+Z4*10e-2,[3,1,2]); 
% Femur parameters (Dumas and Chèze 2007)
rP4                        = RHJC;
rD4                        = RKJC;
w4                         = Z4;
u4                         = X4;
Trial.Segment(4).Q.smooth  = [u4;rP4;rD4;w4];
Trial.Segment(4).rM.smooth = [RTHI2,RKNE,RKNM,RTHAP,RTHAD];
Trial.Segment(4).rM.label  = {'RTHI2','RKNE','RKNM','RTHAP','RTHAD'};
Trial.Segment(4).wM        = [Trial.Marker(9).IKweight,...
                              Trial.Marker(10).IKweight,...
                              Trial.Marker(11).IKweight,...
                              Trial.Marker(6).IKweight,...
                              Trial.Marker(7).IKweight];

% -------------------------------------------------------------------------
% Right Tibia/fibula parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
RTIAP = permute(Trial.Marker(14).Trajectory.smooth,[2,3,1]);
RTIAD = permute(Trial.Marker(15).Trajectory.smooth,[2,3,1]);
RTIB2 = permute(Trial.Marker(17).Trajectory.smooth,[2,3,1]);
RANK  = permute(Trial.Marker(18).Trajectory.smooth,[2,3,1]);
RMED  = permute(Trial.Marker(19).Trajectory.smooth,[2,3,1]);
% Ankle joint centre
RKJC2  = Trial.Vmarker(3).Trajectory.smooth;
RTIB22 = Trial.Marker(17).Trajectory.smooth;
RANK2  = Trial.Marker(18).Trajectory.smooth;
RAJC   = chord_func(RKJC2,RTIB22,RANK2,Participant.RAnkleWidth,Session.markerHeight)';
% Store virtual marker
Trial.Vmarker(2).label             = 'RAJC';
Trial.Vmarker(2).Trajectory.smooth = permute(RAJC,[3,1,2]);  
% Tibia/fibula axes (Dumas and Wojtusch 2018)
Y3 = Vnorm_array3(RKJC-RAJC);
X3 = Vnorm_array3(cross(RAJC-RANK,RKJC-RANK));
Z3 = Vnorm_array3(cross(X3,Y3));
% Store segment coordinate system
Trial.Vmarker(17).label             = 'RTIBIA_X';
Trial.Vmarker(17).Trajectory.smooth = permute(RKJC+X3*10e-2,[3,1,2]);
Trial.Vmarker(18).label             = 'RTIBIA_Y';
Trial.Vmarker(18).Trajectory.smooth = permute(RKJC+Y3*10e-2,[3,1,2]);
Trial.Vmarker(19).label             = 'RTIBIA_Z';
Trial.Vmarker(19).Trajectory.smooth = permute(RKJC+Z3*10e-2,[3,1,2]); 
% Tibia/fibula parameters (Dumas and Chèze 2007)
rP3                        = RKJC;
rD3                        = RAJC;
w3                         = Z3;
u3                         = X3;
Trial.Segment(3).Q.smooth  = [u3;rP3;rD3;w3];
Trial.Segment(3).rM.smooth = [RTIB2,RANK,RMED,RTIAP,RTIAD];
Trial.Segment(3).rM.label  = {'RTIB','RANK','RMED','RTIAP','RTIAD'};
Trial.Segment(3).wM        = [Trial.Marker(14).IKweight,...
                              Trial.Marker(15).IKweight,...
                              Trial.Marker(17).IKweight,...
                              Trial.Marker(18).IKweight,...
                              Trial.Marker(19).IKweight];

% -------------------------------------------------------------------------
% Right foot parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
RHEE = permute(Trial.Marker(20).Trajectory.smooth,[2,3,1]);
RTOE = permute(Trial.Marker(21).Trajectory.smooth,[2,3,1]);
RFMH = permute(Trial.Marker(22).Trajectory.smooth,[2,3,1]);
RSMH = permute(Trial.Marker(23).Trajectory.smooth,[2,3,1]);
RVMH = permute(Trial.Marker(24).Trajectory.smooth,[2,3,1]);
% Metatarsal joint centre
RMJC = RTOE;
% Store virtual marker
Trial.Vmarker(1).label             = 'RMJC';
Trial.Vmarker(1).Trajectory.smooth = permute(RMJC,[3,1,2]);  
% Foot axes (Dumas and Wojtusch 2018)
X2 = Vnorm_array3(RMJC-RHEE);
Y2 = Vnorm_array3(cross(RVMH-RHEE,RFMH-RHEE));
Z2 = Vnorm_array3(cross(X2,Y2));
% Store segment coordinate system
Trial.Vmarker(20).label             = 'RFOOT_X';
Trial.Vmarker(20).Trajectory.smooth = permute(RAJC+X2*10e-2,[3,1,2]);
Trial.Vmarker(21).label             = 'RFOOT_Y';
Trial.Vmarker(21).Trajectory.smooth = permute(RAJC+Y2*10e-2,[3,1,2]);
Trial.Vmarker(22).label             = 'RFOOT_Z';
Trial.Vmarker(22).Trajectory.smooth = permute(RAJC+Z2*10e-2,[3,1,2]);
% Foot parameters (Dumas and Chèze 2007)
rP2                        = RAJC;
rD2                        = RMJC;
w2                         = Z2;
u2                         = X2;
Trial.Segment(2).Q.smooth  = [u2;rP2;rD2;w2];
Trial.Segment(2).rM.smooth = [RHEE,RTOE,RFMH,RVMH,RSMH];
Trial.Segment(2).rM.label  = {'RHEE','RTOE','RFMH','RVMH','RSMH'};
Trial.Segment(2).wM        = [Trial.Marker(20).IKweight,...
                              Trial.Marker(21).IKweight,...
                              Trial.Marker(22).IKweight,...
                              Trial.Marker(24).IKweight,...
                              Trial.Marker(23).IKweight];

% -------------------------------------------------------------------------
% Left femur parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
LTHAP = permute(Trial.Marker(26).Trajectory.smooth,[2,3,1]);
LTHAD = permute(Trial.Marker(27).Trajectory.smooth,[2,3,1]);
LTHI2 = permute(Trial.Marker(29).Trajectory.smooth,[2,3,1]);
LKNE  = permute(Trial.Marker(30).Trajectory.smooth,[2,3,1]);
LKNM  = permute(Trial.Marker(31).Trajectory.smooth,[2,3,1]);
% Knee joint centre
LHJC2  = Trial.Vmarker(8).Trajectory.smooth;
LTHI22 = Trial.Marker(29).Trajectory.smooth;
LKNE2  = Trial.Marker(30).Trajectory.smooth;
LKJC   = chord_func(LHJC2,LTHI22,LKNE2,Participant.LKneeWidth,Session.markerHeight)';
% Store virtual marker
Trial.Vmarker(7).label             = 'LKJC';
Trial.Vmarker(7).Trajectory.smooth = permute(LKJC,[3,1,2]);  
% Femur axes (Dumas and Wojtusch 2018)
Y9 = Vnorm_array3(LHJC-LKJC);
X9 = -Vnorm_array3(cross(LKNE-LHJC,LKJC-LHJC));
Z9 = Vnorm_array3(cross(X9,Y9));
% Store segment coordinate system
Trial.Vmarker(23).label             = 'LFEMUR_X';
Trial.Vmarker(23).Trajectory.smooth = permute(LHJC+X9*10e-2,[3,1,2]);
Trial.Vmarker(24).label             = 'LFEMUR_Y';
Trial.Vmarker(24).Trajectory.smooth = permute(LHJC+Y9*10e-2,[3,1,2]);
Trial.Vmarker(25).label             = 'LFEMUR_Z';
Trial.Vmarker(25).Trajectory.smooth = permute(LHJC+Z9*10e-2,[3,1,2]);  
% Femur parameters (Dumas and Chèze 2007)
rP9                        = LHJC;
rD9                        = LKJC;
w9                         = Z9;
u9                         = X9;
Trial.Segment(9).Q.smooth  = [u9;rP9;rD9;w9];
Trial.Segment(9).rM.smooth = [LTHI2,LKNE,LKNM,LTHAP,LTHAD];
Trial.Segment(9).rM.label  = {'LTHI2','LKNE','LKNM','LTHAP','LTHAD'};
Trial.Segment(9).wM        = [Trial.Marker(29).IKweight,...
                              Trial.Marker(30).IKweight,...
                              Trial.Marker(31).IKweight,...
                              Trial.Marker(26).IKweight,...
                              Trial.Marker(27).IKweight];

% -------------------------------------------------------------------------
% Left Tibia/fibula parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
LTIAP = permute(Trial.Marker(34).Trajectory.smooth,[2,3,1]);
LTIAD = permute(Trial.Marker(35).Trajectory.smooth,[2,3,1]);
LTIB2 = permute(Trial.Marker(37).Trajectory.smooth,[2,3,1]);
LANK  = permute(Trial.Marker(38).Trajectory.smooth,[2,3,1]);
LMED  = permute(Trial.Marker(39).Trajectory.smooth,[2,3,1]);
% Ankle joint centre
LKJC2  = Trial.Vmarker(7).Trajectory.smooth;
LTIB22 = Trial.Marker(37).Trajectory.smooth;
LANK2  = Trial.Marker(38).Trajectory.smooth;
LAJC   = chord_func(LKJC2,LTIB22,LANK2,Participant.LAnkleWidth,Session.markerHeight)';
% Store virtual marker
Trial.Vmarker(6).label             = 'LAJC';
Trial.Vmarker(6).Trajectory.smooth = permute(LAJC,[3,1,2]);  
% Tibia/fibula axes (Dumas and Wojtusch 2018)
Y8 = Vnorm_array3(LKJC-LAJC);
X8 = -Vnorm_array3(cross(LAJC-LANK,LKJC-LANK));
Z8 = Vnorm_array3(cross(X8,Y8));
% Store segment coordinate system
Trial.Vmarker(26).label             = 'LTIBIA_X';
Trial.Vmarker(26).Trajectory.smooth = permute(LKJC+X8*10e-2,[3,1,2]);
Trial.Vmarker(27).label             = 'LTIBIA_Y';
Trial.Vmarker(27).Trajectory.smooth = permute(LKJC+Y8*10e-2,[3,1,2]);
Trial.Vmarker(28).label             = 'LTIBIA_Z';
Trial.Vmarker(28).Trajectory.smooth = permute(LKJC+Z8*10e-2,[3,1,2]); 
% Tibia/fibula parameters (Dumas and Chèze 2007)
rP8                        = LKJC;
rD8                        = LAJC;
w8                         = Z8;
u8                         = X8;
Trial.Segment(8).Q.smooth  = [u8;rP8;rD8;w8];
Trial.Segment(8).rM.smooth = [LTIB2,LANK,LMED,LTIAP,LTIAD];
Trial.Segment(8).rM.label  = {'LTIB2','LANK','LMED','LTIAP','LTIAD'};
Trial.Segment(8).wM        = [Trial.Marker(37).IKweight,...
                              Trial.Marker(38).IKweight,...
                              Trial.Marker(39).IKweight,...
                              Trial.Marker(34).IKweight,...
                              Trial.Marker(35).IKweight];

% -------------------------------------------------------------------------
% Left foot parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
LHEE = permute(Trial.Marker(40).Trajectory.smooth,[2,3,1]);
LTOE = permute(Trial.Marker(41).Trajectory.smooth,[2,3,1]);
LFMH = permute(Trial.Marker(42).Trajectory.smooth,[2,3,1]);
LSMH = permute(Trial.Marker(43).Trajectory.smooth,[2,3,1]);
LVMH = permute(Trial.Marker(44).Trajectory.smooth,[2,3,1]);
% Metatarsal joint centre
LMJC = LTOE;
% Store virtual marker
Trial.Vmarker(5).label             = 'LMJC';
Trial.Vmarker(5).Trajectory.smooth = permute(LMJC,[3,1,2]);  
% Foot axes (Dumas and Wojtusch 2018)
X7 = Vnorm_array3(LMJC-LHEE);
Y7 = -Vnorm_array3(cross(LVMH-LHEE,LFMH-LHEE));
Z7 = Vnorm_array3(cross(X7,Y7));
% Store segment coordinate system
Trial.Vmarker(29).label             = 'LFOOT_X';
Trial.Vmarker(29).Trajectory.smooth = permute(LAJC+X7*10e-2,[3,1,2]);
Trial.Vmarker(30).label             = 'LFOOT_Y';
Trial.Vmarker(30).Trajectory.smooth = permute(LAJC+Y7*10e-2,[3,1,2]);
Trial.Vmarker(31).label             = 'LFOOT_Z';
Trial.Vmarker(31).Trajectory.smooth = permute(LAJC+Z7*10e-2,[3,1,2]);
% Foot parameters (Dumas and Chèze 2007)
rP7                        = LAJC;
rD7                        = LMJC;
w7                         = Z7;
u7                         = X7;
Trial.Segment(7).Q.smooth  = [u7;rP7;rD7;w7];
Trial.Segment(7).rM.smooth = [LHEE,LTOE,LFMH,LVMH,LSMH];
Trial.Segment(7).rM.label  = {'LHEE','LTOE','LFMH','LVMV','LSMH'};
Trial.Segment(7).wM        = [Trial.Marker(40).IKweight,...
                              Trial.Marker(41).IKweight,...
                              Trial.Marker(42).IKweight,...
                              Trial.Marker(44).IKweight,...
                              Trial.Marker(43).IKweight];