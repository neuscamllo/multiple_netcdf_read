# multiple_netcdf_read
Reading and extracting data from multiple netcdf files into R.

This function is designed to import and extract environmental data from multiple netcdf files (corresponding to a time series) into R.

The input variables are relevant to the netcdf files names (i.e., year, file name and working directory).

The function returns a list of dataframes where each element corresponds to a year of the time series. The information provided into each dataframe corresponds to latitude, longitude, depth, and the corresponding variable.
