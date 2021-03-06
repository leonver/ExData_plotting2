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
#3.Of the four types of sources indicated by the type (point, nonpoint, onroad, nonroad) variable, 
# which of these four sources have seen decreases in emissions from 1999-2008 for Baltimore City? 
# Which have seen increases in emissions from 1999-2008? Use the ggplot2 plotting system to make 
# a plot answer this question.

library(plyr)

#Select data for baltimore fips = "24510"
  NEI.Baltimore <- subset(NEI, fips == "24510")
        
        
#the table contains number of tons of PM2.5 emitted from a specific type of source for the entire year
# check the number of observation per source , type and year         
    UniquePoints <- count(NEI.Baltimore, c("SCC", "type", "year")) 

#There are more than one obeservations per year, we take the average per source, type and  year)
        
    PointsStat <- ddply(NEI.Baltimore, c("SCC", "type", "year"), 
                  summarize, EmmissionMean =mean(Emissions), 
                             NrObs = length(Emissions))
        
#Not every point has observation for every year only the points with an observation for every year 
#are taken as data for the plot.    
    PointsYearCount <- count(PointsStat, c("SCC", "type"))    
        
    EveryYearPoints <- subset(PointsYearCount, freq == 4)
        
#Select the data with values for every year
        
    cleaned.data <- merge(x = PointsStat, y= EveryYearPoints, by= c("SCC", "type"))      
        
library(ggplot2)
        
png('plot3.png', width = 480, height= 480, units = "px")
g <- ggplot(cleaned.data, aes(year, EmmissionMean, color= type))
g <- g + geom_line(stat = "summary", fun.y = "sum")
g <- g + ylab(expression("y axis"))  
g <- g + ggtitle("Emmisions pm2.5 for Baltimore city by type")        
print(g)        
dev.off()   
        
        
      