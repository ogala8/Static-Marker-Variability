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
% Description  : Compute a set of parameters related to the flexion
%                relaxation phenomenom
% -------------------------------------------------------------------------
% Dependencies : To be defined
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% INIT THE WORKSPACE
% -------------------------------------------------------------------------
clearvars;
close all;
clc;

% -------------------------------------------------------------------------
% SET FOLDERS
% -------------------------------------------------------------------------
disp('Set folders');
Folder.toolbox      = 'C:\Users\moissene\Documents\Professionnel\projets recherche\2019 - NSCLBP - Biomarkers\Données\NSLBP-BIO_Toolbox\';
Folder.data         = 'C:\Users\moissene\Documents\Professionnel\projets recherche\2019 - NSCLBP - Biomarkers\Données\FRP Anais\DataKevin\NSLBP 001\';
Folder.dependencies = [Folder.toolbox,'dependencies\'];
addpath(Folder.toolbox);
addpath(genpath(Folder.dependencies));

% -------------------------------------------------------------------------
% LOAD C3D FILES
% -------------------------------------------------------------------------
disp('Extract data from C3D files');
trialTypes = {'Trunk_Forward','XDMNN'};
cd(Folder.data);
c3dFiles = dir('*.c3d');
k        = 1;
for i = 1:size(c3dFiles,1)
    for j = 1:size(trialTypes,2)
        if ~isempty(strfind(c3dFiles(i).name,trialTypes{j}))
            disp(['  - ',c3dFiles(i).name]);
            Trial(k).type    = trialTypes{j};
            Trial(k).file    = c3dFiles(i).name;
            Trial(k).btk     = btkReadAcquisition(c3dFiles(i).name);
            Trial(k).n0      = btkGetFirstFrame(Trial(k).btk);
            Trial(k).n1      = btkGetLastFrame(Trial(k).btk)-Trial(k).n0+1;
            Trial(k).fmarker = btkGetPointFrequency(Trial(k).btk);
            Trial(k).fanalog = btkGetAnalogFrequency(Trial(k).btk);
            Marker           = btkGetMarkers(Trial(k).btk);
            Event            = btkGetEvents(Trial(k).btk);
            k                = k+1;
        end
    end
end
% Clear workspace
clear trialTypes c3dFiles i j k;

% -------------------------------------------------------------------------
% COMPUTE PARAMETERS
% -------------------------------------------------------------------------

% Parameter(1)
% Full spine range of motion 
% Adapted from Hidalgo et al. 2012
% -------------------------------------------------------------------------
% Initialisation
Parameter(1).label      = 'Full spine range of motion';
Parameter(1).units      = '°deg';
Parameter(1).timeseries = [];
Parameter(1).value      = [];
% Get marker trajectories
C7 = Marker.C7;
S1 = Marker.S1;
% Get movement plane
start   = fix(Event.start*Trial.fmarker);
stop    = fix(Event.back*Trial.fmarker);
[~,ind] = max(C7(stop(1),1:2)-C7(start(1),1:2)); % Z assumed vertical
% Compute parameter during the whole recording
if ind == 1 % XZ plane
    Xp = C7(:,1);
    Xd = S1(:,1);
    Zp = C7(:,3);
    Zd = S1(:,3);
    for t = 1:Trial.n1
        Parameter(1).timeseries(t,:) = rad2deg(atan2(Xp(t,:)-Xd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Xp(start(1),:)-Xd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
elseif ind == 2 % YZ plane
    Yp = C7(:,2);
    Yd = S1(:,2);
    Zp = C7(:,3);
    Zd = S1(:,3);
    for t = 1:Trial.n1
        Parameter(1).timeseries(t,:) = rad2deg(atan2(Yp(t,:)-Yd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Yp(start(1),:)-Yd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
end
% Extract values of interest
Parameter(1).value.data = [Parameter(1).timeseries(stop(1))-Parameter(1).timeseries(start(1)) ...
                           Parameter(1).timeseries(stop(2))-Parameter(1).timeseries(start(2)) ...
                           Parameter(1).timeseries(stop(3))-Parameter(1).timeseries(start(3))];
Parameter(1).value.mean = mean(Parameter(1).value.data);
Parameter(1).value.std  = std(Parameter(1).value.data);
% Plot timeseries
% figure; hold on;
% plot(Parameter(1).timeseries,'red');
% Clear workspace
clear C7 S1 start stop ind Xd Yd Zd Xp Yp Zp t;

% Parameter(2)
% Full thoracic spine range of motion 
% Adapted from Hidalgo et al. 2012
% -------------------------------------------------------------------------
% Initialisation
Parameter(2).label      = 'Full thoracic spine range of motion';
Parameter(2).units      = '°deg';
Parameter(2).timeseries = [];
Parameter(2).value      = [];
% Get marker trajectories
C7  = Marker.C7;
T10 = Marker.T10;
% Get movement plane
start   = fix(Event.start*Trial.fmarker);
stop    = fix(Event.back*Trial.fmarker);
[~,ind] = max(C7(stop(1),1:2)-C7(start(1),1:2)); % Z assumed vertical
% Compute parameter during the whole recording
if ind == 1 % XZ plane
    Xp = C7(:,1);
    Xd = T10(:,1);
    Zp = C7(:,3);
    Zd = T10(:,3);
    for t = 1:Trial.n1
        Parameter(2).timeseries(t,:) = rad2deg(atan2(Xp(t,:)-Xd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Xp(start(1),:)-Xd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
elseif ind == 2 % YZ plane
    Yp = C7(:,2);
    Yd = T10(:,2);
    Zp = C7(:,3);
    Zd = T10(:,3);
    for t = 1:Trial.n1
        Parameter(2).timeseries(t,:) = rad2deg(atan2(Yp(t,:)-Yd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Yp(start(1),:)-Yd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
end
% Extract values of interest
Parameter(2).value.data = [Parameter(2).timeseries(stop(1))-Parameter(2).timeseries(start(1)) ...
                           Parameter(2).timeseries(stop(2))-Parameter(2).timeseries(start(2)) ...
                           Parameter(2).timeseries(stop(3))-Parameter(2).timeseries(start(3))];
Parameter(2).value.mean = mean(Parameter(2).value.data);
Parameter(2).value.std  = std(Parameter(2).value.data);
% Plot timeseries
% figure; hold on; 
% plot(Parameter(2).timeseries,'green');
% Clear workspace
clear C7 T10 start stop ind Xd Yd Zd Xp Yp Zp t;

% Parameter(3)
% Upper thoracic spine range of motion 
% Adapted from Hidalgo et al. 2012
% -------------------------------------------------------------------------
% Initialisation
Parameter(3).label      = 'Upper thoracic spine range of motion';
Parameter(3).units      = '°deg';
Parameter(3).timeseries = [];
Parameter(3).value      = [];
% Get marker trajectories
C7 = Marker.C7;
T6 = Marker.T6;
% Get movement plane
start   = fix(Event.start*Trial.fmarker);
stop    = fix(Event.back*Trial.fmarker);
[~,ind] = max(C7(stop(1),1:2)-C7(start(1),1:2)); % Z assumed vertical
% Compute parameter during the whole recording
if ind == 1 % XZ plane
    Xp = C7(:,1);
    Xd = T6(:,1);
    Zp = C7(:,3);
    Zd = T6(:,3);
    for t = 1:Trial.n1
        Parameter(3).timeseries(t,:) = rad2deg(atan2(Xp(t,:)-Xd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Xp(start(1),:)-Xd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
elseif ind == 2 % YZ plane
    Yp = C7(:,2);
    Yd = T6(:,2);
    Zp = C7(:,3);
    Zd = T6(:,3);
    for t = 1:Trial.n1
        Parameter(3).timeseries(t,:) = rad2deg(atan2(Yp(t,:)-Yd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Yp(start(1),:)-Yd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
end
% Extract values of interest
Parameter(3).value.data = [Parameter(3).timeseries(stop(1))-Parameter(3).timeseries(start(1)) ...
                           Parameter(3).timeseries(stop(2))-Parameter(3).timeseries(start(2)) ...
                           Parameter(3).timeseries(stop(3))-Parameter(3).timeseries(start(3))];
Parameter(3).value.mean = mean(Parameter(3).value.data);
Parameter(3).value.std  = std(Parameter(3).value.data);
% Plot timeseries
% figure; hold on;
% plot(Parameter(3).timeseries,'green');
% Clear workspace
clear C7 T6 start stop ind Xd Yd Zd Xp Yp Zp t;

% Parameter(4)
% Lower thoracic spine range of motion 
% Adapted from Hidalgo et al. 2012
% -------------------------------------------------------------------------
% Initialisation
Parameter(4).label      = 'Lower thoracic spine range of motion';
Parameter(4).units      = '°deg';
Parameter(4).timeseries = [];
Parameter(4).value      = [];
% Get marker trajectories
T6  = Marker.T6;
T10 = Marker.T10;
% Get movement plane
start   = fix(Event.start*Trial.fmarker);
stop    = fix(Event.back*Trial.fmarker);
[~,ind] = max(T6(stop(1),1:2)-T6(start(1),1:2)); % Z assumed vertical
% Compute parameter during the whole recording
if ind == 1 % XZ plane
    Xp = T6(:,1);
    Xd = T10(:,1);
    Zp = T6(:,3);
    Zd = T10(:,3);
    for t = 1:Trial.n1
        Parameter(4).timeseries(t,:) = rad2deg(atan2(Xp(t,:)-Xd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Xp(start(1),:)-Xd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
elseif ind == 2 % YZ plane
    Yp = T6(:,2);
    Yd = T10(:,2);
    Zp = T6(:,3);
    Zd = T10(:,3);
    for t = 1:Trial.n1
        Parameter(4).timeseries(t,:) = rad2deg(atan2(Yp(t,:)-Yd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Yp(start(1),:)-Yd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
end
% Extract values of interest
Parameter(4).value.data = [Parameter(4).timeseries(stop(1))-Parameter(4).timeseries(start(1)) ...
                           Parameter(4).timeseries(stop(2))-Parameter(4).timeseries(start(2)) ...
                           Parameter(4).timeseries(stop(3))-Parameter(4).timeseries(start(3))];
Parameter(4).value.mean = mean(Parameter(4).value.data);
Parameter(4).value.std  = std(Parameter(4).value.data);
% Plot timeseries
% figure; hold on;
% plot(Parameter(4).timeseries,'green');
% Clear workspace
clear T6 T10 start stop ind Xd Yd Zd Xp Yp Zp t;

% Parameter(5)
% Full lumbar spine range of motion 
% Adapted from Hidalgo et al. 2012
% -------------------------------------------------------------------------
% Initialisation
Parameter(5).label      = 'Full lumbar spine range of motion';
Parameter(5).units      = '°deg';
Parameter(5).timeseries = [];
Parameter(5).value      = [];
% Get marker trajectories
L1 = Marker.L1;
S1 = Marker.S1;
% Get movement plane
start   = fix(Event.start*Trial.fmarker);
stop    = fix(Event.back*Trial.fmarker);
[~,ind] = max(L1(stop(1),1:2)-L1(start(1),1:2)); % Z assumed vertical
% Compute parameter during the whole recording
if ind == 1 % XZ plane
    Xp = L1(:,1);
    Xd = S1(:,1);
    Zp = L1(:,3);
    Zd = S1(:,3);
    for t = 1:Trial.n1
        Parameter(5).timeseries(t,:) = rad2deg(atan2(Xp(t,:)-Xd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Xp(start(1),:)-Xd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
elseif ind == 2 % YZ plane
    Yp = L1(:,2);
    Yd = S1(:,2);
    Zp = L1(:,3);
    Zd = S1(:,3);
    for t = 1:Trial.n1
        Parameter(5).timeseries(t,:) = rad2deg(atan2(Yp(t,:)-Yd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Yp(start(1),:)-Yd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
end
% Extract values of interest
Parameter(5).value.data = [Parameter(5).timeseries(stop(1))-Parameter(5).timeseries(start(1)) ...
                           Parameter(5).timeseries(stop(2))-Parameter(5).timeseries(start(2)) ...
                           Parameter(5).timeseries(stop(3))-Parameter(5).timeseries(start(3))];
Parameter(5).value.mean = mean(Parameter(5).value.data);
Parameter(5).value.std  = std(Parameter(5).value.data);
% Plot timeseries
% figure; hold on;
% plot(Parameter(5).timeseries,'blue');
% Clear workspace
clear L1 S1 start stop ind Xd Yd Zd Xp Yp Zp t;

% Parameter(6)
% Upper lumbar spine range of motion 
% Adapted from Hidalgo et al. 2012
% -------------------------------------------------------------------------
% Initialisation
Parameter(6).label      = 'Upper lumbar spine range of motion';
Parameter(6).units      = '°deg';
Parameter(6).timeseries = [];
Parameter(6).value      = [];
% Get marker trajectories
L1 = Marker.L1;
L3 = Marker.L3;
% Get movement plane
start   = fix(Event.start*Trial.fmarker);
stop    = fix(Event.back*Trial.fmarker);
[~,ind] = max(L1(stop(1),1:2)-L1(start(1),1:2)); % Z assumed vertical
% Compute parameter during the whole recording
if ind == 1 % XZ plane
    Xp = L1(:,1);
    Xd = L3(:,1);
    Zp = L1(:,3);
    Zd = L3(:,3);
    for t = 1:Trial.n1
        Parameter(6).timeseries(t,:) = rad2deg(atan2(Xp(t,:)-Xd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Xp(start(1),:)-Xd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
elseif ind == 2 % YZ plane
    Yp = L1(:,2);
    Yd = L3(:,2);
    Zp = L1(:,3);
    Zd = L3(:,3);
    for t = 1:Trial.n1
        Parameter(6).timeseries(t,:) = rad2deg(atan2(Yp(t,:)-Yd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Yp(start(1),:)-Yd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
end
% Extract values of interest
Parameter(6).value.data = [Parameter(6).timeseries(stop(1))-Parameter(6).timeseries(start(1)) ...
                           Parameter(6).timeseries(stop(2))-Parameter(6).timeseries(start(2)) ...
                           Parameter(6).timeseries(stop(3))-Parameter(6).timeseries(start(3))];
Parameter(6).value.mean = mean(Parameter(6).value.data);
Parameter(6).value.std  = std(Parameter(6).value.data);
% Plot timeseries
% figure; hold on;
% plot(Parameter(6).timeseries,'blue');
% Clear workspace
clear L1 L3 start stop ind Xd Yd Zd Xp Yp Zp t;

% Parameter(7)
% Lower lumbar spine range of motion 
% Adapted from Hidalgo et al. 2012
% -------------------------------------------------------------------------
% Initialisation
Parameter(7).label      = 'Lower lumbar spine range of motion';
Parameter(7).units      = '°deg';
Parameter(7).timeseries = [];
Parameter(7).value      = [];
% Get marker trajectories
L3 = Marker.L3;
S1 = Marker.S1;
% Get movement plane
start   = fix(Event.start*Trial.fmarker);
stop    = fix(Event.back*Trial.fmarker);
[~,ind] = max(L3(stop(1),1:2)-L3(start(1),1:2)); % Z assumed vertical
% Compute parameter during the whole recording
if ind == 1 % XZ plane
    Xp = L3(:,1);
    Xd = S1(:,1);
    Zp = L3(:,3);
    Zd = S1(:,3);
    for t = 1:Trial.n1
        Parameter(7).timeseries(t,:) = rad2deg(atan2(Xp(t,:)-Xd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Xp(start(1),:)-Xd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
elseif ind == 2 % YZ plane
    Yp = L3(:,2);
    Yd = S1(:,2);
    Zp = L3(:,3);
    Zd = S1(:,3);
    for t = 1:Trial.n1
        Parameter(7).timeseries(t,:) = rad2deg(atan2(Yp(t,:)-Yd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Yp(start(1),:)-Yd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
end
% Extract values of interest
Parameter(7).value.data = [Parameter(7).timeseries(stop(1))-Parameter(7).timeseries(start(1)) ...
                           Parameter(7).timeseries(stop(2))-Parameter(7).timeseries(start(2)) ...
                           Parameter(7).timeseries(stop(3))-Parameter(7).timeseries(start(3))];
Parameter(7).value.mean = mean(Parameter(7).value.data);
Parameter(7).value.std  = std(Parameter(7).value.data);
% Plot timeseries
% figure; hold on;
% plot(Parameter(7).timeseries,'blue');
% Clear workspace
clear L3 S1 start stop ind Xd Yd Zd Xp Yp Zp t;

% Parameter(8)
% Pelvis tilt range of motion 
% Adapted from Nbblett et al. 2014
% -------------------------------------------------------------------------
% Initialisation
Parameter(8).label      = 'Pelvis tilt range of motion';
Parameter(8).units      = '°deg';
Parameter(8).timeseries = [];
Parameter(8).value      = [];
% Get marker trajectories
RASI = Marker.RASI;
LASI = Marker.LASI;
RPSI = Marker.RPSI;
LPSI = Marker.LPSI;
mASI = (RASI+LASI)/2;
mPSI = (RPSI+LPSI)/2;
% Get movement plane
start   = fix(Event.start*Trial.fmarker);
stop    = fix(Event.back*Trial.fmarker);
[~,ind] = max(mASI(start(1),1:2)-mPSI(start(1),1:2)); % Z assumed vertical
% Compute parameter during the whole recording
if ind == 1 % XZ plane
    Xp = mPSI(:,1);
    Xd = mASI(:,1);
    Zp = mPSI(:,3);
    Zd = mASI(:,3);
    for t = 1:Trial.n1
        Parameter(8).timeseries(t,:) = rad2deg(atan2(Xp(t,:)-Xd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Xp(start(1),:)-Xd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
elseif ind == 2 % YZ plane
    Yp = L1(:,2);
    Yd = L3(:,2);
    Zp = L1(:,3);
    Zd = L3(:,3);
    for t = 1:Trial.n1
        Parameter(8).timeseries(t,:) = rad2deg(atan2(Yp(t,:)-Yd(t,:),Zp(t,:)-Zd(t,:))) - ...
                                       rad2deg(atan2(Yp(start(1),:)-Yd(start(1),:),Zp(start(1),:)-Zd(start(1),:)));
    end
end
% Extract values of interest
Parameter(8).value.data = [max(Parameter(8).timeseries(start(1)+300:start(2)-300)) ...
                           max(Parameter(8).timeseries(start(2)+300:start(3)-300)) ...
                           max(Parameter(8).timeseries(start(3)+300:start(4)-300))];
Parameter(8).value.mean = mean(Parameter(8).value.data);
Parameter(8).value.std  = std(Parameter(8).value.data);
% Plot timeseries
% figure; hold on;
% plot(Parameter(8).timeseries,'red');
% Clear workspace
clear RASI LASI RPSI LPSI mASI mPSI Xp Xd Yp Yd Zp Zd start stop ind vec1 vec2 t;

% Parameter(9)
% Contribution of full lumbar spine in full thoracic spine range of motion 
% Adapted from Laird et al. 2016
% -------------------------------------------------------------------------
% Initialisation
Parameter(9).label      = 'Contribution of full lumbar spine in full thoracic spine range of motion';
Parameter(9).units      = '%';
Parameter(9).timeseries = [];
Parameter(9).value      = [];
% Extract values of interest
Parameter(9).value.data = [Parameter(5).value.data(1)*100/Parameter(2).value.data(1) ...
                           Parameter(5).value.data(2)*100/Parameter(2).value.data(2) ...
                           Parameter(5).value.data(3)*100/Parameter(2).value.data(3)];
Parameter(9).value.mean = mean(Parameter(9).value.data);
Parameter(9).value.std  = std(Parameter(9).value.data);

% Parameter(10)
% Angular velocity amplitude of the full lumbar spine 
% Adapted from Hidaldo et al. 2012
% -------------------------------------------------------------------------
% Initialisation
Parameter(10).label      = 'Angular velocity amplitude of the full lumbar spine';
Parameter(10).units      = '°deg/s';
Parameter(10).timeseries = [];
Parameter(10).value      = [];
% Get events
start = fix(Event.start*Trial.fmarker);
stop  = fix(Event.back*Trial.fmarker);
% Compute parameter during the whole recording
Parameter(10).timeseries = gradient(Parameter(5).timeseries)*Trial.fmarker;
% Extract values of interest
Parameter(10).value.data = [max(Parameter(10).timeseries(start(1):start(2)))-min(Parameter(10).timeseries(start(1):start(2))) ...
                            max(Parameter(10).timeseries(start(2):start(3)))-min(Parameter(10).timeseries(start(2):start(3))) ...
                            max(Parameter(10).timeseries(start(3):start(4)))-min(Parameter(10).timeseries(start(3):start(4)))];
Parameter(10).value.mean = mean(Parameter(10).value.data);
Parameter(10).value.std  = std(Parameter(10).value.data);
% Plot timeseries
% figure; hold on;
% plot(Parameter(10).timeseries,'red');
% Clear workspace
clear start stop;

% Parameter(11)
% Angular velocity amplitude of the upper lumbar spine 
% Adapted from Hidaldo et al. 2012
% -------------------------------------------------------------------------
% Initialisation
Parameter(11).label      = 'Angular velocity amplitude of the upper lumbar spine';
Parameter(11).units      = '°deg/s';
Parameter(11).timeseries = [];
Parameter(11).value      = [];
% Get events
start = fix(Event.start*Trial.fmarker);
stop  = fix(Event.back*Trial.fmarker);
% Compute parameter during the whole recording
Parameter(11).timeseries = gradient(Parameter(6).timeseries)*Trial.fmarker;
% Extract values of interest
Parameter(11).value.data = [max(Parameter(11).timeseries(start(1):start(2)))-min(Parameter(11).timeseries(start(1):start(2))) ...
                            max(Parameter(11).timeseries(start(2):start(3)))-min(Parameter(11).timeseries(start(2):start(3))) ...
                            max(Parameter(11).timeseries(start(3):start(4)))-min(Parameter(11).timeseries(start(3):start(4)))];
Parameter(11).value.mean = mean(Parameter(11).value.data);
Parameter(11).value.std  = std(Parameter(11).value.data);
% Plot timeseries
% figure; hold on;
% plot(Parameter(11).timeseries,'red');
% Clear workspace
clear start stop;

% Parameter(12)
% Angular velocity amplitude of the lower lumbar spine 
% Adapted from Hidaldo et al. 2012
% -------------------------------------------------------------------------
% Initialisation
Parameter(12).label      = 'Angular velocity amplitude of the lower lumbar spine';
Parameter(12).units      = '°deg/s';
Parameter(12).timeseries = [];
Parameter(12).value      = [];
% Get events
start = fix(Event.start*Trial.fmarker);
stop  = fix(Event.back*Trial.fmarker);
% Compute parameter during the whole recording
Parameter(12).timeseries = gradient(Parameter(7).timeseries)*Trial.fmarker;
% Extract values of interest
Parameter(12).value.data = [max(Parameter(12).timeseries(start(1):start(2)))-min(Parameter(12).timeseries(start(1):start(2))) ...
                            max(Parameter(12).timeseries(start(2):start(3)))-min(Parameter(12).timeseries(start(2):start(3))) ...
                            max(Parameter(12).timeseries(start(3):start(4)))-min(Parameter(12).timeseries(start(3):start(4)))];
Parameter(12).value.mean = mean(Parameter(12).value.data);
Parameter(12).value.std  = std(Parameter(12).value.data);
% Plot timeseries
% figure; hold on;
% plot(Parameter(12).timeseries,'red');
% Clear workspace
clear start stop;

% Parameter(13)
% Lumbar spine length ratio between full flexion and standing
% No reference
% -------------------------------------------------------------------------
% Initialisation
Parameter(13).label      = 'Lumbar spine length ratio between full flexion and standing';
Parameter(13).units      = '';
Parameter(13).timeseries = [];
Parameter(13).value      = [];
% Get marker trajectories
T10 = Marker.T10;
L1  = Marker.L1;
L3  = Marker.L3;
L5  = Marker.L5;
S1  = Marker.S1;
% Get events
start = fix(Event.start*Trial.fmarker);
stop  = fix(Event.back*Trial.fmarker);
% Compute parameter during the whole recording
Parameter(13).timeseries = sqrt(sum((T10-L1).^2,2)) + ...
                           sqrt(sum((L1-L3).^2,2)) + ...
                           sqrt(sum((L3-L5).^2,2)) + ...
                           sqrt(sum((L5-S1).^2,2));
% Extract values of interest
Parameter(13).value.data = [Parameter(13).timeseries(stop(1))/Parameter(13).timeseries(start(1)) ...
                            Parameter(13).timeseries(stop(2))/Parameter(13).timeseries(start(2)) ...
                            Parameter(13).timeseries(stop(3))/Parameter(13).timeseries(start(3))];
Parameter(13).value.mean = mean(Parameter(13).value.data);
Parameter(13).value.std  = std(Parameter(13).value.data);
% Plot timeseries
% figure; hold on;
plot(Parameter(13).timeseries,'red');
% Clear workspace
clear L1 L3 L5 T10 S1 start stop;