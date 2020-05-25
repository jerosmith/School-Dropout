# EXPLORATORY DATA ANALYSIS
# Create specialised, more detailed plots, for example eliminating outliers

# Libraries
library(stringr)
library(lattice)
library(ggplot2)

# Parameters
cnnString = "Driver={SQL Server Native Client RDA 11.0};Server=CLSCLSQL01\\SQLSERVER2017;Database=School_Dropout;Trusted_Connection=yes"
plotsRelativePath = "../Plots/"

# Initialise data source pointer to SQL Server observations table
sql_Obs_Hist = RxSqlServerData(sqlQuery="select * from Observation_Student", connectionString = cnnString)

# AgeDifference_wr_LevelGrade plots
variable = "AgeDifference_wr_LevelGrade"
startVal = -1
endVal = 5

# Histogram
Rtxt = paste("g = rxHistogram(~ ", variable, ", sql_Obs_Hist, startVal = startVal, endVal = endVal, histType = \"Percent\", title = \"", variable, " Histogram\", reportProgress = 1)", sep = "")
eval(parse(text = Rtxt))
pathFile = paste(plotsRelativePath, variable, "_Histogram_No_Outliers.png", sep = "")
print(g)
trellis.device("png", file = pathFile)
print(g)
dev.off()

# Scatterplot
txtsql = paste("select", variable, ", sum(convert(float,DropOut))/convert(float,count(*)) as DropOut_Probability from Observation_Student group by", variable)
sql_Obs_Scatter = RxSqlServerData(sqlQuery = txtsql, connectionString = cnnString)
df_Obs = rxImport(sql_Obs_Scatter)
txtR = paste("g = ggplot(df_Obs, aes(y = DropOut_Probability, x =", variable, "))")
eval(parse(text = txtR))
g = g + geom_point(colour = "red")
g = g + ggtitle(paste("Dropout Probability vs", variable, "Scatterplot"))
g = g + scale_x_continuous(limits = c(-1, 5), breaks = seq(-1, 5, 1))
g = g + ggtitle(paste("Dropout Probability vs", variable, "Scatterplot Without Outliers"))
g
pathFile = paste(plotsRelativePath, variable, "_Scatterplot_No_Outliers.png", sep = "")
ggsave(pathFile, g)
