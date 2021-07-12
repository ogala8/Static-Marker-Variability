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
%Folder.data         = 'C:\Users\moissene\Documents\Professionnel\projets recherche\2019 - NSCLBP - Biomarkers\Données\FRP Anais\DataKevin_raw\NSLBP 003\20151207-LBP\';
Folder.biomarkers   = 'C:\Users\moissene\Documents\Professionnel\projets recherche\2019 - NSCLBP - Biomarkers\Données\NSLBP-BIO_Toolbox\data\';
% Folder.export       = [Folder.data,'\output\'];
Folder.dependencies = [Folder.toolbox,'dependencies\'];
addpath(Folder.toolbox);
addpath(genpath(Folder.dependencies));

% ONLY for Kevin data
participantList = {'001','002','003','005','006','007','008','009',...
                   '010','012','013','014','016','017','018','019',...
                   '020','021','022','024','026','027','028','029',...
                   '030','031','032','033','034','035','036','038','039',...
                   '040','041','042','044','045','046','047','048','049',...
                   '050','052','056',...
                   '063'};
for iparticipant = 1:size(participantList,2)
disp(participantList{iparticipant});
cd(['C:\Users\moissene\Documents\Professionnel\projets recherche\2019 - NSCLBP - Biomarkers\Données\FRP Anais\DataKevin_raw\NSLBP ',num2str(participantList{iparticipant}),'\']);
sessionFolder = dir('*-LBP*');
Folder.data   = [sessionFolder.folder,'\',sessionFolder.name,'\'];
Folder.export = [Folder.data,'\output\'];
Folder.data2  = ['C:\Users\moissene\Documents\Professionnel\projets recherche\2019 - NSCLBP - Biomarkers\Données\FRP Anais\DataKevin_raw\fiche sujet\',num2str(participantList{iparticipant}),'\'];

% -------------------------------------------------------------------------
% DEFINE PARTICIPANT
% -------------------------------------------------------------------------
disp('Set participant parameters');
% Participant.id           = '';
% Participant.type         = '';
% Participant.gender       = ''; % Female / Male
% Participant.inclusionAge = NaN; % years
% Participant.pelvisWidth  = NaN; % m
% Participant.RLegLength   = NaN; % m
% Participant.LLegLength   = NaN; % m
% Participant.RKneeWidth   = NaN; % m
% Participant.LKneeWidth   = NaN; % m
% Participant.RAnkleWidth  = NaN; % m
% Participant.LAnkleWidth  = NaN; % m
% ONLY for Kevin data
cd(Folder.data2);
temp = dir('*.xlsx');
xlsxFile = temp(1).name;
Participant.id            = xlsread(xlsxFile,1,'C2');
Participant.type          = xlsread(xlsxFile,1,'G2');
if Participant.type == 1
    Participant.type = 'Control';
else
    Participant.type = 'Patient';
end
Participant.gender        = xlsread(xlsxFile,1,'E2');
if Participant.gender == 1
    Participant.gender = 'Male';
else
    Participant.gender = 'Female';
end
Participant.inclusionAge  = xlsread(xlsxFile,1,'C3'); % years
Participant.pelvisWidth   = xlsread(xlsxFile,1,'B19')*1e-2; % m
Participant.RLegLength    = xlsread(xlsxFile,1,'C16')*1e-2; % m
Participant.LLegLength    = xlsread(xlsxFile,1,'B16')*1e-2; % m
Participant.RKneeWidth    = xlsread(xlsxFile,1,'C17')*1e-2; % m
Participant.LKneeWidth    = xlsread(xlsxFile,1,'B17')*1e-2; % m
Participant.RAnkleWidth   = xlsread(xlsxFile,1,'C18')*1e-2; % m
Participant.LAnkleWidth   = xlsread(xlsxFile,1,'B18')*1e-2; % m
Session.participantHeight = xlsread(xlsxFile,1,'E3'); % cm
Session.participantWeight = xlsread(xlsxFile,1,'G3'); % kg
clear temp;

% -------------------------------------------------------------------------
% DEFINE SESSION
% -------------------------------------------------------------------------
disp('Set session parameters');
Session.date              = '';
Session.type              = '';
Session.examiner          = '';
% ONLY for Kevin data
% Session.participantHeight = NaN; % cm
% Session.participantWeight = NaN; % kg
Session.markerHeight      = 0.014; % m

% -------------------------------------------------------------------------
% LOAD C3D FILES
% -------------------------------------------------------------------------
disp('Extract data from C3D files');

% List all trial types
% trialTypes = {'Static',...
%               'Endurance_Ito','Endurance_Sorensen',...
%               'Gait_Fast','Gait_Normal','Gait_Slow',...
%               'Posture_Standing','Posture_Sitting',...
%               'Perturbation_R_Shoulder','Perturbation_L_Shoulder',...
%               'S2S_Constrained','S2S_Unconstrained',...
%               'Swing_R_Leg','Swing_L_Leg',...
%               'Trunk_Forward','Trunk_Lateral','Trunk_Rotation',...
%               'Weight_Constrained','Weight_Unconstrained',...
%               'sMVC'};
% trialTypes = {'Static','Trunk_Forward'}; % Florent FRP data
trialTypes = {'SBNNN','XDMNN'}; % Kevin FRP data

% Extract data from C3D files
cd(Folder.data);
c3dFiles = dir('*.c3d');
k1       = 1;
k2       = 1;
for i = 1:size(c3dFiles,1)
    disp(['  - ',c3dFiles(i).name]);
    for j = 1:size(trialTypes,2)
        if ~isempty(strfind(c3dFiles(i).name,trialTypes{j}))
            if ~isempty(strfind(trialTypes{j},'Static')) == 1 || ~isempty(strfind(trialTypes{j},'SBNNN')) == 1
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
for i = 1%:size(Static,2) % For the moment, only one static allowed in the process
    disp(['  - ',Static(i).file]);
    
    % Get manually defined events
    Static(i).Event = [];
    
    % Process marker trajectories
    Marker            = btkGetMarkers(Static(i).btk);
    Static(i).Marker  = [];
    Static(i).Vmarker = [];
    Static(i).Segment = [];
    Static(i).Joint   = [];
    Static(i)         = InitialiseMarkerTrajectories(Static(i),Marker);
    Static(i)         = InitialiseVmarkerTrajectories(Static(i));
    Static(i)         = InitialiseSegments(Static(i));
    Static(i)         = InitialiseJoints(Static(i));
    Static(i)         = ProcessMarkerTrajectories([],Static(i));
%     Static(i)         = DefineSegments(Participant,[],Static(i));
    Static(i)         = DefineSegments_KevinData(Session,Participant,[],Static(i));
    clear Marker;
    
    % Process EMG signals
    Static(i).EMG = [];
    
    % Process forceplate signals
    Static(i).GRF = [];
    
    % Store processed static data in a new C3D file
    mkdir('output');
    ExportC3D(Static(i),[],Participant,Session,Folder);
end

% EMG calibration data
disp('Pre-process EMG calibration data');
Calibration(1).type = 'EMG_calibration';
Calibration(1).EMG  = [];
for i = 1:size(Trial,2)
    
    if ~isempty(strfind(Trial(i).type,'Endurance')) || ...
       ~isempty(strfind(Trial(i).type,'sMVC')) 
        
        disp(['  - ',Trial(i).file]);

        % Get manually defined events
        Event          = btkGetEvents(Trial(i).btk);
        Trial(i).Event = [];
        Trial(i)       = InitialiseEvents(Trial(i),Event);
        clear Event;   
    
        % Process marker trajectories
        Trial(i).Marker = [];  
        
        % Process EMG signals
        EMG                    = btkGetAnalogs(Trial(i).btk);
        Trial(i).EMG           = [];
        Trial(i)               = InitialiseEMGSignals(Trial(i),EMG);
        fmethod.type           = 'butterBand4';
        fmethod.parameter      = [10 450];
        smethod.type           = 'butterLow2';
        smethod.parameter      = 3;
        nmethod.type           = 'sMVC';
        [Calibration,Trial(i)] = ProcessEMGSignals(Calibration,Trial(i),1,fmethod,smethod,nmethod);
        clear EMG fmethod smethod nmethod;
    
        % Process forceplate signals
        Trial(i).GRF = [];
        
        % Store processed static data in a new C3D file
        cd(Folder.data);
        ExportC3D(Trial(i),[],Participant,Session,Folder);        
   
    end
end

% Trial data
disp('Pre-process trial data');
for i = 1:size(Trial,2)
    
    if isempty(strfind(Trial(i).type,'sMVC')) % Endurance tasks considered as Trial here

        disp(['  - ',Trial(i).file]);

        % Get manually defined events
        Trial(i).Event = [];
        Event          = btkGetEvents(Trial(i).btk);
        Trial(i)       = InitialiseEvents(Trial(i),Event);
        clear Event;   

        % Process marker trajectories   
        Trial(i).Marker      = [];
        Marker               = btkGetMarkers(Trial(i).btk);
        Trial(i)             = InitialiseMarkerTrajectories(Trial(i),Marker);        
        fmethod.type         = 'intercor';
        fmethod.gapThreshold = [];
        smethod.type         = 'movmean';
        smethod.parameter    = 15;        
%         Trial(i)             = ProcessMarkerTrajectories(Static,Trial(i),fmethod,smethod);   
        Trial(i)             = ProcessMarkerTrajectories_KevinData(Static,Trial(i),fmethod,smethod);        
        clear Marker fmethod smethod;
        
        % Compute segment and joint kinematics
        Trial(i).Vmarker = [];
        Trial(i).Segment = [];
        Trial(i).Joint   = [];
        Trial(i)         = InitialiseVmarkerTrajectories(Trial(i));
        Trial(i)         = InitialiseSegments(Trial(i));
        Trial(i)         = InitialiseJoints(Trial(i));
        if isempty(strfind(Trial(i).type,'Endurance'))
%             Trial(i)            = DefineSegments(Participant,Static,Trial(i));
            Trial(i)            = DefineSegments_KevinData(Session,Participant,Static,Trial(i));
            Trial(i)            = ComputeKinematics(Trial(i),2,5); % Right lower limb kinematic chain
            Trial(i)            = ComputeKinematics(Trial(i),7,10); % Left lower limb kinematic chain
            Trial(i)            = ComputeKinematics(Trial(i),10,13); % Pelvis/lumbar/thorax/head
            Trial(i)            = ComputeKinematics(Trial(i),14,19); % Pelvis/lower lumbar/upper lumbar/lower thorax/upper thorax/head
            Trial(i).Joint(5)   = Trial(i).Joint(10); % Double pelvis/lumbar joint for indices coherence
            Trial(i).Segment(5) = Trial(i).Segment(10); % Double pelvis segment for indices coherence
        end
        
        % Process EMG signals
        Trial(i).EMG           = [];
        EMG                    = btkGetAnalogs(Trial(i).btk);
%         Trial(i)               = InitialiseEMGSignals(Trial(i),EMG);
        Trial(i)               = InitialiseEMGSignals_KevinData(Trial(i),EMG);
        fmethod.type           = 'butterBand4';
        fmethod.parameter      = [10 450];
        smethod.type           = 'butterLow2';
        smethod.parameter      = 3;
%         [Calibration,Trial(i)] = ProcessEMGSignals(Calibration,Trial(i),0,fmethod,smethod,[]);
        [Calibration,Trial(i)] = ProcessEMGSignals_KevinData(Calibration,Trial(i),0,fmethod,smethod,[]);
        clear EMG fmethod smethod;
        
        % Process forceplate signals
        Trial(i).GRF      = [];
        tGRF              = [];
        Trial(i).btk      = Correct_FP_C3D_Mokka(Trial(i).btk);
        tGRF              = btkGetForcePlatformWrenches(Trial(i).btk); % Required for C3D exportation only
        GRF               = btkGetGroundReactionWrenches(Trial(i).btk);
        GRFmeta           = btkGetMetaData(Trial(i).btk,'FORCE_PLATFORM');
        Trial(i)          = InitialiseGRFSignals(Trial(i),GRF,GRFmeta);
        fmethod.type      = 'threshold';
        fmethod.parameter = 35;
        smethod.type      = 'butterLow2';
        smethod.parameter = 50;
        [Trial(i),tGRF]   = ProcessGRFSignals(Session,Trial(i),GRF,tGRF,fmethod,smethod);
        clear GRF GRFmeta fmethod smethod;
                
        % Define additional events (for trials other than gait)
        % Crop raw files if needed to keep only wanted cycles
        if contains(Trial(i).type,'Perturbation_R_Shoulder')
            type      = 1;
            threshold = 135; % deg
            vec1      = Trial(i).Marker(58).Trajectory.smooth-Trial(i).Marker(54).Trajectory.smooth; % Vector RHAN-RSHO
            vec2      = Trial(i).Marker(8).Trajectory.smooth-Trial(i).Marker(54).Trajectory.smooth; % Vector RGTR-RSHO
            Trial(i)  = DetectEvents(Trial(i),vec1,vec2,type,threshold);
            clear type threshold vec1 vec2;
        
        elseif contains(Trial(i).type,'Perturbation_L_Shoulder')   
            type      = 1;
            threshold = 135; % deg
            vec1      = Trial(i).Marker(63).Trajectory.smooth-Trial(i).Marker(59).Trajectory.smooth; % Vector LHAN-lSHO
            vec2      = Trial(i).Marker(23).Trajectory.smooth-Trial(i).Marker(59).Trajectory.smooth; % Vector LGTR-LSHO
            Trial(i)  = DetectEvents(Trial(i),vec1,vec2,type,threshold);
            clear type threshold vec1 vec2;
        
        elseif contains(Trial(i).type,'Trunk_Forward') || contains(Trial(i).type,'XDMNN') % Kevin FRP data
            type      = 2;
            threshold = 45; % deg
            vec1      = Trial(i).Marker(41).Trajectory.smooth-...
                        (Trial(i).Marker(3).Trajectory.smooth+Trial(i).Marker(4).Trajectory.smooth)/2; % Vector C7-mean(RPSI,LPSI)
            vec2      = repmat([0 0 1],[size(vec1,1),1]); % Vector ICS_Z
            Trial(i)  = DetectEvents(Trial(i),vec1,vec2,type,threshold);
            clear type threshold vec1 vec2;
        
        elseif contains(Trial(i).type,'Trunk_Lateral')
            type      = 2;
            threshold = 22.5; % deg
            vec1      = Trial(i).Marker(41).Trajectory.smooth-...
                        (Trial(i).Marker(3).Trajectory.smooth+Trial(i).Marker(4).Trajectory.smooth)/2; % Vector C7-mean(RPSI,LPSI)
            vec2      = repmat([0 0 1],[size(vec1,1),1]); % Vector ICS_Z
            Trial(i)  = DetectEvents(Trial(i),vec1,vec2,type,threshold);
            clear type threshold vec1 vec2;
        
        elseif contains(Trial(i).type,'Trunk_Rotation')
            type      = 2;
            threshold = 22.5; % deg
            vec1      = Trial(i).Marker(54).Trajectory.smooth-Trial(i).Marker(59).Trajectory.smooth; % Vector RSHO-lSHO
            vec2      = Trial(i).Marker(15).Trajectory.smooth-Trial(i).Marker(30).Trajectory.smooth; % Vector RANK-LANK
            Trial(i)  = DetectEvents(Trial(i),vec1,vec2,type,threshold);
            clear type threshold vec1 vec2;
        
        elseif contains(Trial(i).type,'Weight_Constrained')
            type      = 2;
            threshold = 30; % deg
            vec1      = Trial(i).Marker(8).Trajectory.smooth-Trial(i).Marker(10).Trajectory.smooth; % Vector RGTR-RKNE
            vec2      = Trial(i).Marker(8).Trajectory.smooth-Trial(i).Marker(15).Trajectory.smooth; % Vector RANK-RKNE
            Trial(i)  = DetectEvents(Trial(i),vec1,vec2,type,threshold);
            clear type threshold vec1 vec2;
        
        elseif contains(Trial(i).type,'Weight_Unconstrained')
            type      = 2;
            threshold = 30; % deg
            vec1      = Trial(i).Marker(41).Trajectory.smooth-...
                        (Trial(i).Marker(3).Trajectory.smooth+Trial(i).Marker(4).Trajectory.smooth)/2; % Vector C7-mean(RPSI,LPSI)
            vec2      = repmat([0 0 1],[size(vec1,1),1]); % Vector ICS_Z
            Trial(i)  = DetectEvents(Trial(i),vec1,vec2,type,threshold);
            clear type threshold vec1 vec2;
        
        elseif contains(Trial(i).type,'S2S')
            type      = 3;
            threshold = 22.5; % deg
            vec1      = Trial(i).Marker(41).Trajectory.smooth-...
                        (Trial(i).Marker(3).Trajectory.smooth+Trial(i).Marker(4).Trajectory.smooth)/2; % Vector C7-mean(RPSI,LPSI)
            vec2      = repmat([0 0 1],[size(vec1,1),1]); % Vector ICS_Z
            Trial(i)  = DetectEvents(Trial(i),vec1,vec2,type,threshold);
            clear type threshold vec1 vec2;
        end
        
        % Cut data per cycle
        Trial(i) = CutCycles(Trial(i));

        % Store processed static data in a new C3D file
        ExportC3D(Trial(i),tGRF,Participant,Session,Folder);
        clear tGRF;
        
    end
end
clear i j;

% ONLY FOR KEVIN DATA
end