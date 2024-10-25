# 'multiple_netcdf_read': Function to read and extract information from multiple netcdf files, downloaded for example from copernicus.#
#                                                                                                                                     #
# Neus Campanyà-Llovet. (2024). neuscamllo/multiple_netcdf_read: v1.0.0 (v1.0.0). Zenodo. https://doi.org/10.5281/zenodo.13992594     #
#                                                                                                                                     #
# INPUT:                                                                                                                              #   
#     -   yearf : first year of the time series                                                                                       #
#     -   yearl : last year of the time series                                                                                        #
#     -   file_name: name of the part of the file that does not vary, constant throughout the files.                                  #
#                     It often corresponds with the name of the model and variable of interest.                                       #
#     -   wd: working directory. Folder where files have been stored.                                                                 #
#                                                                                                                                     #
# OUTPUT:                                                                                                                             #
#     -   List of dataframes where each element contains the extracted variables corresponding to each year:                          #
#                 Latitude, Longitude, Depth, Mean Thetao                                                                             #
#                                                                                                                                     #        
# Library requirements: ncdf4                                                                                                         #                    
#######################################################################################################################################


multiple_netcdf_read <- function(yearf, yearl, file_name, wd){
  setwd(wd)
  tt_list <- list()
  for (i in yearf:yearl) {
    nc_data <- ncdf4::nc_open(paste(file_name, i, ".nc", sep = ""))
    # Extracting variables
    lat <- ncdf4::ncvar_get(nc_data, "latitude")
    lon <- ncdf4::ncvar_get(nc_data, "longitude")
    tim <- ncdf4::ncvar_get(nc_data, "time")
    dep <- ncdf4::ncvar_get(nc_data, "depth")
    nlat <- dim(lat)
    nlon <- dim(lon)
    ntim <- dim(tim)
    ndep <- dim(dep)
    
    tt_array <- ncdf4::ncvar_get(nc_data, "thetao")
    tt_fv <- ncdf4::ncatt_get(nc_data, "thetao","_FillVallue") # Value used in copernicus to express what we express with NAs in R
    dim(tt_array)
    tt_array[tt_array == tt_fv$value] <- NA 
    
    # creating a dataframe
    lonlattimedep <- as.matrix(expand.grid(lon,lat,tim,dep)) # Thetao has 4 dimensions (x,y,z,t)
    tt_vec <- as.vector(tt_array)
    tt_obs <- data.frame(cbind(lonlattimedep, tt_vec))
    colnames(tt_obs) <- c("Long","Lat","time","depth","thetao_celsius")
    tt_obs <- tt_obs[complete.cases(tt_obs),]# We remove NAs from our dataset
    
    # Calculating annual means
    tt_yr <- tt_obs %>% group_by(Long,Lat,depth) %>% summarise(mean_thetao = mean (thetao_celsius))
    
    # storing the data
    tt_list[[as.character(i)]] <- tt_yr
    
  } 
  return(tt_list)
}

res <- multiple_netcdf_read(2000,2001,"CMEMS-GLOBAL_001_030-bottomT_thetao-","C:/R/copernicus-tmp-data")
