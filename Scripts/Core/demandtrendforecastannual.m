function data = demandtrendforecastannual(data)

%% Get demand data

dmd=data.demand.demand;

%% Find 83pc,max,demandgap numbers for historic data

baseDEM=prctile(cell2mat(dmd),83);
maxDEM=prctile(cell2mat(dmd),99.5);
gapDEM=prctile(cell2mat(dmd),99.5)-prctile(cell2mat(dmd),83);

%% Find capacity market uptake

for a=1:1:length(dmd)
    if dmd{a}>baseDEM
        capDEM(a)=cell2mat(dmd(a))-baseDEM;
    else
        capDEM(a)=0;
    end
end

kWperiods=sum(capDEM)/4;%sum of 1/2 hourly KW periods averaged over 4 year period

uptake=(mean(capDEM))/gapDEM;
        
%% Input annual variation profile

FES= cell2mat({1.01319,	1.010229246,	1.005524136,	0.997648895,	0.986985943,	0.979819339,	0.977034763,	0.97722979,	0.976842518,	0.979048336,	0.982794673,	0.987817307});
data.demand.fesvariation=FES;

%% Find maxdemand,83demand,demandgap,uptake forecasts for 2014-2025

%max demand
for a=1:1:length(FES)
    FmaxDEM(a)=maxDEM.*FES(a);
end

%83demand
for a=1:1:length(FES)
    FbaseDEM(a)=baseDEM.*FES(a);
end

%demandgap
for a=1:1:length(FES)
    FgapDEM(a)=gapDEM.*FES(a);
end

%uptake
for a=1:1:length(FES)
    Fuptake(a)=uptake.*FES(a);
end

%% Structure arrays

data.timeseries.maxdemand=FmaxDEM;
data.timeseries.basedemand=FbaseDEM;
data.timeseries.gapdemand=FgapDEM;
data.timeseries.uptake=Fuptake;

%% Dates!
nyears=12;
for a=1:1:nyears
    temp{a}=cellstr(datestr(datenum((2013+a),1:12,1),12));
end
dateC=[temp{1};temp{2};temp{3};temp{4};temp{5};temp{6};temp{7};temp{8};temp{9};temp{10};temp{11};temp{12}]';
data.timeseries.dates=dateC;

%% Target demand


