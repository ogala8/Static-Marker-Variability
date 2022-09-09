% Author       : Omar Galarraga
%                Florent Moissenet
%                Mordjane Sahrane
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : https://github.com/ogala8/Static-Marker-Variability
% Reference    : To be defined
% Date         : June 2022
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

function [error, Static, Segment] = Copy_2_of_MAIN(Participant, markersettype, fstatic1, fstatic2, varargin)
% -------------------------------------------------------------------------
% INIT THE WORKSPACE
% -------------------------------------------------------------------------
%clearvars;
%close all;
%clc;

if nargin > 4
    IKweight = varargin{1};
end

% Participant.id = 'Omar'; %'Mickael3000';
% markersettype = 'ISBlike'; %CGM1.0 ou CGM2.4 ou ISBlike
% if strcmp(Participant.id, 'Mickael3000')
%    markersettype = 'CGM1.0';
% end
% fstatic1 = 1;
% fstatic2 = 2;

% -------------------------------------------------------------------------
% SET FOLDERS
% -------------------------------------------------------------------------
disp('Set folders');
Folder.toolbox      = 'C:\Users\mordj\Documents\Projet_stage_UGECAM\Static-Marker-Variability\Static-Marker-Variability-dev_IK\';
if strcmp(Participant.id, 'Oscar')
    Folder.data         = 'C:\Users\Omar\Documents\StaticVariability\DataTest\';
elseif strcmp(Participant.id, 'Mickael3000')
    Folder.data         = 'C:\Users\Omar\Documents\StaticVariability\DataMickael\Test\';
elseif strcmp(Participant.id, 'Omar')
    %Folder.data  = 'C:\Users\mordj\Documents\Projet_stage_UGECAM\Static-Marker-Variability\Static-Marker-Variability-dev_IK\Data\';
    %Folder.data  = 'C:\Users\mordj\Documents\Projet_stage_UGECAM\Static-Marker-Variability\Static-Marker-Variability-dev_IK\Data_misplacement_10mm_jambeG\';
    Folder.data  = 'C:\Users\mordj\Documents\Projet_stage_UGECAM\Static-Marker-Variability\Static-Marker-Variability-dev_IK\Data_misplacement_5mm\';

    %'C:\Users\Omar\Documents\StaticVariability\DataOmarTest\';
end
Folder.dependencies = [Folder.toolbox,'dependencies\'];
addpath(Folder.toolbox);
addpath(genpath(Folder.dependencies));

% -------------------------------------------------------------------------
% DEFINE PARTICIPANT
% -------------------------------------------------------------------------
disp('Set participant parameters');
if strcmp(Participant.id, 'Oscar') 
    Participant.type         = '';
    Participant.gender       = 'Male'; % Female / Male
    Participant.inclusionAge = NaN; % years
    Participant.pelvisWidth  = 0.245; % m
    Participant.RLegLength   = 0.67; % m
    Participant.LLegLength   = 0.675; % m
    Participant.RKneeWidth   = 0.085; % m
    Participant.LKneeWidth   = 0.08; % m
    Participant.RAnkleWidth  = 0.065; % m
    Participant.LAnkleWidth  = 0.07; % m
elseif strcmp(Participant.id, 'Mickael3000')
    Participant.type         = '';
    Participant.gender       = 'Male'; % Female / Male
    Participant.inclusionAge = 6; % years
    Participant.pelvisWidth  = 0.016; % m
    Participant.RLegLength   = 0.055; % m
    Participant.LLegLength   = 0.056; % m
    Participant.RKneeWidth   = 0.008; % m
    Participant.LKneeWidth   = 0.008; % m
    Participant.RAnkleWidth  = 0.005; % m
    Participant.LAnkleWidth  = 0.0055; % m
elseif strcmp(Participant.id, 'Omar')
    Participant.type         = '';
    Participant.gender       = 'Male'; % Female / Male
    Participant.inclusionAge = 32; % years
    Participant.pelvisWidth  = 0.20; % m
    Participant.RLegLength   = 0.91; % m
    Participant.LLegLength   = 0.90; % m
    Participant.RKneeWidth   = 0.095; % m
    Participant.LKneeWidth   = 0.095; % m
    Participant.RAnkleWidth  = 0.07; % m
    Participant.LAnkleWidth  = 0.07; % m
end
% -------------------------------------------------------------------------
% DEFINE SESSION
% -------------------------------------------------------------------------
disp('Set session parameters');
Session.date              = '';
Session.type              = '';
Session.examiner          = '';
if strcmp(Participant.id, 'Oscar')
    Session.participantHeight = NaN; % cm %Oscar
    Session.participantWeight = NaN; % kg %Oscar
elseif strcmp(Participant.id, 'Mickael3000')
    Session.participantHeight = 119; % cm
    Session.participantWeight = 21; % kg
elseif strcmp(Participant.id, 'Omar')
    Session.participantHeight = 172; % cm
    Session.participantWeight = 61; % kg
end
Session.markerHeight      = 0.014; % m

% -------------------------------------------------------------------------
% LOAD C3D FILES
% -------------------------------------------------------------------------
disp('Extract data from C3D files');

% List all trial types
if strcmp(Participant.id, 'Oscar') 
    trialTypes = {'Static_Oscar'};
    seltype = 'Static_Oscar';
elseif strcmp(Participant.id, 'Mickael3000')
    trialTypes = {'Static_Mickael'};
    seltype = 'Static_Mickael';
elseif strcmp(Participant.id, 'Omar')
    trialTypes = {'StaticOmar'};
    seltype = 'StaticOmar';
end

% Extract data from C3D files
cd(Folder.data);
c3dFiles = dir('*.c3d');
k1       = 1;
k2       = 1;
for i = 1:size(c3dFiles,1)
    disp(['  - ',c3dFiles(i).name]);
    for j = 1:size(trialTypes,2)
        if ~isempty(strfind(c3dFiles(i).name,trialTypes{j}))
            if ~isempty(strfind(trialTypes{j},seltype)) == 1
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
    btkCloseAcquisition(Static(i).btk);
    Static(i).Marker  = [];
    Static(i).Vmarker = [];
    Static(i).Segment = [];
    Static(i).Joint   = [];
    if exist('IKweight','var')
        Static(i)         = InitialiseMarkerTrajectories(Static(i),Marker, IKweight);
    else
        Static(i)         = InitialiseMarkerTrajectories(Static(i),Marker);
    end
    Static(i)         = InitialiseVmarkerTrajectories(Static(i));
    Static(i)         = InitialiseSegments(Static(i));
    Static(i)         = InitialiseJoints(Static(i));
    Static(i)         = ProcessMarkerTrajectories([],Static(i));
    if strcmp(markersettype, 'ISBlike') 
        Static(i)         = DefineSegments_ISB(Session,Participant,[],Static(i));
    elseif strcmp(markersettype, 'CGM1.0')
        Static(i)         = DefineSegments_CGM10_NoHJC(Session,Participant,[],Static(i));
    elseif strcmp(markersettype, 'CGM2.4')
        Static(i)         = DefineSegments_CGM24(Session,Participant,[],Static(i));
    end
    clear Marker;
    %keyboard;
    % Store processed static data in a new C3D file
    mkdir('output');
    ExportC3D(Static(i),[],Participant,Session,Folder);
end

%% ------------------------------------------------------------------------
% BUILD MODEL
% -------------------------------------------------------------------------
%keyboard;
% Define the Static to be used as measured marker position
iStatic = fstatic1;

% Prepare the Segment structure used to define the local marker position
% based on Static 1
for i = 1:5
    Segment(i).Q   = Static(iStatic).Segment(i).Q.smooth;
    Segment(i).rM  = Static(iStatic).Segment(i).rM.smooth;
    if i > 1
        Segment(i).rM_label  = Static(iStatic).Segment(i).rM.label;    
    end
    Segment(i).wM  = Static(iStatic).Segment(i).wM;
    Segment(i).rM0 = Static(iStatic).Segment(i).rM.smooth; % Store as initial posture before correction
end
j = 6;
for i = 9:-1:7    
    Segment(j).Q          = Static(iStatic).Segment(i).Q.smooth;
    Segment(j).Q(4:6,:,:) = Static(iStatic).Segment(i).Q.smooth(7:9,:,:); % Exchange rP and rD to get a continuous kinematic chain from right foot to left foot
    Segment(j).Q(7:9,:,:) = Static(iStatic).Segment(i).Q.smooth(4:6,:,:);
    Segment(j).rM         = Static(iStatic).Segment(i).rM.smooth;
    Segment(j).rM_label   = Static(iStatic).Segment(i).rM.label;    
    Segment(j).wM         = Static(iStatic).Segment(i).wM;
    Segment(j).rM0        = Static(iStatic).Segment(i).rM.smooth; % Store as initial posture before correction
    j                     = j+1;
end

% Compute local marker position in each segment (nM)
Segment = Multibody_Optimisation_SSS_Static(Segment);
%Segment = Multibody_Optimisation_SSS_Static_L1(Segment);

% -------------------------------------------------------------------------
% PROCESS INVERSE KINEMATICS
% -------------------------------------------------------------------------

% Define the Static to be used as measured marker position
iStatic = fstatic2;

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
Segment = Multibody_Optimisation_SSS_Static(Segment);

% -------------------------------------------------------------------------
% PLOT RESULTS
% -------------------------------------------------------------------------
% figure;
for i = 2:8
    for j = 1:size(Segment(i).rM,2)
        NMij = [Segment(i).nM(1,j)*eye(3),...
            (1 + Segment(i).nM(2,j))*eye(3), ...
            - Segment(i).nM(2,j)*eye(3), ...
            Segment(i).nM(3,j)*eye(3)];
        Segment(i).rM2(:,j) = Mprod_array3(repmat(NMij,[1,1,n]),Segment(i).Q);
%         plot3(Segment(i).rM0(1,j),Segment(i).rM0(2,j),Segment(i).rM0(3,j),...
%               'Marker','o','Color','black');
%         hold on;
%         axis equal;  
%         plot3(Segment(i).rM(1,j),Segment(i).rM(2,j),Segment(i).rM(3,j),...
%               'Marker','^','Color','red');
%         plot3(Segment(i).rM2(1,j),Segment(i).rM2(2,j),Segment(i).rM2(3,j),...
%               'Marker','x','Color','blue');
%         legend({'Reference', 'Original', 'Alignment'});  
        error(:,j,i) = Segment(i).rM2(:,j)-Segment(i).rM(:,j);
    end
end
disp(['Static1: ', Static(fstatic1).file])
disp(['Static2: ', Static(fstatic2).file])
disp(['Mean error (mm): ',num2str(1e3*mean(abs(error(:))))]);
disp(['Std error (mm): ',num2str(1e3*std(abs(error(:))))]);
disp(['Max error (mm): ',num2str(1e3*max(abs(error(:))))]);
cd(Folder.toolbox)