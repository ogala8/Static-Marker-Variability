close all; clear all; clc;
pathprin = 'Matlab static\';

pat = dir(pathprin);
pat(1:2) = [];
npat = length(pat);
nsession = 3;
nmarkpelv = 6;
nmarkmi = 7;
o1 = zeros(nsession, nmarkpelv + 2*nmarkmi, 3, npat);
o2 = zeros(nsession, nmarkpelv + 2*nmarkmi, 3, npat);

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
        clear EAFilter;
        matrot1 = PelvisRotNorm(matbrut1);
        [o1(j,:, :,2*(i-1)+1), o1(j,:, :,2*(i-1)+2)] = AnkleDorsiNorm(matrot, -LDorsiFl1, -RDorsiFl1);
        %[o1(j,:, :,2*(i-1)+1), o1(j,:, :,2*(i-1)+2)] = KneeFlexNorm(squeeze(o1(j,:, :,i)), -LKneeFl1, -RKneeFl1);
        
        matbrut2 = LoadMarkersNorm(pathses, ses(j+nses).name);
        load([pathses '\' ses(j).name], 'EAFilter');
        LDorsiFl2 = mean(EAFilter.LAnkle.value(:,2));
        RDorsiFl2 = mean(EAFilter.RAnkle.value(:,2));
        LKneeFl2 = mean(EAFilter.LKnee.value(:,2));
        RKneeFl2 = mean(EAFilter.RKnee.value(:,2));
        clear EAFilter;        
        matrot2 = PelvisRotNorm(matbrut2);
        [o2(j,:, :,2*(i-1)+1), o2(j,:, :,2*(i-1)+2)] = AnkleDorsiNorm(matrot2, -LDorsiFl2, -RDorsiFl2);
        %[o2(j,:, :,2*(i-1)+1), o2(j,:, :,2*(i-1)+2)] = KneeFlexNorm(squeeze(o2(j,:, :,i)), -LKneeFl2, -RKneeFl2);
    end
end

pati = 1;
figure;    
for z = 1:nsession 
    plot3(o1(z, :, 1, pati), o1(z, :, 2, pati), o1(z, :, 3, pati), 'o', 'LineWidth', 3);
    hold on;
end
xlabel('x'); ylabel('y'); zlabel('z');
axis equal;
hold off;

sd_static_interop_pat = zeros(size(o1, 3), nmarkpelv+nmarkmi, 2*npat);
for z = 1:npat
    for zz = 1:size(o1,3)
       sd_static_interop_pat(zz,1:nmarkpelv,2*(z-1)+1) = std([squeeze(o1(:, 1:nmarkpelv, zz, z)); squeeze(o2(:, 1:nmarkpelv, zz, z))]);
       %sd_static_interop_pat(zz,1:nmarkpelv,2*(z-1)+2) = sd_static_interop_pat(zz,1:nmarkpelv,2*(z-1)+1);
       sd_static_interop_pat(zz,nmarkpelv+(1:nmarkmi),2*(z-1)+1) = std([squeeze(o1(:, nmarkpelv+[1:4 9:11], zz, z)); squeeze(o2(:, nmarkpelv+[1:4 9:11], zz, z))]);
       sd_static_interop_pat(zz,nmarkpelv+(1:nmarkmi),2*(z-1)+2) = std([squeeze(o1(:, nmarkpelv+[5:8 12:14], zz, z)); squeeze(o2(:, nmarkpelv+[5:8 12:14], zz, z))]);
    end
end

sd_static_interop_pat_reshape = reshape(permute(sd_static_interop_pat, [2, 1, 3]), (nmarkpelv+nmarkmi)*3, npat*2)';
sd_static_interop = mean(sd_static_interop_pat, 3);

%correlation entre sd_static_interop_pat et varibilité cinématique bassin
%(voir résultats précédents)
load('kinematic_variability.mat', 'moyenne_sd_mi_interop');
matcor = corrcoef([moyenne_sd_mi_interop', sd_static_interop_pat_reshape]);
[maxv, imax]=max(abs(matcor(10:end,1:9)));