function data = supplyseries (data)

%% Find year labels
months=data.timeseries.dates;
formatIn='mmmyy';
for a=1:1:length(months)
    years(a)=str2num(datestr(datenum(months(a),formatIn),11));
end

%% Find total national generation capacity and derated capacity series

techs=fieldnames(data.supply);

for a=1:1:length(months)
    for b=1:1:length(techs)
        if ~isempty(data.supply.(techs{b}).plants)
            plants=fieldnames(data.supply.(techs{b}).plants);
        else
            plants=[];
        end
        for c=1:1:length(plants)
            endyear=data.supply.(techs{b}).plants.(plants{c}).EndYear;
            if (endyear>(2000+years(a)))
                mnum=a-(floor((a-1)/12))*12;
                pcap(c)=data.supply.(techs{b}).plants.(plants{c}).Capacity;
                pdecap(c)=data.supply.(techs{b}).plants.(plants{c}).DeratedCapacity(mnum);
            end %else = 0?
        end
        techcap(b)=sum(pcap);
        techdecap(b)=sum(pdecap);
        clear pcap
        clear pdecap
    end
    data.timeseries.techcap{a}=sum(techcap);
    data.timeseries.techdecap{a}=sum(techdecap);
    clear techcap
    clear techdecap
end

%% Find deployed baseload capacity

basetechs={'Coal','Nuclear','Hydro','Biomass'};
techs=fieldnames(data.supply);

for a=1:1:length(months)   
    for b=1:1:length(techs)
        if max(strcmp(techs(b),basetechs))%if is one of basetechs
            if ~isempty(data.supply.(techs{b}).plants)
                plants=fieldnames(data.supply.(techs{b}).plants);
            else
                plants=[];
            end
                for c=1:1:length(plants)
                    endyear=data.supply.(techs{b}).plants.(plants{c}).EndYear;
                    if (endyear>(2000+years(a)))
                        mnum=a-(floor((a-1)/12))*12;
                        basepdecap(c)=data.supply.(techs{b}).plants.(plants{c}).DeratedCapacity(mnum);
                    end %else = 0?
                end
                basetechdecap(b)=sum(basepdecap);
                clear basepdecap
        end
    end
    data.timeseries.deployedbase{a}=sum(basetechdecap);
    clear basetechdecap  
end

%% Convert deployed base to annual resolution

deployedbase=data.timeseries.deployedbase;
for a=1:1:(length(deployedbase)/12)
    start=1+(12*(a-1));
    fin=start+11;
    annualdeployedbase(a)=mean(cell2mat(deployedbase(start:fin)));
end

data.timeseries.baseCAP=annualdeployedbase;

%% Find required 'peak' capacity

baseDEM=data.timeseries.basedemand;
for a=1:1:length(annualdeployedbase)
    peakCAP(a)=baseDEM(a)-annualdeployedbase(a);
end

%% Find available capacity in generation mix, deploy as needed and report names

%CCGT only for now
for c=1:1:length(peakCAP)
    peakDEPLOYED=0;
    capAVAILABLE=0;
    for a=1:1:length(fieldnames(data.supply.CCGT.plants))
        plants=fieldnames(data.supply.CCGT.plants);
        for b=1:1:length(plants)
            if peakDEPLOYED<peakCAP(c)
                peakDEPLOYED=peakDEPLOYED+mean(data.supply.CCGT.plants.(plants{b}).DeratedCapacity);
                peakNAMES{b}=plants(b);
            end
        end
    end
    data.timeseries.peakDEP(c)=peakDEPLOYED;
    data.timeseries.peakNAMES{c}=peakNAMES;
    clear peakDEPLOYED
    clear peakNAMES
end

%% Find plants available for capacity market (CCGT)

for c=1:1:length(peakCAP)
    plants=fieldnames(data.supply.CCGT.plants);
    for b=1:1:length(plants)
        if max(strcmp([data.timeseries.peakNAMES{c}{:}],plants(b)))
            capplants{b}=plants{b};
        end
    end
    %data.timeseries.capNAMES{c}.CCGT=capplants;
    clear capplants
end

for a=1:1:length(peakCAP)
    
    l=length(data.timeseries.peakNAMES{a});
    data.timeseries.capNAMES.CCGT{a}=[plants(l:end)];
    
    plants=fieldnames(data.supply.CCGT.plants);
    for b=1:1:length(plants)
        cap(b)=mean(data.supply.CCGT.plants.(plants{b}).DeratedCapacity);
    end
    
    data.timeseries.capAVAILABLE.CCGT(a)=sum(cap(l:end));
    clear cap
end

%% Find CHP,Oil,OCGT plants available for capacity markets

for a=1:1:length(peakCAP)
    captechs={'OCGT','Oil','CHP'};
    for b=1:1:length(captechs)
        plants=fieldnames(data.supply.(captechs{b}).plants);
        for c=1:1:length(plants)
             cap(c)=mean(data.supply.(captechs{b}).plants.(plants{b}).DeratedCapacity);
             names{c}=plants(c);
        end
        data.timeseries.capAVAILABLE.(captechs{b})(a)=sum(cap);
        data.timeseries.capNAMES.(captechs{b}){a}=names;
        clear plants
        clear cap
        clear names
    end
end

% Plot output (optional)
chart=false;
if chart
    plot (data.timeseries.capAVAILABLE.CCGT)
    plot (data.timeseries.capAVAILABLE.OCGT)
    plot (data.timeseries.capAVAILABLE.Oil)
    plot (data.timeseries.capAVAILABLE.CHP)
end