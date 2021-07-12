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

function Trial = InitialiseVmarkerTrajectories(Trial)

vmarkerLabels = {'RMJC','RAJC','RKJC','RHJC',...
                 'LMJC','LAJC','LKJC','LHJC',...
                 'LJC','TJC','CJC','VER',...
                 'midASIS','PELVIS_X','PELVIX_Y','PELVIS_Z',...
                 'RFEMUR_X','RFEMUR_Y','RFEMUR_Z',...
                 'RTIBIA_X','RTIBIA_Y','RTIBIA_Z',...
                 'RFOOT_X','RFOOT_Y','RFOOT_Z',...
                 'LFEMUR_X','LFEMUR_Y','LFEMUR_Z',...
                 'LTIBIA_X','LTIBIA_Y','LTIBIA_Z',...
                 'LFOOT_X','LFOOT_Y','LFOOT_Z'};
             
for i = 1:length(vmarkerLabels)
    Trial.Vmarker(i).label             = vmarkerLabels{i};
    Trial.Vmarker(i).Trajectory.smooth = [];
    Trial.Vmarker(i).Trajectory.rcycle = [];
    Trial.Vmarker(i).Trajectory.lcycle = [];
    Trial.Vmarker(i).Trajectory.units  = 'm';
end