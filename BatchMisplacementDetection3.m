close all;
clearvars;
clc;
%statref = 1;
nstat =145; %10;%25; 
nmarqueur = 44;
isbset = [1:5, 10:13, 18:20, 22, 24, 25, 30:33, 39:41, 43, 45];
indMax=zeros(1);
errors = cell(nstat);
Participant.id = 'Omar';
distmean = zeros(nstat); %mean distance in mm
dist3d = cell(nstat); %distance 3D for each marker in mm
diststd = zeros(nstat); %std of distance in mm
distmax = zeros(1);
mlabel = cell(1);

h = waitbar(0, 'Please wait...');
for i = 1:nstat
    waitbar(i / nstat);
    for j = 1%:nstat%:length(isbset)+1
        ikw = 1000*ones(1,nmarqueur);
        %ikw([1:4]) = [1, 1, 1, 1];
        %ikw([20,22, 24]) = [1, 1, 1];
        %ikw([40,42, 44]) = [1, 1, 1];
        %ikw([32, 33, 38, 39]) = [1, 1, 1, 1];
        %ikw([12,13,18,19])=[1,1,1,1];
        %ikw([5,10, 11]) = [1,1,1];
        ikw([25,30, 31]) = [1,1,1];
%         if j <= length(isbset)
%             ikw(isbset(j)) = 0;
%         end
        [errors{j,i}, Static, Segment] = Copy_2_of_MAIN(Participant, 'ISBlike', j, i, ikw);
        %dist3d(j,i) = norm(errors{i}(:,2,4))*1000;
        rme = errors{j,i}(:);
        ind = find(rme);
        distmean(j,i) = 1e3*sqrt(rme(ind)'*rme(ind)/length(ind));
        diststd(j,i) = 1e3*sqrt(std(rme(ind).^2));
        [vMax,iMax]=max(rme.^2);
        distmax(j,i) = 1e3*sqrt(vMax);
        d3d = [];
        nmarker = 0;
        for k = 2:size(Segment,2)
            for z = 1:size(Segment(k).rM_label,2)
                nmarker = nmarker+1;
                mlabel{nmarker} = Segment(k).rM_label{z};
                d3d = [d3d, 1e3*norm(errors{j,i}(:,z,k))];
            end
        end
        dist3d{j,i}=d3d';
        [vMax2,indMax(j,i)]=max(d3d);
    end
end
close(h);
%mlabel(indMax(indMax~=0))

%
%final_array=[ans;num2cell(distmax)];
%
%
%
%%V�rification du d�placement des marqueurs
indMark=[20 12 18 23 15 22 16 17 21 14 19 24 6 11 4 2 8 1 9 10 7 13 5 3];
indMark2=repelem(indMark,6);
pourc_reussite=sum(indMark2 == indMax(2:145))/length(indMark2)*100;
% 
% 
% %%Distances cumul�es 
% 
% errcum = zeros(size(mlabel,2),1);
% for i = 2:size(dist3d,2)
%     errcum = errcum + dist3d{1,i};
% end
% disp(errcum/(size(dist3d,2)-1));


 





