# EXPLORATORY DATA ANALYSIS 2
# Create correlation tables

# Libraries
install.packages("rJava")
install.packages("xlsx")
library(stringr)
Sys.setenv(JAVA_HOME='C:/Program Files/Java/jre-9.0.1') # Prerequisite for loading xlsx
library(xlsx)

# Parameters
cnnString = "Driver={SQL Server Native Client RDA 11.0};Server=CLSCLSQL01\\SQLSERVER2017;Database=School_Dropout;Trusted_Connection=yes"
TablesRelativePath = "../Tables/"

# Extract observations table
sql_Obs = RxSqlServerData(table="Observation_Student", connectionString = cnnString)
df_Obs = rxImport(inData=sql_Obs)
str(df_Obs)

# Remove non-variable columns from dataframe
variables = names(df_Obs)
variables = variables[str_sub(variables, -6, -1) != "_Label" & str_sub(variables, -2, -1) != "ID"]
df_Obs = df_Obs[, variables]
str(df_Obs)

# Create table of correlation of dependent variable DropOut with each one of the predictive variables,
# and store table in Excel.
cor_DropOut = cor(df_Obs$DropOut, df_Obs) # Calculate correlations
cor_DropOut = t(cor_DropOut) # Transpose so that variables and correlations are displayed downwards 
cor_DropOut = data.frame(Variable = rownames(cor_DropOut), Correlation = cor_DropOut) # Convert to dataframe
rownames(cor_DropOut) = NULL # Eliminate row names
cor_DropOut = cor_DropOut[order(-abs(cor_DropOut$Correlation)), ] # Order by absolute value of correlation, in descending order
path_file = paste(TablesRelativePath, "Correlation with Dropout.xlsx", sep = "")
write.xlsx2(x = cor_DropOut, file = path_file, row.names = F) # Write to Excel file

# Create table of correlation of ALL variables with each other, and store table in Excel.
cor_All = cor(df_Obs) # Calulate all correlations and store in matrix cor_All
path_file = paste(TablesRelativePath, "Joint Correlation of All Variables.xlsx", sep = "")
write.xlsx2(x = cor_All, file = path_file) # Write to Excel file
