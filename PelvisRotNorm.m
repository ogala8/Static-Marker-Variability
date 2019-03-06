function CoordRot = PelvisRotNorm(CoordBrut)
%CoordBrut(5,:) = ASIS
%CoordBrut(6,:) = SACR
%CoordBrut(1,:) = LASIS

%Local coordinate system    
xl = CoordBrut(5,:) - CoordBrut(6,:);
xlu = xl / sqrt(xl*xl');
yltemp = CoordBrut(1,:) - CoordBrut(5,:);
ylutemp = yltemp / sqrt(yltemp*yltemp');
zl = cross(xlu,ylutemp);
zlu = zl / sqrt(zl*zl');
ylu = cross(xlu, zlu);
PelvicTilt = asind(zlu(2));
PelvicRotation = acosd(ylu(2)/cosd(PelvicTilt));
angle_cible = -PelvicRotation;
Rzcib = [cosd(angle_cible), -sind(angle_cible), 0; ...
       sind(angle_cible), cosd(angle_cible), 0; ...
       0, 0, 1];
CoordRot = (Rzcib*CoordBrut')';
%keyboard;

%plot
% figure;
% plot3(CoordBrut([1 2 4 3 1], 1), CoordBrut([1 2 4 3 1], 2), CoordBrut([1 2 4 3 1], 3), '-og', 'LineWidth', 3);
% hold on;
% plot3(CoordBrut([1 15 8 10 9], 1), CoordBrut([1 15 8 10 9], 2), CoordBrut([1 15 8 10 9], 3), '-or', 'LineWidth', 3);
% plot3(CoordBrut([2 18 12 14 13], 1), CoordBrut([2 18 12 14 13], 2), CoordBrut([2 18 12 14 13], 3), '-ob', 'LineWidth', 3);
% axis equal;
% xlabel('x'); ylabel('y'); zlabel('z');
% hold off;

end