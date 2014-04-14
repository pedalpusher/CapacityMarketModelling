function data = getdata()

data=struct('supply',[],'demand',[]);

data.supply=getgendata4();

data.demand=getdemand();

data = ratedoutputs (data);

data = demandtrendforecastannual(data);

data = supplyseries (data);

data = margins3 (data);