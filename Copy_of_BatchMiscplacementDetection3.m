close all;
clearvars;
clc;
%statref = 1;
nstat = 145;
indMax=zeros(1);
errors = cell(nstat);
Participant.id = 'Omar';
distmean = zeros(nstat); %mean distance in mm
dist3d = cell(nstat); %distance 3D for each marker in mm
diststd = zeros(nstat); %std of distance in mm
distmax = zeros(1);
mlabel = cell(1);
h=waitbar(0,'please wait');
    for i = 1:nstat
        for k = 1;
        waitbar(i/nstat)
        ikw = ones(1,nmarker);
        ikw =
        [errors{1,i}, Static, Segment] = Copy_2_of_MAIN(Participant, 'ISBlike', 1, i, ikw);
        %dist3d(j,i) = norm(errors{i}(:,2,4))*1000;
        rme = errors{1,i}(:);
        ind = find(rme);
        distmean(1,i) = 1e3*sqrt(rme(ind)'*rme(ind)/length(ind));
        diststd(1,i) = 1e3*sqrt(std(rme(ind).^2));
        [vMax,iMax]=max(rme.^2);
        distmax(1,i) = 1e3*sqrt(vMax);
        d3d = [];
        nmarker = 0;
        for k = 2:size(Segment,2)
            for z = 1:size(Segment(k).rM_label,2)
                nmarker = nmarker+1;
                mlabel{nmarker} = Segment(k).rM_label{z};
                d3d = [d3d, 1e3*norm(errors{1,i}(:,z,k))];
            end
        end
        dist3d{1,i}=d3d';
        [vMax2,indMax(1,i)]=max(d3d);
        total=[];

    end
  close(h)  

mlabel(indMax);

% 
 final_array=[ans;num2cell(distmax)];
% 
% 
% 
% %%Vérification du déplacement des marqueurs
indMark=[20 12 18 23 15 22 16 17 21 14 19 24 6 11 4 2 8 1 9 10 7 13 5 3];
indMark2=repelem(indMark,6);
sum=sum(indMark2 == indMax(2:145))/length(indMark2)*100;


%%Distances cumulées 

errcum = zeros(size(mlabel,2),1);
for i = 2:size(dist3d,2)
    errcum = errcum + dist3d{1,i};
end
disp(errcum/(size(dist3d,2)-1));


 





