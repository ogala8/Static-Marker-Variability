% Author       : Omar Galarraga
%                Florent Moissenet
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : https://github.com/fmoissenet/NSLBP-BIOToolbox
% Reference    : To be defined
% Date         : July 2020
% -------------------------------------------------------------------------
% Description  : To be defined
% -------------------------------------------------------------------------
% Dependencies : To be defined
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function Trial = ProcessMarkerTrajectories(Static,Trial,fmethod,smethod)

% -------------------------------------------------------------------------
% IDENTIFY MISSING TRAJECTORIES AND GAPS IN TRAJECTORIES 
% -------------------------------------------------------------------------
for i = 1:size(Trial.Marker,2)

    % Special case of static
    if isempty(Static)
        if isempty(Trial.Marker(i).Trajectory.raw)
            Trial.Marker(i).Trajectory.fill = [];
        else
            Trial.Marker(i).Trajectory.fill = mean(Trial.Marker(i).Trajectory.raw,1);
        end
        Trial.n0 = 1;
        Trial.n1 = 1;  
    end
    
    % Missing marker trajectory
    if isempty(Trial.Marker(i).Trajectory.raw)
        Trial.Marker(i).Trajectory.Gap(1).frames         = 1:Trial.n1;
        Trial.Marker(i).Processing.Gap(1).reconstruction = 'none';
        Trial.Marker(i).Processing.smooth                = 'none';

    % Marker trajectory with gaps
    elseif ~isempty(Trial.Marker(i).Trajectory.raw)
        
%         % Replace high accelerations by NaN
%         threshold = 5e-4; % Empirically defined
%         temp      = gradient(gradient(Trial.Marker(i).Trajectory.raw(:,1)));
%         for j = 1:Trial.n1
%             if abs(temp(j,1)) > threshold
%                Trial.Marker(i).Trajectory.raw(j,:) = nan(1,3);
%             end
%         end
%         clear threshold temp;

        % Replace [0 0 0] by NaN
        for j = 1:Trial.n1
            if Trial.Marker(i).Trajectory.raw(j,:) == [0 0 0]
               Trial.Marker(i).Trajectory.fill(j,:) = nan(1,3);
            else
               Trial.Marker(i).Trajectory.fill(j,:) = Trial.Marker(i).Trajectory.raw(j,:);
            end
        end

        % Find gaps
        start = 0;
        stop  = 0;
        k     = 0;
        for j = 1:Trial.n1-1
            if isnan(Trial.Marker(i).Trajectory.fill(j,:))
                if start == 0
                    start = j;
                end
                if ~isnan(Trial.Marker(i).Trajectory.fill(j+1,:))
                    if start ~= 0
                        stop   = j;
                        k      = k+1;    
                        Trial.Marker(i).Trajectory.Gap(k).frames         = start:stop;
                        Trial.Marker(i).Processing.Gap(k).reconstruction = 'none';
                        start  = 0;
                        stop   = 0;
                    end
                elseif j+1 == Trial.n1
                    if isnan(Trial.Marker(i).Trajectory.fill(j+1,:))
                        if start ~= 0
                            stop   = j+1;
                            k      = k+1;    
                            Trial.Marker(i).Trajectory.Gap(k).frames         = start:stop;
                            Trial.Marker(i).Processing.Gap(k).reconstruction = 'none';
                            start  = 0;
                            stop   = 0;
                        end   
                    end
                end
            end
        end
    end
end

% -------------------------------------------------------------------------
% TRAJECTORIES GAP FILLING (NOT ALLOWED FOR STATIC)
% -------------------------------------------------------------------------
if ~isempty(Static)
    
    % Method 0: None
    if strcmp(fmethod.type,'none')
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                if ~isempty(Trial.Marker(i).Trajectory.Gap)
                    for j = 1:size(Trial.Marker(i).Trajectory.Gap,2)
                        Trial.Marker(i).Processing.Gap(j).reconstruction = 'none';
                    end
                end
            end
        end
    end
    
    % Method 1: Linear interpolation
    %           - At least 1 point before and 1 point after gap is required (1/1
    %             are used here)
    if strcmp(fmethod.type,'linear')
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                if ~isempty(Trial.Marker(i).Trajectory.Gap)
                    for j = 1:size(Trial.Marker(i).Trajectory.Gap,2)
                        if size(Trial.Marker(i).Trajectory.Gap(j).frames,2) < fmethod.gapThreshold
                            if Trial.Marker(i).Trajectory.Gap(j).frames(1) > 1 && ...
                               Trial.Marker(i).Trajectory.Gap(j).frames(end) < Trial.n1
                                Trial.Marker(i).Trajectory.fill(Trial.Marker(i).Trajectory.Gap(j).frames(1)-1: ...
                                                                Trial.Marker(i).Trajectory.Gap(j).frames(end)+1,:) = ...
                                fillmissing(Trial.Marker(i).Trajectory.fill(Trial.Marker(i).Trajectory.Gap(j).frames(1)-1: ...
                                                                            Trial.Marker(i).Trajectory.Gap(j).frames(end)+1,:),'linear');
                            end
                            Trial.Marker(i).Processing.Gap(j).reconstruction = 'linear';
                        end
                    end
                end
            end
        end
    end

    % Method 2: Cubic spline interpolation
    %           - At least 2 point before and 2 point after gap is required 
    %             (10/10 are used here)
    if strcmp(fmethod.type,'spline')
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                if ~isempty(Trial.Marker(i).Trajectory.Gap)
                    for j = 1:size(Trial.Marker(i).Trajectory.Gap,2)
                        if size(Trial.Marker(i).Trajectory.Gap(j).frames,2) < fmethod.gapThreshold
                            if Trial.Marker(i).Trajectory.Gap(j).frames(1) > 10 && ...
                               Trial.Marker(i).Trajectory.Gap(j).frames(end) < Trial.n1-9
                                Trial.Marker(i).Trajectory.fill(Trial.Marker(i).Trajectory.Gap(j).frames(1)-10: ...
                                                                Trial.Marker(i).Trajectory.Gap(j).frames(end)+10,:) = ...
                                fillmissing(Trial.Marker(i).Trajectory.fill(Trial.Marker(i).Trajectory.Gap(j).frames(1)-10: ...
                                                                            Trial.Marker(i).Trajectory.Gap(j).frames(end)+10,:),'spline');
                            end
                            Trial.Marker(i).Processing.Gap(j).reconstruction = 'spline';
                        end
                    end
                end
            end
        end
    end

    % Method 3: Shape-preserving piecewise cubic interpolation
    %           - At least 2 point before and 2 point after gap is required 
    %             (10/10 are used here)
    if strcmp(fmethod.type,'pchip')
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                if ~isempty(Trial.Marker(i).Trajectory.Gap)
                    for j = 1:size(Trial.Marker(i).Trajectory.Gap,2)
                        if size(Trial.Marker(i).Trajectory.Gap(j).frames,2) < fmethod.gapThreshold
                            if Trial.Marker(i).Trajectory.Gap(j).frames(1) > 10 && ...
                               Trial.Marker(i).Trajectory.Gap(j).frames(end) < Trial.n1-9
                                Trial.Marker(i).Trajectory.fill(Trial.Marker(i).Trajectory.Gap(j).frames(1)-10: ...
                                                                Trial.Marker(i).Trajectory.Gap(j).frames(end)+10,:) = ...
                                fillmissing(Trial.Marker(i).Trajectory.fill(Trial.Marker(i).Trajectory.Gap(j).frames(1)-10: ...
                                                                            Trial.Marker(i).Trajectory.Gap(j).frames(end)+10,:),'pchip');
                            end
                            Trial.Marker(i).Processing.Gap(j).reconstruction = 'pchip';
                        end
                    end
                end
            end
        end
    end

    % Method 4: Modified Akima cubic Hermite interpolation
    %           - At least 1 point before and 1 point after gap is required 
    %             (10/10 are used here)
    if strcmp(fmethod.type,'makima')
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                if ~isempty(Trial.Marker(i).Trajectory.Gap)
                    for j = 1:size(Trial.Marker(i).Trajectory.Gap,2)
                        if size(Trial.Marker(i).Trajectory.Gap(j).frames,2) < fmethod.gapThreshold
                            if Trial.Marker(i).Trajectory.Gap(j).frames(1) > 10 && ...
                               Trial.Marker(i).Trajectory.Gap(j).frames(end) < Trial.n1-9
                                Trial.Marker(i).Trajectory.fill(Trial.Marker(i).Trajectory.Gap(j).frames(1)-10: ...
                                                                Trial.Marker(i).Trajectory.Gap(j).frames(end)+10,:) = ...
                                fillmissing(Trial.Marker(i).Trajectory.fill(Trial.Marker(i).Trajectory.Gap(j).frames(1)-10: ...
                                                                            Trial.Marker(i).Trajectory.Gap(j).frames(end)+10,:),'makima');
                            end
                            Trial.Marker(i).Processing.Gap(j).reconstruction = 'makima';
                        end
                    end
                end
            end
        end
    end

    % Method 5: Marker trajectories intercorrelation (https://doi.org/10.1371/journal.pone.0152616)
    if strcmp(fmethod.type,'intercor')
        tMarker = [];
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                tMarker = [tMarker Trial.Marker(i).Trajectory.fill];
            end
        end
        tMarker = PredictMissingMarkers(tMarker,'Algorithm',2);
        k = 0;
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                k = k+1;
                Trial.Marker(i).Trajectory.fill = tMarker(:,(3*k)-2:3*k);
            end
        end
        clear k tMarker;
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                if ~isempty(Trial.Marker(i).Trajectory.Gap)
                    for j = 1:size(Trial.Marker(i).Trajectory.Gap,2)
                        Trial.Marker(i).Processing.Gap(j).reconstruction = 'intercor';
                    end
                end
            end
        end
    end

    % Method 6: Apply rigid body transformation of the related segment on
    %           missing trajectories
    %           - The missing trajectories must be part of a marker related to a
    %             rigid body
    %           - At least 3 other markers, without gap, are needed on each segment
    if strcmp(fmethod.type,'rigid')
        for i = 1:size(Trial.Marker,2)        
            if ~isempty(Trial.Marker(i).Trajectory.Gap)
                for j = 1:size(Trial.Marker(i).Trajectory.Gap,2)

                    % Markers related to a rigid body
                    if strcmp(Trial.Marker(i).type,'landmark') || ...
                            strcmp(Trial.Marker(i).type,'hybrid-landmark') || ...
                            strcmp(Trial.Marker(i).type,'technical')

                        % Identify all available markers of the same segment
                        % without gap during all frames of the processed gap
                        nsegment = Trial.Marker(i).Body.Segment.label;
                        kmarker = [];
                        if strcmp(nsegment,'none') == 0 % Only for available segments
                            for k = 1:size(Trial.Marker,2)
                                if k ~= i
                                    if strcmp(Trial.Marker(k).Body.Segment.label,nsegment) == 1
                                        if ~isempty(Trial.Marker(k).Trajectory.raw)
                                            if isempty(find(isnan(Trial.Marker(k).Trajectory.fill(Trial.Marker(i).Trajectory.Gap(j).frames,1))))
                                                kmarker = [kmarker k];
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        % If at least 3 markers of the same segment are
                        % available, reconstruct the missing marker
                        if size(kmarker,2) >= 3
                            X = [];
                            for k = 1:size(kmarker,2)
                                X = [X; Static.Marker(kmarker(k)).Trajectory.fill];
                            end
                            for t = Trial.Marker(i).Trajectory.Gap(j).frames
                                Y = [];
                                for k = 1:size(kmarker,2)
                                    Y = [Y; Trial.Marker(kmarker(k)).Trajectory.fill(t,:)];
                                end
                                [R,d,rms] = soder(X,Y);
                                Trial.Marker(i).Trajectory.fill(t,:) = ...
                                    Static.Marker(i).Trajectory.fill*R'+d';
                                clear R d;
                            end
                        end
                        clear segment;
                    end
                    Trial.Marker(i).Processing.Gap(j).reconstruction = 'rigid';
                end
            end
        end               
    end
    
    % Method 7: Kalman filter (https://doi.org/10.1016/j.jbiomech.2016.04.016)
    if strcmp(fmethod.type,'kalman')
        
        % Parameters TO BE USED (TESTED)
        tol = 5e-6; %5e-6;
        sigmaR = 8e-13; %5e-2;
        
        % PROBLEM TO BE SOLVED = TRAINING WITHOUT GAPS = keep markers
        % indices ....

    end 

end

% % -------------------------------------------------------------------------
% % MISSING TRAJECTORIES RECONSTRUCTION (NOT ALLOWED FOR STATIC)
% % -------------------------------------------------------------------------
% if ~isempty(Static)
%     for i = 1:size(Trial.Marker,2)
%         if isempty(Trial.Marker(i).Trajectory.raw)
%             
%             % Markers related to a rigid body (landmarks and hybrid-landmarks)
%             if strcmp(Trial.Marker(i).type,'landmark') || ...
%                strcmp(Trial.Marker(i).type,'hybrid-landmark') || ...
%                strcmp(Trial.Marker(i).type,'technical')
%                 
%                 % Identify all available markers of the same segment
%                 % without gap during all frames of the processed gap
%                 nsegment = Trial.Marker(i).Body.Segment.label;
%                 kmarker = [];
%                 if strcmp(nsegment,'none') == 0 % Only for available segments
%                     for k = 1:size(Trial.Marker,2)
%                         if k ~= i
%                             if strcmp(Trial.Marker(k).Body.Segment.label,nsegment) == 1
%                                 if ~isempty(Trial.Marker(k).Trajectory.raw)
%                                     if isempty(find(isnan(Trial.Marker(k).Trajectory.fill(Trial.Marker(i).Trajectory.Gap(1).frames,1))))
%                                         kmarker = [kmarker k];
%                                     end
%                                 end
%                             end
%                         end
%                     end
%                 end
%                 
%                 % If at least 3 markers of the same segment are
%                 % available, reconstruct the missing marker
%                 if size(kmarker,2) >= 3
%                     X = [];
%                     for k = 1:size(kmarker,2)
%                         X = [X; Static.Marker(kmarker(k)).Trajectory.fill];
%                     end
%                     for t = Trial.Marker(i).Trajectory.Gap(1).frames
%                         Y = [];
%                         for k = 1:size(kmarker,2)
%                             Y = [Y; Trial.Marker(kmarker(k)).Trajectory.fill(t,:)];
%                         end
%                         [R,d,rms] = soder(X,Y);
%                         Trial.Marker(i).Trajectory.fill(t,:) = ...
%                             Static.Marker(i).Trajectory.fill*R'+d';
%                         clear R d;
%                     end
%                     Trial.Marker(i).Trajectory.Gap(1).reconstruction = 'rigid';
%                 end
%                 clear segment;
%                 
%             % Markers related to a curve (semi-landmarks)
%             elseif strcmp(Trial.Marker(i).type,'semi-landmark') || ...
%                    strcmp(Trial.Marker(i).type,'hybrid-landmark')
%                 
%                 % Identify all available markers of the same curve
%                 % without gap during all frames of the processed gap
%                 ncurve = Trial.Marker(i).Body.Curve.label;
%                 kmarker = [];
%                 if strcmp(ncurve,'none') == 0 % Only for available ncurve
%                     for k = 1:size(Trial.Marker,2)
%                         if k ~= i
%                             if strcmp(Trial.Marker(k).Body.Curve.label,ncurve) == 1
%                                 if ~isempty(Trial.Marker(k).Trajectory.raw)
%                                     if isempty(find(isnan(Trial.Marker(k).Trajectory.fill(Trial.Marker(i).Trajectory.Gap(1).frames,1))))
%                                         kmarker = [kmarker k];
%                                     end
%                                 end
%                             end
%                         end
%                     end
%                 end
%                 
%                 % If at least 4 markers of the same curve are available,
%                 % reconstruct the missing marker
%                 if size(kmarker,2) >= 4
%                     
%                     % Set Y level based on the mean of the previous and
%                     % next markers
%                     prev = 0;
%                     next = 0;
%                     for k = 1:size(kmarker,2) % distance1 previous and/or next markers
%                         if Trial.Marker(kmarker(k)).Body.Curve.index == ...
%                                 Trial.Marker(i).Body.Curve.index-1
%                             prev = k;
%                         elseif Trial.Marker(kmarker(k)).Body.Curve.index == ...
%                                 Trial.Marker(i).Body.Curve.index+1
%                             next = k;
%                         end
%                     end
%                     if prev == 0 || next == 0 % distance1 previous and/or next marker not available
%                         prev = 0;
%                         next = 0;
%                         for k = 1:size(kmarker,2) % distance2 previous and/or next markers
%                             if Trial.Marker(kmarker(k)).Body.Curve.index == ...
%                                     Trial.Marker(i).Body.Curve.index-2
%                                 prev = k;
%                             elseif Trial.Marker(kmarker(k)).Body.Curve.index == ...
%                                     Trial.Marker(i).Body.Curve.index+2
%                                 next = k;
%                             end
%                         end
%                     end
%                     if prev ~= 0 && next ~= 0
%                         for t = Trial.Marker(i).Trajectory.Gap(1).frames
%                             
%                             % Store and sort the position of other
%                             % semi-landmarks of the related curve
%                             temp = [];
%                             X = [];
%                             for k = 1:size(kmarker,2)
%                                 temp = [temp; Trial.Marker(kmarker(k)).Body.Curve.index];
%                                 X    = [X; Trial.Marker(kmarker(k)).Trajectory.fill(t,:)];
%                             end
%                             [~,I] = sort(temp,'descend');
%                             X = X(I,:);
%                             clear I;
%                             
%                             % Define the axis of maximal variation
%                             temp = [abs(X(1,1)-X(end,1)) abs(X(1,2)-X(end,2)) abs(X(1,3)-X(end,3))];
%                             mVar = find(temp==max(temp));
%                             if mVar == 1
%                                 X1 = X(:,1);
%                                 % Polynom is plane 1
%                                 P1 = makima(X1,X(:,2));
%                                 Y1 = ppval(P1,X1);
%                                 % Polynom is plane 2
%                                 P2 = makima(X1,X(:,3));
%                                 Z1 = ppval(P2,X1);
%                                 % Reconstruct the missing marker
%                                 X2 = (Trial.Marker(kmarker(prev)).Trajectory.fill(t,1) + ...
%                                     Trial.Marker(kmarker(next)).Trajectory.fill(t,1))/2;
%                                 Y2 = ppval(P1,X2);
%                                 Z2 = ppval(P2,X2);
%                             elseif mVar == 2
%                                 Y1 = X(:,2);
%                                 % Polynom is plane 1
%                                 P1 = makima(Y1,X(:,1));
%                                 X1 = ppval(P1,Y1);
%                                 % Polynom is plane 2
%                                 P2 = makima(Y1,X(:,3));
%                                 Z1 = ppval(P2,Y1);
%                                 % Reconstruct the missing marker
%                                 Y2 = (Trial.Marker(kmarker(prev)).Trajectory.fill(t,2) + ...
%                                     Trial.Marker(kmarker(next)).Trajectory.fill(t,2))/2;
%                                 X2 = ppval(P1,Y2);
%                                 Z2 = ppval(P2,Y2);
%                             elseif mVar == 3
%                                 Z1 = X(:,3);
%                                 % Polynom is plane 1
%                                 P1 = makima(Z1,X(:,1));
%                                 X1 = ppval(P1,Z1);
%                                 % Polynom is plane 2
%                                 P2 = makima(Z1,X(:,2));
%                                 Y1 = ppval(P2,Z1);
%                                 % Reconstruct the missing marker
%                                 Z2 = (Trial.Marker(kmarker(prev)).Trajectory.fill(t,3) + ...
%                                     Trial.Marker(kmarker(next)).Trajectory.fill(t,3))/2;
%                                 X2 = ppval(P1,Z2);
%                                 Y2 = ppval(P2,Z2);
%                             end
%                             Trial.Marker(i).Trajectory.fill(t,:) = ...
%                                 [X2 Y2 Z2];
%                             clear X P1 P2 X2 Y2 Z2;
%                         end
%                         Trial.Marker(i).Trajectory.Gap(1).reconstruction = 'curve';
%                     end
%                 end
%                 clear segment;
%             end
%         end
%     end
% end

% -------------------------------------------------------------------------
% SMOOTH ALL RESULTING TRAJECTORIES
% -------------------------------------------------------------------------
for i = 1:size(Trial.Marker,2)
    if ~isempty(Trial.Marker(i).Trajectory.fill)
        if ~isempty(Static)
            % Method 1: None
            if strcmp(smethod.type,'none')    
                Trial.Marker(i).Trajectory.smooth = Trial.Marker(i).Trajectory.fill;
                Trial.Marker(i).Processing.smooth = 'none';
            % Method 2: Low pass filter (Butterworth 2nd order, [smethod.parameter] Hz)
            elseif strcmp(smethod.type,'butterLow2')                
                [B,A]                             = butter(1,smethod.parameter/(Trial.fmarker/2),'low'); 
                Trial.Marker(i).Trajectory.smooth = filtfilt(B,A,Trial.Marker(i).Trajectory.fill);
                Trial.Marker(i).Processing.smooth = 'butterLow2';
            % Method 3: Moving average (window of [smethod.parameter] frames)
            elseif strcmp(smethod.type,'movmedian')
                Trial.Marker(i).Trajectory.smooth = smoothdata(Trial.Marker(i).Trajectory.fill,'movmedian',smethod.parameter);
                Trial.Marker(i).Processing.smooth = 'movmedian';
            % Method 4: Moving average (window of [smethod.parameter] frames)
            elseif strcmp(smethod.type,'movmean')
                Trial.Marker(i).Trajectory.smooth = smoothdata(Trial.Marker(i).Trajectory.fill,'movmean',smethod.parameter);
                Trial.Marker(i).Processing.smooth = 'movmean';
            % Method 5: Gaussian-weighted moving average (window of [smethod.parameter] frames)
            elseif strcmp(smethod.type,'gaussian')
                Trial.Marker(i).Trajectory.smooth = smoothdata(Trial.Marker(i).Trajectory.fill,'gaussian',smethod.parameter);
                Trial.Marker(i).Processing.smooth = 'gaussian';
            % Method 6: Robust quadratic regression (window of [smethod.parameter] frames)
            elseif strcmp(smethod.type,'rloess')
                Trial.Marker(i).Trajectory.smooth = smoothdata(Trial.Marker(i).Trajectory.fill,'rloess',smethod.parameter);
                Trial.Marker(i).Processing.smooth = 'rloess';
            % Method 7: Savitzky-Golay filter (window of [smethod.parameter] frames)
            elseif strcmp(smethod.type,'sgolay')
                Trial.Marker(i).Trajectory.smooth = smoothdata(Trial.Marker(i).Trajectory.fill,'sgolay',smethod.parameter);
                Trial.Marker(i).Processing.smooth = 'sgolay';
            end
        else
            Trial.Marker(i).Trajectory.smooth = Trial.Marker(i).Trajectory.fill;
        end
    else
        Trial.Marker(i).Trajectory.smooth = [];
        Trial.Marker(i).Processing.smooth = 'none';
    end
end