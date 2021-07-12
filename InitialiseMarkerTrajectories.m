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

function Trial = InitialiseMarkerTrajectories(Trial,Marker)

% Set markerset
markerSet = {'RASI','RPSI','LPSI','LASI',...
             'RGTR','RTHAP','RTHAD','RTHI1','RTHI2','RKNE','RKNM',...
             'RFAX','RTTA','RTIAP','RTIAD','RTIB1','RTIB2','RANK','RMED',...
             'RHEE','RTOE','RFMH','RSMH','RVMH',...
             'LGTR','LTHAP','LTHAD','LTHI1','LTHI2','LKNE','LKNM',...
             'LFAX','LTTA','LTIAP','LTIAD','LTIB1','LTIB2','LANK','LMED',...
             'LHEE','LTOE','LFMH','LSMH','LVMH'};
         
% Set landmark type
% 'landmark' is a marker related to a rigid body
% 'semi-landmark' is a marker related to a curve
% 'hybrid-landmark' is a marker related to a curve and a rigid body
% 'technical' is a marker not used for anatomical description
landmarkList = {'landmark','landmark','landmark','landmark',...
                'landmark','technical','technical','technical','technical','landmark','landmark',...
                'landmark','landmark','technical','technical','technical','technical','landmark','landmark',...
                'landmark','landmark','landmark','landmark','landmark',...
                'landmark','technical','technical','technical','technical','landmark','landmark',...
                'landmark','landmark','technical','technical','technical','technical','landmark','landmark',...
                'landmark','landmark','landmark','landmark','landmark'};       
         
% Set related rigid segments
% Only used with landmark and hybrid-landmarks markers ('none' instead')
segmentList = {'Pelvis','Pelvis','Pelvis','Pelvis',...
               'RThigh','RThigh','RThigh','RThigh','RThigh','RThigh','RThigh',...
               'RShank','RShank','RShank','RShank','RShank','RShank','RShank','RShank',...
               'RFoot','RFoot','RFoot','RFoot','RFoot',...
               'LThigh','LThigh','LThigh','LThigh','LThigh','LThigh','LThigh',...
               'LShank','LShank','LShank','LShank','LShank','LShank','LShank','LShank',...
               'LFoot','LFoot','LFoot','LFoot','LFoot'};
           
% Set related curves
% Only used with semi-landmark and hybrid-landmarks markers ('none' instead')
% Syntax: Curve named followed by order number on the curve
curveList = {'none',nan,'none',nan,'none',nan,'none',nan,...
             'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,...
             'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,...
             'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,...
             'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,...
             'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,...
             'none',nan,'none',nan,'none',nan,'none',nan,'none',nan};

% Initialise markers
Trial.Marker = [];
for i = 1:length(markerSet)
    Trial.Marker(i).label                 = markerSet{i};
    Trial.Marker(i).type                  = landmarkList{i};
    Trial.Marker(i).Body.Segment.label    = segmentList{i};
    Trial.Marker(i).Body.Curve.label      = curveList{i*2-1};
    Trial.Marker(i).Body.Curve.index      = curveList{i*2};
    if isfield(Marker,markerSet{i})
        Trial.Marker(i).Trajectory.raw    = Marker.(markerSet{i})*1e-3; % Convert mm to m
        Trial.Marker(i).Trajectory.fill   = [];
        Trial.Marker(i).Trajectory.smooth = [];
        Trial.Marker(i).Trajectory.rcycle = [];
        Trial.Marker(i).Trajectory.lcycle = [];
        Trial.Marker(i).Trajectory.units  = 'm';
        Trial.Marker(i).Trajectory.Gap    = [];
    else
        Trial.Marker(i).Trajectory.raw    = [];
        Trial.Marker(i).Trajectory.fill   = [];
        Trial.Marker(i).Trajectory.smooth = [];
        Trial.Marker(i).Trajectory.rcycle = [];
        Trial.Marker(i).Trajectory.lcycle = [];
        Trial.Marker(i).Trajectory.units  = 'm';
        Trial.Marker(i).Trajectory.Gap    = [];
    end
    Trial.Marker(i).Processing.smooth     = 'none';
    Trial.Marker(i).Processing.Gap        = [];
end