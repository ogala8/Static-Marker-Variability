close all;
clearvars;
clc;
%statref = 1;
nstat = 145;
indMax=zeros(nstat);
errors = cell(nstat);
Participant.id = 'Omar';
distmean = zeros(nstat); %mean distance in mm
dist3d = cell(nstat); %distance 3D for each marker in mm
diststd = zeros(nstat); %std of distance in mm
distmax = zeros(nstat);
mlabel = cell(1);
for j= 1:nstat
    for i = 1:nstat
        [errors{j,i}, Static, Segment] = Copy_2_of_MAIN(Participant, 'ISBlike', j, i);
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

        
        total=[];
        
        for m = 1:24
            l=0;
           for j = 1:10
              for i = 1:10
                 if(indMax(j,i) == m)
                      l=l+1;    
                 end 
              end
           end
          
           total=[total,l];
          
           
          end


    end
end

mlabel(indMax)
