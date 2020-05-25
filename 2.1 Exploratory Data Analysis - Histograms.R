# EXPLORATORY DATA ANALYSIS
# Create histograms

# Libraries
library(stringr)
library(lattice)

# Parameters
cnnString = "Driver={SQL Server Native Client RDA 11.0};Server=CLSCLSQL01\\SQLSERVER2017;Database=School_Dropout;Trusted_Connection=yes"
plotsRelativePath = "../Plots/"

t0 = Sys.time()

# Initialise data source pointer to SQL Server observations table
sql_Obs = RxSqlServerData(sqlQuery="select * from Observation_Student", connectionString = cnnString)

# Get variable names
varNames = rxGetVarNames(sql_Obs)
k = length(varNames)

for (i in 3:k) {
  
  print(i)
  
  variable = varNames[i] # Get variable name
  
  if (str_sub(variable, -6, -1) == "_Label") { # If variable name of type Label, skip
    next
  }
  
  # Plot histogram and save in file
  Rtxt = paste("g = rxHistogram(~ ", variable, ", data = sql_Obs, histType = \"Percent\", title = \"", variable, " Histogram\", reportProgress = 1)", sep = "")
  eval(parse(text = Rtxt))
  pathFile = paste(plotsRelativePath, variable, "_Histogram.png", sep = "")
  trellis.device("png", file = pathFile)
  print(g)
  dev.off()
  
}

Sys.time() - t0 # 14 minutes
