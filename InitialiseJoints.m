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

function Trial = InitialiseJoints(Trial)

jointLabels = {'Right MTP','Right ankle','Right knee','Right hip','Lumbo-pelvis joint', ...
               'Left MTP','Left ankle','Left knee','Left hip','Lumbo-pelvis joint', ...
               'Thoraco-lumbar joint','Cervical joint','',...
               'Lower lumbo-pelvis joint', ...
               'Lower/upper lumbar joint','Upper lumbar/lower thorax joint', ...
               'Lower/Upper thorax joint','Head/upper thorax joint'};

for i = 1:length(jointLabels)
    Trial.Joint(i).label        = jointLabels{i};
    Trial.Joint(i).T.smooth     = [];
    Trial.Joint(i).T.rcycle     = [];
    Trial.Joint(i).T.lcycle     = [];
    Trial.Joint(i).Euler.smooth = [];
    Trial.Joint(i).Euler.rcycle = [];
    Trial.Joint(i).Euler.lcycle = [];
    Trial.Joint(i).Euler.units  = 'rad';
    Trial.Joint(i).dj.smooth    = [];
    Trial.Joint(i).dj.rcycle    = [];
    Trial.Joint(i).dj.lcycle    = [];
    Trial.Joint(i).dj.units     = 'm';
    Trial.Joint(i).sequence     = '';
end