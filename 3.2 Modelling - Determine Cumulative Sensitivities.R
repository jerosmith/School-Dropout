# DETERMINE CUMULATIVE SENSITIVITIES OF VARIABLES
# Add variables one by one to model, in order of individual specificities.

# Libraries
library(caret)

# Parameters
cnnString = "Driver={SQL Server Native Client RDA 11.0};Server=CLSCLSQL01\\SQLSERVER2017;Database=School_Dropout;Trusted_Connection=yes;"
Dependent_Variable = "DropOut"
Probability_Threshold = 0.5

t0 = Sys.time()

# Initialise data source pointers to data
sql_train = RxSqlServerData("Observation_Train", connectionString = cnnString)
sql_test = RxSqlServerData("Observation_Test", connectionString = cnnString)

# Get number of rows of training dataset
sql_n = RxSqlServerData(sqlQuery = "select count(*) from Observation_Train", connectionString = cnnString)
df_n = rxDataStep(sql_n)
n = df_n[1, 1]

# Import testing dataset into data frame
df_test = rxDataStep(sql_test)

# Create cumulative variable ranking table from individual variable ranking table from SQL Server
sql_Result_Variable_Individual_Rank = RxSqlServerData("Result_Variable_Individual_Rank", connectionString = cnnString)
df_Variable_Cumulative_Rank = rxDataStep(sql_Result_Variable_Individual_Rank)
k = nrow(df_Variable_Cumulative_Rank)
df_Variable_Cumulative_Rank$Accuracy = rep(NA, k)
df_Variable_Cumulative_Rank$Specificity = rep(NA, k)
df_Variable_Cumulative_Rank$Sensitivity = rep(NA, k)
df_Variable_Cumulative_Rank = df_Variable_Cumulative_Rank[order(df_Variable_Cumulative_Rank$Rank), ]

# Populate cumulative variable ranking table
txtformula = "DropOut ~"
for (i in 1:k){
  print(i)
  
  if (i==1) {
    txtformula = paste(txtformula, df_Variable_Cumulative_Rank$Variable[i])
  } else {
    txtformula = paste(txtformula, "+", df_Variable_Cumulative_Rank$Variable[i])
  }
  formula = as.formula(txtformula)
  
  sqrtn = as.integer(sqrt(n))
  model = rxDTree(formula = formula
                  , data = sql_train
                  , minSplit = sqrtn
                  , maxNumBins = sqrtn
                  , reportProgress = 0
  )
  
  df_predictions = rxPredict(model, data = df_test, extraVarsToWrite = "DropOut", reportProgress = 0)
  names(df_predictions)[1] = "DropOut_Prob"
  df_predictions$DropOut_Pred = ifelse(df_predictions$DropOut_Prob >= Probability_Threshold, T, F)
  cm = confusionMatrix(data = df_predictions$DropOut_Pred, reference = df_predictions$DropOut, positive = "TRUE")
  df_Variable_Cumulative_Rank$Accuracy[i] = cm$overall["Accuracy"]
  df_Variable_Cumulative_Rank$Specificity[i] = cm$byClass["Specificity"]
  df_Variable_Cumulative_Rank$Sensitivity[i] = cm$byClass["Sensitivity"]
  
}

# Store Cumulative variable ranking table in SQL Server
sql_Result_Variable_Cumulative_Rank = RxSqlServerData("Result_Variable_Cumulative_Rank", connectionString = cnnString)
rxDataStep(df_Variable_Cumulative_Rank, sql_Result_Variable_Cumulative_Rank, overwrite = T)

Sys.time() - t0 # 1 hour 46 min
