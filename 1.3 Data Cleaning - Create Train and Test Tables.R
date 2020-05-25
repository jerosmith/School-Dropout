# CREATE TRAINING AND TESTING DATA SETS

# Libraries:
# install.packages("caret")
library(caret)

# Parameters:
cnnString = "Driver={SQL Server Native Client RDA 11.0};Server=CLSCLSQL01\\SQLSERVER2017;Database=School_Dropout;Trusted_Connection=yes;"

t0 = Sys.time()

# Import data from table Observation_Student:
sql_Obs = RxSqlServerData(sqlQuery="select * from Observation_Student", connectionString = cnnString)
df_Obs = rxImport(inData=sql_Obs)

# Create training and testing dataframes:
set.seed(1)
inTrain = createDataPartition(y=df_Obs$DropOut, p=0.8, list=F)
df_Train = df_Obs[inTrain,]
df_Test = df_Obs[-inTrain,]

# Step N° 68 - Store training data set in SQL Server database. 32 seconds
sql_Train = RxSqlServerData(table="Observation_Train", connectionString = cnnString)
rxDataStep(inData=df_Train, outFile=sql_Train)

# Step N° 69 - Store testing data set in SQL Server database. 8 seconds
sql_Test = RxSqlServerData(table="Observation_Test", connectionString = cnnString)
rxDataStep(inData=df_Test, outFile=sql_Test)

Sys.time() - t0 # 2 minutes 55 seconds
