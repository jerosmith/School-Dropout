# DETERMINE RELEVANT VARIABLES
# Determine individual sensitivities of variables by using one at a time in a decision tree model.

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

# Get variable names
variables = rxGetVarNames(sql_train)
variables = variables[variables != "StudentID" & variables != "DropOut"] # Exclude because these are not predictive variables.
variables = variables[variables != "SchoolOrd" & variables != "StudentCommuneOrd" & variables != "SchoolCommuneOrd"] # Exclude because these are circumstantial and may change with time (see paper).
variables = variables[!grepl("_Label", variables)] # These are not variables.
k = length(variables)

# Create individual variable ranking table
df_Variable_Individual_Rank = data.frame(  Variable = variables
                                         , Accuracy = rep(NA, k)
                                         , Specificity = rep(NA, k)
                                         , Sensitivity = rep(NA, k)
                                         )

# Populate individual variable ranking table
for (i in 1:k){
  print(i)
  
  formula = as.formula(paste("DropOut ~", variables[i]))
  
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
  df_Variable_Individual_Rank$Accuracy[i] = cm$overall["Accuracy"]
  df_Variable_Individual_Rank$Specificity[i] = cm$byClass["Specificity"]
  df_Variable_Individual_Rank$Sensitivity[i] = cm$byClass["Sensitivity"]
  
}

# Order ranking table by sensitivity and add rank column
df_Variable_Individual_Rank = df_Variable_Individual_Rank[order(-df_Variable_Individual_Rank$Sensitivity),]
df_Variable_Individual_Rank$Rank = 1:k

# Store individual variable ranking table in SQL Server
sql_Result_Variable_Individual_Rank = RxSqlServerData("Result_Variable_Individual_Rank", connectionString = cnnString)
rxDataStep(df_Variable_Individual_Rank, sql_Result_Variable_Individual_Rank, overwrite = T)

Sys.time() - t0 # 15 min 58 sec
