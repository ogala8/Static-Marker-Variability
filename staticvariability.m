close all; clear all; clc;
pathprin = 'C:\Users\florent.moissenet\Documents\Professionnel\routines\github\Static-Marker-Variability\data\';

pat = dir(pathprin);
pat(1:2) = [];
npat = length(pat);
nsession = 3;
nmarkpelv = 4;
nmarkmi = 11;
nop = 1;
o1 = zeros(nsession, nmarkpelv + nmarkmi, 3, 2*npat);
o2 = zeros(nsession, nmarkpelv + nmarkmi, 3, 2*npat);
color = ['b'; 'r'; 'g'];

%% Marker position and alignment
for i = 1:npat
    pathses = [pathprin pat(i).name];
    ses = dir(pathses);
    ses(1:2) = [];
    nses = length(ses)/2;
    for j = 1:nses
        matbrut1 = LoadMarkersNorm(pathses, ses(j).name);
        load([pathses '\' ses(j).name], 'EAFilter');
        LDorsiFl1 = mean(EAFilter.LAnkle.value(:,2));
        RDorsiFl1 = mean(EAFilter.RAnkle.value(:,2));
        LKneeFl1 = mean(EAFilter.LKnee.value(:,2));
        RKneeFl1 = mean(EAFilter.RKnee.value(:,2));
%         LFootProg = mean(EAFilter.LFoot.value(:,3));
%         if LFootProg > 90
%             LFootProg = 180 - LFootProg;
%         end
%         RFootProg = mean(EAFilter.RFoot.value(:,3));
%         if RFootProg > 90
%             RFootProg = 180 - RFootProg;
%         end        
        clear EAFilter;
        %Pelvic rotation alignment
        matrot1 = PelvisRotNorm(matbrut1);
        %Hip rotation (feet alginment)
        %matrot1 = FeetAlign(matrot1, -25-LFootProg, -25-RFootProg);
        %Ankle dorsiflexion alignment (knee and pelvic markers)
        [lmatkneerot1, rmatkneerot1] = AnkleDorsiNorm(matrot1([1:6 15:17],:), matrot1([1:6 18:20],:), LDorsiFl1, RDorsiFl1);       
        %Knee flexion alignment (pelvic markers)
        [lmathiprot1, rmathiprot1] = KneeFlexNorm(lmatkneerot1(1:6,:), rmatkneerot1(1:6,:), LKneeFl1+LDorsiFl1, RKneeFl1+RDorsiFl1);
        %Mirroring
        o1(j,:, :,2*(i-1)+1) = [lmathiprot1; lmatkneerot1(7:9,:); matrot1(7:10,:)];
        rmatkneerot1(7:9,2) = -rmatkneerot1(7:9,2); 
        matrot1(11:14,2) = -matrot1(11:14,2);
        o1(j,:, :,2*(i-1)+2) = [rmathiprot1; rmatkneerot1(7:9,:); matrot1(11:14,:)];

%         figure(i);
%         plotMarkers(lmatkneerot1, ['o' color(j)]);
%         hold on;
%         plotMarkers(lmathiprot1, ['^' color(j)]);
%         plotMarkers(matrot1, ['x' color(j)])
%         plotMarkers(rmatkneerot1, ['o' color(j)]);
%         plotMarkers(rmathiprot1, ['^' color(j)]);
        
        %Second operator
        matbrut2 = LoadMarkersNorm(pathses, ses(j+nses).name);
        load([pathses '\' ses(j).name], 'EAFilter');
        LDorsiFl2 = mean(EAFilter.LAnkle.value(:,2));
        RDorsiFl2 = mean(EAFilter.RAnkle.value(:,2));
        LKneeFl2 = mean(EAFilter.LKnee.value(:,2));
        RKneeFl2 = mean(EAFilter.RKnee.value(:,2));
        LFootProg = mean(EAFilter.LFoot.value(:,3));
        RFootProg = mean(EAFilter.RFoot.value(:,3));        
        clear EAFilter;
        %Pelvic rotation alignment
        matrot2 = PelvisRotNorm(matbrut2);
        %Hip rotation (feet alginment)
        %matrot2 = FeetAlign(matrot2, LFootProg, RFootProg);
        %Ankle dorsiflexion alignment (knee and pelvic markers)
        [lmatkneerot2, rmatkneerot2] = AnkleDorsiNorm(matrot2([1:6 15:17],:), matrot2([1:6 18:20],:), LDorsiFl2, RDorsiFl2);
        %Knee flexion alignment (pelvic markers)
        [lmathiprot2, rmathiprot2] = KneeFlexNorm(lmatkneerot2(1:6,:), rmatkneerot2(1:6,:), LKneeFl2+LDorsiFl2, RKneeFl2+RDorsiFl2);
        %Lateral mirroring
        o2(j,:, :,2*(i-1)+1) = [lmathiprot2; lmatkneerot2(7:9,:); matrot2(7:10,:)];
        rmatkneerot2(7:9,2) = -rmatkneerot2(7:9,2);
        matrot2(11:14,2) = -matrot2(11:14,2);
        o2(j,:, :,2*(i-1)+2) = [rmathiprot2; rmatkneerot2(7:9,:); matrot2(11:14,:)];
    end
end

%% Marker position alignment per session (color) and operator (marker symbol) 
for i = 1:npat
    figure(i);    
    for z = 1:nsession 
        plot3([o1(z, :, 1, 2*(i-1)+1), o1(z, :, 1, 2*(i-1)+2)], [o1(z, :, 2, 2*(i-1)+1), o1(z, :, 2, 2*(i-1)+2)], [o1(z, :, 3, 2*(i-1)+1), o1(z, :, 3, 2*(i-1)+2)], ['o' color(z)], 'LineWidth', 3);
        hold on;
        plot3([o2(z, :, 1, 2*(i-1)+1), o2(z, :, 1, 2*(i-1)+2)], [o2(z, :, 2, 2*(i-1)+1), o2(z, :, 2, 2*(i-1)+2)], [o2(z, :, 3, 2*(i-1)+1), o2(z, :, 3, 2*(i-1)+2)], ['x' color(z)], 'LineWidth', 3);
    end
    xlabel('x'); ylabel('y'); zlabel('z');
    axis equal;
    hold off;
end

%% Marker distance intersession and interoperator
avgdist_intersession = zeros(2*npat, nmarkpelv+nmarkmi, nop);
avgdist_interop = zeros(2*npat, nmarkpelv+nmarkmi);
maxdist_intersession = zeros(2*npat, nmarkpelv+nmarkmi, nop);
maxdist_interop = zeros(2*npat, nmarkpelv+nmarkmi);
for j = 1:2*npat
    for k = 1:nmarkpelv+nmarkmi
        dist1 = zeros(nsession);
        dist2 = zeros(nsession);
        distop = zeros(nsession);
        for z = 1:nsession
            difop = squeeze(o1(z, k, :, j))-squeeze(o2(z, k, :, j));
            distop(z,z) = sqrt(difop'*difop);
            for zz = z+1:nsession
                dif1 = squeeze(o1(z, k, :, j))-squeeze(o1(zz, k, :, j));
                dist1(z, zz) = sqrt(dif1'*dif1);
                dif2 = squeeze(o2(z, k, :, j))-squeeze(o2(zz, k, :, j));
                dist2(z, zz) = sqrt(dif2'*dif2);
                difop1 = squeeze(o1(z, k, :, j))-squeeze(o2(zz, k, :, j));
                distop(z,zz) = sqrt(difop1'*difop1);
                difop2 = squeeze(o2(z, k, :, j))-squeeze(o1(zz, k, :, j));
                distop(zz,z) = sqrt(difop2'*difop2);
            end
        end
        avgdist_intersession(j, k, 1) = sum(sum(dist1))/sumdec(nsession-1);
        avgdist_intersession(j, k, 2) = sum(sum(dist2))/sumdec(nsession-1);
        avgdist_interop(j, k) = sum(sum(distop))/numel(distop);
        maxdist_intersession(j, k, 1) = max(max(dist1));
        maxdist_intersession(j, k, 2) = max(max(dist2));
        maxdist_interop(j, k) = max(max(distop));        
    end
end

%% Interoperator Marker Variability 
sd_static_interop_ll = zeros(size(o1, 3), nmarkpelv+nmarkmi, 2*npat);
for z = 1:npat*2
    for zz = 1:size(o1,3)
       sd_static_interop_ll(zz,:,z) = std([squeeze(o1(:, :, zz, z)); squeeze(o2(:, :, zz, z))]);
    end
end

sd_static_interop_ll_reshape = reshape(permute(sd_static_interop_ll, [2, 1, 3]), (nmarkpelv+nmarkmi)*3, npat*2)';
sd_static_interop = mean(sd_static_interop_ll, 3);

%% Correlation between marker variability and kinematic variability
load('kinematic_variability.mat', 'moyenne_sd_mi_interop', 'sd_interop');
matcor = corrcoef([moyenne_sd_mi_interop', sd_static_interop_ll_reshape]);
[maxv, imax]=max(abs(matcor(10:end,1:9)));
matcor2 = corrcoef([sd_interop, sd_static_interop_ll_reshape]);
[maxv2, imax2]=max(abs(matcor2(460:end,1:459)));