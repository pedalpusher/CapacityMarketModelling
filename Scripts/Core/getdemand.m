function dmddata = getdemand()

%% Define source paths
path='C:\Users\davidchristopherson\Documents\MATLAB\~Capacity Market Modelling\~Raw Data\Demand_Jan 2010 to Dec 2012.xls';
[~,~,r3]=xlsread(path,'Demands');

path='C:\Users\davidchristopherson\Documents\MATLAB\~Capacity Market Modelling\~Raw Data\Demand_Jan to Dec 2013.xls';
[~,~,r4]=xlsread(path,'Demands');

%% Extract, collate tabledates
tabledates1={r3{(2:end),1}};
tabledates2={r4{(2:end),1}};
tabledates={[tabledates1,tabledates2]};
tabledates=tabledates{1};

%% Define, format model dates
startdate='01/01/2010 00:00:00';
enddate='31/12/2013 23:30:00';
formatIn='dd/mm/yyyy HH:MM:SS';
stamps=linspace(datenum(startdate,formatIn),datenum(enddate,formatIn),((4*365*24*2)+48));
dates=datestr(stamps);
dateC=cellstr(dates).';

%% Extract, collate demand data
dmd1={r3{(2:end),6}};
dmd2={r4{(2:end),6}};
dmd={[dmd1,dmd2]};
dmd=dmd{1};

%% Future energy scenario annual variation
fesvariation=cell2mat({1.01319, 1.010229246, 1.005524136,	0.997648895, 0.986985943, 0.979819339,	0.977034763, 0.97722979, 0.976842518, 0.979048336, 0.982794673,	0.987817307});

%% Structuring
dmddata=struct();
dmddata.tabledates=tabledates;
dmddata.dates=dateC;
dmddata.demand=dmd;
dmddata.fesvariation=fesvariation;
%dmddata=struct('tabledates',tabledates,'dates',dateC,'demand',dmd);


