function data=margins3(data)

%% Get margin data

path='C:\Users\davidchristopherson\Documents\MATLAB\~Capacity Market Modelling\~Raw Data\Copy of Past and future whoelsale prices_20140306.xlsx';
%path = 'J:\ALK-01\Copy of Past and future whoelsale prices_20140306.xlsx';
%path='J:\ALK-01\Wholesale prices master sheet.xlsx';
%path='J:\MAR-01\Wholesale prices master sheet.xlsx';
%[~,~,rmar]=xlsread(path,'Future Wholesale Prices (NG)');
%[~,~,rmar]=xlsread(path,'Future Wholesale Prices (DECC)');
[~,~,rmar]=xlsread(path,'Future Wholesale Prices (FPC)');

%% Calculate margins

captechs={'CCGT','OCGT','CHP','Oil'};
nyears=13;
for a=1:1:nyears
    for b=1:1:length(captechs)
        mpower(a,b)=rmar{4,(2+a)}; % power margin = power price
        mfuel(a,b)=(rmar{3,3+a})/data.supply.(captechs{b}).specs.Efficiency; % fuel margin = fuel price(£/MWhg) * (1/eff)
        mcarbon(a,b)=(rmar{11,3+a}); % carbon margin = carbon price(£/MWhe)
        mfixed(a,b)=2.9; % from DECC cost model
        mvariable(a,b)=0.1; % from DECC costs model
        margin(a,b)=mpower(a,b)-mfuel(a,b)-mcarbon(a,b)-mfixed(a,b)-mvariable(a,b);
        spread(a,b)=mpower(a,b)-mfuel(a,b)-mcarbon(a,b);
    end
end

%% Calculate offerprices

netcone=29;
for a=1:1:nyears
    offerprice(a)=-(margin(a,1)-(margin(1,1)))*(365.25*24/1000)*0.75;
end

%% Cap and rationalise offerprices

cappedofferprice=offerprice;
for a=1:1:nyears
    if offerprice(a)<0
        cappedofferprice(a)=0;% no negative bids
    elseif offerprice(a)>(netcone/2)
        cappedofferprice(a)=(netcone/2);%cap bids at netcone/2
    end
end

data.timeseries.offerprice=offerprice;
data.timeseries.cappedofferprice=cappedofferprice;
spread(1,1)=2.5;
data.timeseries.spread=spread(:,1);