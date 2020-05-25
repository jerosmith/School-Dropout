# EXPLORATORY DATA ANALYSIS
# Create scatterplots

# Libraries
library(stringr)
library(ggplot2)

# Parameters
cnnString = "Driver={SQL Server Native Client RDA 11.0};Server=CLSCLSQL01\\SQLSERVER2017;Database=School_Dropout;Trusted_Connection=yes"
PlotsRelativePath = "../Plots/"

t0 = Sys.time()

# Get variable names
sql_Obs = RxSqlServerData(sqlQuery="select * from Observation_Student", connectionString = cnnString)
varNames = rxGetVarNames(sql_Obs)
k = length(varNames)

for (i in 3:k) {
  print(i)
  
  variable = varNames[i]
  
  if (str_sub(variable, -6, -1) == "_Label") {
    next
  }
  
  txtsql = paste("select", variable, ", sum(convert(float,DropOut))/convert(float,count(*)) as DropOut_Probability from Observation_Student group by", variable)
  sql_Obs = RxSqlServerData(sqlQuery = txtsql, connectionString = cnnString)
  df_Obs = rxImport(sql_Obs)
  
  txtR = paste("g = ggplot(df_Obs, aes(y = DropOut_Probability, x =", variable, "))")
  eval(parse(text = txtR))
  g = g + geom_point(colour = "red")
  g = g + ggtitle(paste("Dropout Probability vs", variable, "Scatterplot"))
  
  path_file = paste(PlotsRelativePath, variable, "_Scatterplot.png", sep = "")
  ggsave(filename = path_file, plot = g)
  
  if (grepl("Ord", variable)) {
    
    label = varNames[i+1]
    txtsql = paste("select", variable, ",", label, ", sum(convert(float,DropOut))/convert(float,count(*)) as DropOut_Probability from Observation_Student group by", variable, ",", label)
    sql_Obs = RxSqlServerData(sqlQuery = txtsql, connectionString = cnnString)
    df_Obs = rxImport(sql_Obs)
    df_Obs[, 2] = str_sub(df_Obs[, 2], 1, 50)
    df_Obs[, 2] = gsub("[^a-zA-Z//]", " ", df_Obs[, 2])
    if (nrow(df_Obs) >= 500) {
      select = sample(rownames(df_Obs), size = 500)
      df_Obs = df_Obs[select, ]
    }
    
    g = ggplot(df_Obs, aes(y = DropOut_Probability, x = df_Obs[, 1]))
    g = g + geom_col(fill = "red")
    g = g + scale_x_continuous(breaks = df_Obs[, 1], labels = df_Obs[, 2])
    g = g + coord_flip()
    g = g + xlab(variable)
    g = g + ggtitle(paste("Dropout Probability vs", variable, "Barchart"))

    path_file = paste(PlotsRelativePath, variable, "_Barchart.png", sep = "")
    if (nrow(df_Obs) <= 100) {
      ggsave(filename = path_file, plot = g)
    } else {
      ggsave(filename = path_file, plot = g, units = "cm", height = 100)  
    }
    
  }

}

Sys.time() - t0 # 52 sec
