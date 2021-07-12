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
% Dependencies : - Biomechanical Toolkit (BTK): https://github.com/Biomechanical-ToolKit/BTKCore
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

Folder.data   = 'C:\Users\moissene\Documents\Professionnel\projets recherche\2019 - NSCLBP - Biomarkers\Données\NSLBP-BIO\Data\';
Folder.export = 'C:\Users\moissene\Documents\Professionnel\projets recherche\2019 - NSCLBP - Biomarkers\Données\FRP Anais\DataFlo\';

participantList = {'001','002','004','005','007','008','009','010',...
                   '011','012','013','014','015','016','017','018','019','020',...
                   '021','022','023','024','025','026','027','028','029','030',...
                   '031','032','033','034','035','036','037','038','039','040',...
                   '041','042','043','044','045','046','047','048','049','050',...
                   '051','053','054','055'};
               
for iparticipant = 1:size(participantList,2)
    clear staticFile trunkForwardFile;
    cd(Folder.data);
    cd(['NSLBP-BIO-',participantList{iparticipant}]);
    folder = dir('*INI_session*');
    cd(folder.name);
    cd('output');
    staticFile = dir('*Static*');
    trunkForwardFile = dir('*Trunk_Forward*');
    cd(Folder.export);
    mkdir(['NSLBP-BIO-',participantList{iparticipant}]);
    copyfile([staticFile.folder,'\',staticFile.name],['NSLBP-BIO-',participantList{iparticipant}]);
    copyfile([trunkForwardFile.folder,'\',trunkForwardFile.name],['NSLBP-BIO-',participantList{iparticipant}]);
end