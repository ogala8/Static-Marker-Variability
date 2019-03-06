function [LCoordRot, RCoordRot] = AnkleDorsiNorm(LCoord, RCoord, Lrot, Rrot)
%CoordBrut(5,:) = ASIS
%CoordBrut(6,:) = SACR
%CoordBrut(1,:) = LASIS

%Local coordinate system    
% xl = CoordBrut(5,:) - CoordBrut(6,:);
% xlu = xl / sqrt(xl*xl');
% yltemp = CoordBrut(1,:) - CoordBrut(5,:);
% ylutemp = yltemp / sqrt(yltemp*yltemp');
% zl = cross(xlu,ylutemp);
% zlu = zl / sqrt(zl*zl');
% ylu = cross(xlu, zlu);

%Kinematic angles 
% PelvicTilt = asind(zlu(2));
% PelvicRotation = acosd(ylu(2)/cosd(PelvicTilt));

%Rotation

LRy = [cosd(Lrot), 0, -sind(Lrot); ...
       0, 1, 0; ...
       sind(Lrot), 0, cosd(Lrot)];
   
RRy = [cosd(Rrot), 0, -sind(Rrot); ...
       0, 1, 0; ...
       sind(Rrot), 0, cosd(Rrot)];

LCoordRot = (LRy*LCoord')';
RCoordRot = (RRy*RCoord')';
%keyboard;
end