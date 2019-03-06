function matbrut = LoadMarkersNorm(pathses, filename)         

load([pathses '\' filename], 'Marker', 'RefPoint');
pelviscenter = mean([Marker.Marker.LASIS.Data; ...
    Marker.Marker.RASIS.Data; ...
    Marker.Marker.LPSIS.Data; ...
    Marker.Marker.RPSIS.Data]);
%Pelvis
lasis = mean(Marker.Marker.LASIS.Data) - pelviscenter;
rasis = mean(Marker.Marker.RASIS.Data) - pelviscenter;
asis = (lasis + rasis)/2;
lpsis = mean(Marker.Marker.LPSIS.Data) - pelviscenter;
rpsis = mean(Marker.Marker.RPSIS.Data) - pelviscenter;
sacr = (lpsis + rpsis)/2;
%Ankle/Foot
lankcenter = mean(RefPoint.RefPoint.LAnkle.Data) + [0 100 1000];
rankcenter = mean(RefPoint.RefPoint.RAnkle.Data) + [0 -100 1000];
lmidmt = mean(RefPoint.RefPoint.LMidMT.Data) - lankcenter;
lcalc = mean(RefPoint.RefPoint.LCalcaneus.Data) - lankcenter;
lmedmalleole = mean(RefPoint.RefPoint.LMedialMalleolus.Data) - lankcenter;
llatmalleole = mean(RefPoint.RefPoint.LLateralMalleolus.Data) - lankcenter;
rmidmt = mean(RefPoint.RefPoint.RMidMT.Data) - rankcenter;
rcalc = mean(RefPoint.RefPoint.RCalcaneus.Data) - rankcenter;
rmedmalleole = mean(RefPoint.RefPoint.RMedialMalleolus.Data) - rankcenter;
rlatmalleole = mean(RefPoint.RefPoint.RLateralMalleolus.Data) - rankcenter;
%Knee
lknee = mean(RefPoint.RefPoint.LKnee.Data) - lankcenter;
llatepic = mean(RefPoint.RefPoint.LLateralFemoralEpicondyle.Data) - lankcenter;
lmedepic = mean(RefPoint.RefPoint.LMedialFemoralEpicondyle.Data) - lankcenter;
rknee = mean(RefPoint.RefPoint.RKnee.Data) - rankcenter;
rlatepic = mean(RefPoint.RefPoint.RLateralFemoralEpicondyle.Data) - rankcenter;
rmedepic = mean(RefPoint.RefPoint.RMedialFemoralEpicondyle.Data) - rankcenter;
matbrut = [lasis; rasis; lpsis; rpsis; asis; sacr; ...
    lmedmalleole; llatmalleole; lmidmt; lcalc; ...
    rmedmalleole; rlatmalleole; rmidmt; rcalc; ...
    lknee; lmedepic; llatepic; ...
    rknee; rmedepic; rlatepic];

end