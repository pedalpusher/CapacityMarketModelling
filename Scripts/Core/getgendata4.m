function supply = getgendata4()

%% Get raw data
%path='C:\Users\davidchristopherson\Documents\MATLAB\~Capacity Market Modelling\~Raw Data\Existing and new capacity_alkane_20140306.xlsx';
path='J:\MAR-01\End of Coal capacity_Marchwood_20140404.xlsx';
[~,~,r]=xlsread(path,'Death to coal');

%% Organise and reformat data

%Set technology catergories
techs= {'Coal','OCGT','CCGT','Oil','Nuclear','WindOn','WindOFF',...
        'Hydro','Biomass','CHP','SolarWaveTidal'};%,'Interconnector''PumpedStorage',
%Reference technology calls
techname={{'coal','coal/oil','Gas/Coal/Oil','coal/biomass','coal/biomass ',...
          'coal/biomass/gas/waste derived fuel','coal/oil','Coal'};...
          {'OCGT','gas oil','gas turbine','mines gas','gas/oil','landfill gas','mines gas'};...
          {'CCGT','Gas','gas'};...
          {'oil','diesel','light oil','gas oil/kerosene'};...
          {'nuclear'};...
          {'wind','wind  ','wind   ','Wind'};...
          {'Wind (offshore)','wind (offshore)'};{'hydro'};...
          {'meat & bone meal','poultry litter','rapeseed oil','straw/gas','various fuels',...
          'waste','biomass','AWDF ','Biomass','biomass and waste'};...
          {'Gas CHP','Gas/Gas oil CHP','gas CHP'};...
          {'solar photovoltaics and wave/tidal'}};%;...{'interconnector'};{'hydro/ pumped storage','pumped storage'};...

%Create supply struct
for i=1:1:length(techs)
    supply.(techs{i}).plants=[];
end

for i=1:1:length(techs)
    for k=2:1:458
        if max(strcmp(r{k,3},techname{i}))
            tech=r{k,3};
            cap=r{k,4};
            startyear=r(k,5);
            location=r{k,6};
            if ~isnan(r{k,7})
                endyear=r{k,7};
            else
                endyear=2050;
            end
            if ~isnan(r{k,8})
                note=(r{k,8});
            else
                note=[];
            end
            companyname=r{k,1};
            plantname=r{k,2};
            pname=r{k,2};
            if ~isnan(pname)
                for j=length(pname):-1:1
                    if strcmp(pname(j),' ')
                        pname(j)=[];
                    end
                end
                for j=length(pname):-1:1
                    if strcmp(pname(j),'&')
                        pname(j)=[];
                    end
                end
                for j=length(pname):-1:1
                    if strcmp(pname(j),'.')
                        pname(j)=[];
                    end
                end
                 for j=length(pname):-1:1
                    if strcmp(pname(j),'(')
                        pname(j)=[];
                    end
                 end
                 for j=length(pname):-1:1
                    if strcmp(pname(j),')')
                        pname(j)=[];
                    end
                 end
                 for j=length(pname):-1:1
                    if strcmp(pname(j),'-')
                        pname(j)=[];
                    end
                 end
                 for j=length(pname):-1:1
                    if strcmp(pname(j),'’')
                        pname(j)=[];
                    end
                 end
                 for j=length(pname):-1:1
                    if strcmp(pname(j),',')
                        pname(j)=[];
                    end
                 end
                 for j=length(pname):-1:1
                    if strcmp(pname(j),'''')
                        pname(j)=[];
                    end
                 end
            end
            supply.(techs{i}).plants.(pname)=struct('Name',plantname,'Owner',...
            companyname,'Capacity',cap,'StartYear',startyear,'EndYear',endyear',...
            'Location',location,'Technology',tech,'Note',note);
        end
    end
end

%% Import technological and financial specifications

path2 = 'C:\Users\davidchristopherson\Documents\MATLAB\~Capacity Market Modelling\Results\Technology Database.xlsx';
[~,~,r2]=xlsread(path2,'tech');
[~,~,r3]=xlsread(path2,'availability');

for i=1:1:length(techs)
    supply.(techs{i}).specs=struct('Efficiency',r2{(i+2),2},'CAPEX',r2{(i+2),3},'OPEXF',r2{(i+2),4},...
                                   'OPEXV',(r2{(i+2),5}),'Lifetime',r2{(i+2),6},'Contrib',r2{(i+2),6},...
                                   'Availability',{(r3((i+2),(2:13)) )});
end        