function [LCoordRot, RCoordRot] = KneeFlexNorm(LCoord, RCoord, Lrot, Rrot)

%Rotation
LRy = [cosd(Lrot), 0, -sind(Lrot); ...
       0, 1, 0; ...
       sind(Lrot), 0, cosd(Lrot)];
   
RRy = [cosd(Rrot), 0, -sind(Rrot); ...
       0, 1, 0; ...
       sind(Rrot), 0, cosd(Rrot)];

LCoordRot = (LRy*LCoord')';
RCoordRot = (RRy*RCoord')';

end