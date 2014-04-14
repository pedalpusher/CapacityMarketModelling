function data = ratedoutputs (data)

supply=data.supply;

%% Find total name-plate technological capacities (annual)
techs=fieldnames(supply);
for i=1:1:length(techs)
    if ~isempty(supply.(techs{i}).plants)
        plants=fieldnames(supply.(techs{i}).plants);
    else
        plants=[];
    end
    for j=1:1:length(plants)
        output{j}=supply.(techs{i}).plants.(plants{j}).Capacity;
    end
    totaloutput=sum(cell2mat(output));
    supply.(techs{i}).outputs.totaloutput=totaloutput;
    clear plants
end


%% Find total de-rated technological capacities (monthly)
for i=1:1:12
    for j=1:1:length(techs)
        deratedtechoutput(i,j)=(supply.(techs{j}).specs.Availability{i})*(supply.(techs{j}).outputs.totaloutput);
        supply.(techs{j}).outputs.derated=deratedtechoutput(:,j);
    end
end

%% Find individual de-rated technological capacities (monthly)
for i=1:1:12
    for j=1:1:length(techs)
        if ~isempty(supply.(techs{j}).plants)
            plants=fieldnames(supply.(techs{j}).plants);
        else
            plants=[];
        end
        for k=1:1:length(plants)
            derated(i,j,k)=(supply.(techs{j}).specs.Availability{i})*(supply.(techs{j}).plants.(plants{k}).Capacity);
            supply.(techs{j}).plants.(plants{k}).DeratedCapacity=derated(:,j,k);
        end
        clear plants
    end
end

%% Find total de-rated UK generation capacity (monthly)
for i=1:1:12
    for j=1:1:length(techs)
        deratedtechoutput(i,j)=(supply.(techs{j}).specs.Availability{i})*(supply.(techs{j}).outputs.totaloutput);
        supply.(techs{j}).outputs.derated=deratedtechoutput(:,j);
        deratedtotaloutput(i)=sum(deratedtechoutput(i,:));
    end
end

data.supply=supply;