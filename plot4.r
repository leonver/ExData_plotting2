## this script creates a graph from data downloaded from the internet.

# Conditional download data from the internet

    # Create a data folder for the data to download
        if (!file.exists("downloaddata")) 
        {
            dir.create("./downloaddata")
        }
    
    #name to give to the dataset to download
        dataset.zip <- "./downloaddata/dataset.zip"
    
    #check if the data is already present in the folder
        
        if (!file.exists(dataset.zip))
        {
            #location of the file to download
            downloadurl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
            #execute download
            download.file(downloadurl, destfile=dataset.zip, mode="wb")
            #extract the data from the zipfile
            unzip(dataset.zip, exdir="./downloaddata")
        }
        
#read the data if it's not already available in memory
    if (!exists("NEI"))
    {        
        NEI <- readRDS("downloaddata/summarySCC_PM25.rds")
        if (nrow(NEI[!complete.cases(NEI),]) == 0 )
        {    
            message("No NA's in dataset NEI")
            #check duplicates
        }    
        else message("Dataset NEI with NA's, take further action")
        SCC <- readRDS("downloaddata/Source_Classification_Code.rds")
        if (nrow(SCC[!complete.cases(SCC),]) == 0)
        {    
            message("No NA's in dataset SCC")
        }    
        else 
        {
            message("Dataset SCC with NA's take further action")
            #variables Map.To (11358) and Last.Inventory.Year (8972) contains NA's
        }    
    }    
#4.Across the United States, how have emissions from coal combustion-related
# sources changed from 1999-2008?

library(plyr)

#Select coal combustion related data
    SCC.coal <- SCC[grepl("coal", SCC$EI.Sector, ignore.case = TRUE), ]
    Coal.data <- merge(x = NEI, y= SCC.coal, by= "SCC")      
        
#the table contains number of tons of PM2.5 emitted from a specific type of source for the entire year
# check the number of observation per source , type and year         
    UniquePoints <- count(Coal.data, c("SCC", "type", "year")) 

#There are more than one obeservations per year, we take the average per source, type and  year)
        
    PointsStat <- ddply(Coal.data, c("SCC", "type", "year"), 
                  summarize, EmmissionMean =mean(Emissions), 
                             NrObs = length(Emissions))
        
#Not every point has observation for every year only the points with an observation for every year 
#are taken as data for the plot.    
    PointsYearCount <- count(PointsStat, c("SCC", "type"))    
        
    EveryYearPoints <- subset(PointsYearCount, freq == 4)
        
#Select the data with values for every year
        
    cleaned.data <- merge(x = PointsStat, y= EveryYearPoints, by= c("SCC", "type"))      

#Summarize amount for each year

plot.data <- ddply(cleaned.data, "year", summarize, SumEmmission = sum(EmmissionMean))   

png('plot4.png', width = 480, height= 480, units = "px")
plot(plot.data, type = "l", 
     xlab = "year", 
     ylab = "Emmision in tons", 
     main = "Totaal emmission PM2.5 for coal combustion")       
dev.off()        
    

        
        
      