% Author       : A. Naaim
% -------------------------------------------------------------------------
% Description  : Chord function used to compute distal joint axis based on
%                the Conventional Gait Model (CGM) 1.0
% Inputs       : - proximal_joint_center, i.e. the 3D trajectory of the 
%                  proximal joint centre of theexplored segment
%                - wand, i.e. the 3D trajectory of the segment wand marker
%                - lateral_marker, i.e. the 3D trajectory of the lateral 
%                  marker of the distal joint
%                - joint_width, i.e. width of the distal joint
%                - marker_width, i.e. width/height of the reflective
%                  markers
% Outputs      : - distal_joint_center, i.e. the 3D trajectory of the 
%                  distal joint centre of theexplored segment
% -------------------------------------------------------------------------
% Dependencies : None
% -------------------------------------------------------------------------
% Updates      : - 01/06/2021: This code was originally written in Python
%                  and translated to Matlab by F. Moissenet 
% -------------------------------------------------------------------------

function distal_joint_center = chord_func(proximal_joint_center,wand,lateral_marker,joint_width,marker_width)

% Set the distance between the lateral marker and the joint centre
half_width = (joint_width + marker_width)/2;

% Set technical coordinate system
X_plan = proximal_joint_center-lateral_marker;
X_plan = X_plan./mean(sqrt(sum(X_plan.^2,2)));
Z_plan = cross(proximal_joint_center-lateral_marker,wand-lateral_marker);
Z_plan = Z_plan./mean(sqrt(sum(Z_plan.^2,2)));
Y_plan = cross(Z_plan,X_plan);

% Compute direction vector from lateral marker
distance_hypothenus = mean(sqrt(sum((proximal_joint_center-lateral_marker).^2,2)));
acos_dist           = half_width/distance_hypothenus;
angle               = acos(acos_dist);
vector_dir          = cos(-angle)*X_plan+sin(-angle)*Y_plan;
vector_dir          = vector_dir./mean(sqrt(sum(vector_dir.^2,2)));

% Define the joint centre along this direction vector at the distance
% previously defined
distal_joint_center = lateral_marker+vector_dir*half_width;