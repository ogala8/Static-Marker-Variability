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

function ExportC3D(Trial,tGRF,Participant,Session,Folder)

% Set new C3D file
btkFile = btkNewAcquisition();
btkSetFrequency(btkFile,Trial.fmarker);
btkSetFrameNumber(btkFile,Trial.n1);
btkSetPointsUnit(btkFile,'marker','m');
btkSetAnalogSampleNumberPerFrame(btkFile,10);

% Append events
if ~isempty(Trial.Event)
    for i = 1:size(Trial.Event,2)
        for j = 1:size(Trial.Event(i).value,2)
            Event = Trial.Event(i).value(1,j)/Trial.fmarker;
            btkAppendEvent(btkFile,Trial.Event(i).label,Event,'');
            clear Event;
        end
    end
end

% Append marker trajectories
if ~isempty(Trial.Marker)
    for i = 1:size(Trial.Marker,2)
        if ~isempty(Trial.Marker(i).Trajectory.smooth)
            btkAppendPoint(btkFile,'marker',Trial.Marker(i).label,Trial.Marker(i).Trajectory.smooth);
        else
            btkAppendPoint(btkFile,'marker',Trial.Marker(i).label,zeros(Trial.n1,3));
        end
    end
end

% Append virtual marker trajectories
if ~isempty(Trial.Vmarker)
    for i = 1:size(Trial.Vmarker,2)
        if ~isempty(Trial.Vmarker(i).Trajectory.smooth)
            btkAppendPoint(btkFile,'marker',Trial.Vmarker(i).label,Trial.Vmarker(i).Trajectory.smooth);
        else
            btkAppendPoint(btkFile,'marker',Trial.Vmarker(i).label,zeros(Trial.n1,3));
        end
    end
end

% Append participant metadata
nData = 11;
info.format = 'Integer';
info.values = nData;
btkAppendMetaData(btkFile,'PARTICIPANT','USED',info);
clear info;
info.format = 'Char';
info.dimensions = ['1x',nData];
info.values(1:nData) = {'id' 'type' 'gender' 'inclusionAge' 'pelvisWidth' ...
                        'RLegLength' 'LLegLength' ...
                        'RKneeWidth' 'LKneeWidth' ...
                        'RAnkleWidth' 'LAnkleWidth'};
btkAppendMetaData(btkFile,'PARTICIPANT','LABELS',info);
clear info;
info.format = 'Char';
info.dimensions = ['1x',nData];
info.values(1:nData) = {'adimensioned' 'adimensioned (1: control, 2: patient)' 'adimensioned (1: male, 2: female)' 'years' 'm' ...
                        'm' 'm' ...
                        'm' 'm' ...
                        'm' 'm'};
btkAppendMetaData(btkFile,'PARTICIPANT','UNITS',info);
clear info;
info.format     = 'Real';
info.dimensions = ['1x',nData];
info.values(1)  = 1;
if strcmp(Participant.type,'Control')
    info.values(2) = 1;
elseif strcmp(Participant.type,'Patient')
    info.values(2) = 2;
end
if strcmp(Participant.gender,'Male')
    info.values(3) = 1;
elseif strcmp(Participant.gender,'Female')
    info.values(3) = 2;
end
info.values(4)  = Participant.inclusionAge;
if ~isempty(Participant.pelvisWidth)
    info.values(5) = Participant.pelvisWidth;
else
    info.values(5) = 0;
end
info.values(6)  = Participant.RLegLength;
info.values(7)  = Participant.LLegLength;
info.values(8)  = Participant.RKneeWidth;
info.values(9)  = Participant.LKneeWidth;
info.values(10) = Participant.RAnkleWidth;
info.values(11) = Participant.LAnkleWidth;
btkAppendMetaData(btkFile,'PARTICIPANT','VALUES',info);

% Append session metadata
nData                = 6;
info.format          = 'Integer';
info.values          = nData;
btkAppendMetaData(btkFile,'SESSION','USED',info);
clear info;
info.format          = 'Char';
info.dimensions      = ['1x',nData];
info.values(1:nData) = {'date' 'type' 'examiner' ...
                        'participantHeight' 'participantWeight' 'markerHeight'};
btkAppendMetaData(btkFile,'SESSION','LABELS',info);
clear info;
info.format          = 'Char';
info.dimensions      = ['1x',nData];
info.values(1:nData) = {'DD-MM-YYYY' 'XXX_session' 'initials' 'm' 'kg' 'm'};
btkAppendMetaData(btkFile,'SESSION','UNITS',info);
clear info;
info.format          = 'Char';
info.dimensions      = ['1x',nData];
info.values(1:nData) = {Session.date Session.type Session.examiner ...
                        num2str(Session.participantHeight*1e-2) num2str(Session.participantWeight) num2str(Session.markerHeight)};
btkAppendMetaData(btkFile,'SESSION','VALUES',info);

% Export C3D file
cd([Folder.data,'output\']);
btkWriteAcquisition(btkFile,[regexprep(Trial.file,'.c3d',''),'_processed.c3d']);