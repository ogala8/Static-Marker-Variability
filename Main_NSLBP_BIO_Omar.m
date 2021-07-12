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
% Description  : Main routine used to launch NSLBP-BIO routines
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
Folder.data         = 'C:\Users\moissene\Documents\Professionnel\publications\articles\1- en cours\Galarraga - 2021\Data\';
Folder.biomarkers   = 'C:\Users\moissene\Documents\Professionnel\projets recherche\2019 - NSCLBP - Biomarkers\Données\NSLBP-BIO_Toolbox\data\';
Folder.export       = [Folder.data,'\output\'];
Folder.dependencies = [Folder.toolbox,'dependencies\'];
addpath(Folder.toolbox);
addpath(genpath(Folder.dependencies));

% -------------------------------------------------------------------------
% DEFINE PARTICIPANT
% -------------------------------------------------------------------------
disp('Set participant parameters');
Participant.id           = '';
Participant.type         = '';
Participant.gender       = 'Male'; % Female / Male
Participant.inclusionAge = NaN; % years
Participant.pelvisWidth  = NaN; % m
Participant.RLegLength   = NaN; % m
Participant.LLegLength   = NaN; % m
Participant.RKneeWidth   = NaN; % m
Participant.LKneeWidth   = NaN; % m
Participant.RAnkleWidth  = NaN; % m
Participant.LAnkleWidth  = NaN; % m

% -------------------------------------------------------------------------
% DEFINE SESSION
% -------------------------------------------------------------------------
disp('Set session parameters');
Session.date              = '';
Session.type              = '';
Session.examiner          = '';
Session.participantHeight = NaN; % cm
Session.participantWeight = NaN; % kg
Session.markerHeight      = 0.014; % m

% -------------------------------------------------------------------------
% LOAD C3D FILES
% -------------------------------------------------------------------------
disp('Extract data from C3D files');

% List all trial types
trialTypes = {'Static_Oscar'};

% Extract data from C3D files
cd(Folder.data);
c3dFiles = dir('*.c3d');
k1       = 1;
k2       = 1;
for i = 1:size(c3dFiles,1)
    disp(['  - ',c3dFiles(i).name]);
    for j = 1:size(trialTypes,2)
        if ~isempty(strfind(c3dFiles(i).name,trialTypes{j}))
            if ~isempty(strfind(trialTypes{j},'Static_Oscar')) == 1
                Static(k1).type    = trialTypes{j};
                Static(k1).file    = c3dFiles(i).name;
                Static(k1).btk     = btkReadAcquisition(c3dFiles(i).name);
                Static(k1).n0      = btkGetFirstFrame(Static(k1).btk);
                Static(k1).n1      = btkGetLastFrame(Static(k1).btk)-Static(k1).n0+1;
                Static(k1).fmarker = btkGetPointFrequency(Static(k1).btk);
                Static(k1).fanalog = btkGetAnalogFrequency(Static(k1).btk);
                k1 = k1+1;
            else
                Trial(k2).type    = trialTypes{j};
                Trial(k2).file    = c3dFiles(i).name;
                Trial(k2).btk     = btkReadAcquisition(c3dFiles(i).name);
                Trial(k2).n0      = btkGetFirstFrame(Trial(k2).btk);
                Trial(k2).n1      = btkGetLastFrame(Trial(k2).btk)-Trial(k2).n0+1;
                Trial(k2).fmarker = btkGetPointFrequency(Trial(k2).btk);
                Trial(k2).fanalog = btkGetAnalogFrequency(Trial(k2).btk);
                k2 = k2+1;
            end
        end
    end
end
clear k1 k2 c3dFiles trialTypes;

% -------------------------------------------------------------------------
% PRE-PROCESS DATA
% -------------------------------------------------------------------------

% Static data
disp('Pre-process static data');
for i = 1:size(Static,2)
    disp(['  - ',Static(i).file]);
    
    % Get manually defined events
    Static(i).Event = [];
    
    % Process marker trajectories
    Marker            = btkGetMarkers(Static(i).btk);
    Static(i).Marker  = [];
    Static(i).Vmarker = [];
    Static(i).Segment = [];
    Static(i).Joint   = [];
    Static(i)         = InitialiseMarkerTrajectories_Omar(Static(i),Marker);
    Static(i)         = InitialiseVmarkerTrajectories_Omar(Static(i));
    Static(i)         = InitialiseSegments(Static(i));
    Static(i)         = InitialiseJoints(Static(i));
    Static(i)         = ProcessMarkerTrajectories([],Static(i));
    Static(i)         = DefineSegments_Omar_ISB(Participant,[],Static(i));
    clear Marker;
    
    % Process EMG signals
    Static(i).EMG = [];
    
    % Process forceplate signals
    Static(i).GRF = [];
    
    % Store processed static data in a new C3D file
    mkdir('output');
    ExportC3D(Static(i),[],Participant,Session,Folder);
end


%%

% -------------------------------------------------------------------------
% BUILD MODEL
% -------------------------------------------------------------------------

% Define the Static to be used as measured marker position
iStatic = 6;

% Prepare the Segment structure used to define the local marker position
% based on Static 1
for i = 1:5
    Segment(i).Q   = Static(iStatic).Segment(i).Q.smooth;
    Segment(i).rM  = Static(iStatic).Segment(i).rM.smooth;
    Segment(i).rM0 = Static(iStatic).Segment(i).rM.smooth; % Store as initial posture before correction
end
j = 6;
for i = 9:-1:7    
    Segment(j).Q          = Static(iStatic).Segment(i).Q.smooth;
    Segment(j).Q(4:6,:,:) = Static(iStatic).Segment(i).Q.smooth(7:9,:,:); % Exchange rP and rD to get a continuous kinematic chain from right foot to left foot
    Segment(j).Q(7:9,:,:) = Static(iStatic).Segment(i).Q.smooth(4:6,:,:);
    Segment(j).rM         = Static(iStatic).Segment(i).rM.smooth;
    Segment(j).rM0        = Static(iStatic).Segment(i).rM.smooth; % Store as initial posture before correction
    j                     = j+1;
end

% Compute local marker position in each segment (nM)
Segment = Multibody_Optimisation_SSS_Omar(Segment);

% -------------------------------------------------------------------------
% PROCESS INVERSE KINEMATICS
% -------------------------------------------------------------------------

% Define the Static to be used as measured marker position
iStatic = 10;

% Prepare the Segment structure used to define the global marker position
% based on Static 2
for i = 1:5
    Segment(i).Q   = Static(iStatic).Segment(i).Q.smooth;
    Segment(i).rM  = Static(iStatic).Segment(i).rM.smooth;
end
j = 6;
for i = 9:-1:7
    Segment(j).Q          = Static(iStatic).Segment(i).Q.smooth;
    Segment(j).Q(4:6,:,:) = Static(iStatic).Segment(i).Q.smooth(7:9,:,:); % Exchange rP and rD to get a continuous kinematic chain from right foot to left foot
    Segment(j).Q(7:9,:,:) = Static(iStatic).Segment(i).Q.smooth(4:6,:,:);
    Segment(j).rM         = Static(iStatic).Segment(i).rM.smooth;
    j                     = j+1;
end
n = size(Segment(2).rM,3);

% Inverse kinematics
Segment = Multibody_Optimisation_SSS_Omar(Segment);

% -------------------------------------------------------------------------
% PLOT RESULTS
% -------------------------------------------------------------------------
figure;
for i = 2:5
    for j = 1:size(Segment(i).rM,2)
        NMij = [Segment(i).nM(1,j)*eye(3),...
            (1 + Segment(i).nM(2,j))*eye(3), ...
            - Segment(i).nM(2,j)*eye(3), ...
            Segment(i).nM(3,j)*eye(3)];
        Segment(i).rM2(:,j) = Mprod_array3(repmat(NMij,[1,1,n]),Segment(i).Q);
        plot3(Segment(i).rM0(1,j),Segment(i).rM0(2,j),Segment(i).rM0(3,j),...
              'Marker','o','Color','black');
        hold on;
        axis equal;  
        plot3(Segment(i).rM(1,j),Segment(i).rM(2,j),Segment(i).rM(3,j),...
              'Marker','o','Color','red');
        plot3(Segment(i).rM2(1,j),Segment(i).rM2(2,j),Segment(i).rM2(3,j),...
              'Marker','x','Color','blue');
          
        error(:,j,i) = Segment(i).rM2(:,j)-Segment(i).rM(:,j);
    end
end

