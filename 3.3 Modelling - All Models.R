# ALL MODELS
# 1) Logit
# 2) Decision Tree
# 3) Random Forest
# 4) Neural Network

# Libraries
#install.packages("caret")
#install.packages("pbkrtest")
#install.packages("e1071")
library(caret)

# Parameters:
cnnString = "Driver={SQL Server Native Client RDA 11.0};Server=CLSCLSQL01\\SQLSERVER2017;Database=School_Dropout;Trusted_Connection=yes;"
Probability_Threshold = 0.5

# Set pointer to training data set and import testing data set:
sql_train = RxSqlServerData(table = "Observation_Train", connectionString = cnnString, stringsAsFactors = TRUE)
sql_test = RxSqlServerData(table = "Observation_Test", connectionString = cnnString, stringsAsFactors = TRUE)
df_test = rxImport(sql_test)

# Get number of rows of training dataset
sql_n = RxSqlServerData(sqlQuery = "select count(*) from Observation_Train", connectionString = cnnString)
df_n = rxDataStep(sql_n)
n = df_n[1, 1]

# Formula:
txtformula = "DropOut"
txtformula = paste(txtformula, "~ TotalSchoolYearRepeats")
txtformula = paste(txtformula, "+ SchoolMarks")
txtformula = paste(txtformula, "+ AgeDifference_wr_LevelGrade")
txtformula = paste(txtformula, "+ Attendance")
txtformula = paste(txtformula, "+ TotalSchoolChanges")
txtformula = paste(txtformula, "+ EducationLevelOrd")
txtformula = paste(txtformula, "+ SchoolYear")
txtformula = paste(txtformula, "+ StudentsPerClass")
txtformula = paste(txtformula, "+ StudentsPerSchool")
txtformula = paste(txtformula, "+ Age")
formula = as.formula(txtformula)


# TRAIN MODELS

# 1) Logit - 49 sec
set.seed(1)
model = rxLogit(formula = formula
                , data = sql_train
                )
summary(model)

# 2) Decision Tree - 6 min 58 sec
sqrtn = as.integer(sqrt(n))
set.seed(1)
model = rxDTree(formula = formula
                , data = sql_train
                , minSplit = sqrtn
                , maxNumBins = sqrtn
                )

# 3) Random Forest - 16 min 17 sec
sqrtn = as.integer(sqrt(n))
set.seed(1)
model = rxDForest(formula = formula
                  , data = sql_train
                  , minSplit = sqrtn
                  , maxNumBins = sqrtn
)

# 4) Neural Network - 17 min 31 sec
sqrtn = as.integer(sqrt(n))
set.seed(1)
model = rxNeuralNet(formula = formula
                    , data = sql_train
)

# Generate confusion matrix:
df_predictions = rxPredict(modelObject = model, data = df_test, extraVarsToWrite = "DropOut")
if (!as.logical(sum(grepl("Neural", class(model))))) {
  names(df_predictions)[1] = "DropOut_Probability"
} else {
  names(df_predictions)[4] = "DropOut_Probability"
}
df_predictions$DropOut_Predicted = ifelse(df_predictions$DropOut_Probability >= Probability_Threshold, T, F)
cm = confusionMatrix(data = df_predictions$DropOut_Predicted, reference = df_predictions$DropOut, positive = "TRUE")
cm

