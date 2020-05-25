# LOAD TABLES IN SQL SERVER DATABASE FROM SOURCE CSV FILES

# Packages
# install.packages("data.table")
# install.packages("RODBC")
# install.packages("stringi")

# Libraries
library(data.table)
library(RODBC)
library(stringi)

# Parameters
RelativeDataPath = "../Data"
ConnectionString = "Driver={SQL Server Native Client 11.0};Server=(local);Database=School_Dropout;Trusted_Connection=yes;"

# Step N° 8 - Load raw data from *Matricula*.csv.
# -----------------------------------------------

t0 = Sys.time()

FileList = list.files(path=RelativeDataPath, pattern="matr[ií]cula.*.csv$", ignore.case=T)
n = length(FileList)

connection = odbcDriverConnect(ConnectionString)

for (i in 1:n){
  print(i)
  dtMatricula = fread(input=paste(RelativeDataPath, FileList[i], sep="/"), sep=";", header=T)
  nrowdt = nrow(dtMatricula)
  table = paste("Source_Matricula", stri_dup("0",2-nchar(as.character(i))), i, sep="")
  nrowstable = sqlQuery(connection, paste("select count(*) from", table), errors=F)
  if (nrowstable==-1){ # If table does not exist, then create it and populate it.
    print("Create table and populate it.")
    sqlSave(connection, dat=dtMatricula, tablename=table, append=T, rownames=F)
  } else if (nrowstable!=nrowdt){ # If table exists but is missing rows, drop it and populate it again.
    print("Drop table and populate it again.")
    sqlDrop(connection, table)
    sqlSave(connection, dat=dtMatricula, tablename=table, append=T, rownames=F)
  } # Otherwise, table is already populated and hence do nothing.
}

odbcClose(connection)

Sys.time() - t0 # 47 minutes

# Step N° 9 - Load raw data from *Rendimiento*.csv.
# -------------------------------------------------

t0 = Sys.time()

FileList = list.files(path=RelativeDataPath, pattern="rendimiento.*.csv$", ignore.case=T)
n = length(FileList)

connection = odbcDriverConnect(ConnectionString)

for (i in 1:n){
  print(i)
  dtRendimiento = fread(input=paste(RelativeDataPath, FileList[i], sep="/"), sep=";", header=T)
  nrowdt = nrow(dtRendimiento)
  table = paste("Source_Rendimiento", stri_dup("0",2-nchar(as.character(i))), i, sep="")
  nrowstable = sqlQuery(connection, paste("select count(*) from", table), errors=F)
  if (nrowstable==-1){ # If table does not exist, then create it and populate it.
    sqlSave(connection, dat=dtRendimiento, tablename=table, append=T, rownames=F)
  } else if (nrowstable!=nrowdt){ # If table exists but is missing rows, drop it and populate it again.
    sqlDrop(connection, table)
    sqlSave(connection, dat=dtRendimiento, tablename=table, append=T, rownames=F)
  } # Otherwise, table is already populated and hence do nothing.
}

odbcClose(connection)

Sys.time() - t0

# Step N° 10 - Load raw data from Docentes*.csv.
# ----------------------------------------------

t0 = Sys.time()

FileList = list.files(path=RelativeDataPath, pattern="docentes.*.csv$", ignore.case=T)
n = length(FileList)

connection = odbcDriverConnect(ConnectionString)

for (i in 1:n){
  print(i)
  dtDocentes = fread(input=paste(RelativeDataPath, FileList[i], sep="/"), sep=";", header=T)
  nrowdt = nrow(dtDocentes)
  table = paste("Source_Docentes", stri_dup("0",2-nchar(as.character(i))), i, sep="")
  nrowstable = sqlQuery(connection, paste("select count(*) from", table), errors=F)
  if (nrowstable==-1){ # If table does not exist, then create it and populate it.
    sqlSave(connection, dat=dtDocentes, tablename=table, append=T, rownames=F)
  } else if (nrowstable!=nrowdt){ # If table exists but is missing rows, drop it and populate it again.
    sqlDrop(connection, table)
    sqlSave(connection, dat=dtDocentes, tablename=table, append=T, rownames=F)
  } # Otherwise, table is already populated and hence do nothing.
}

odbcClose(connection)

Sys.time() - t0 # 3.77 minutes

# Step N° 11 - Load raw data from Comunas Datos Socioeconomicos.csv.
# ------------------------------------------------------------------

t0 = Sys.time()

connection = odbcDriverConnect(ConnectionString)

dtCommunes = fread(input=paste(RelativeDataPath, "Comunas Socioeconomic Data.csv", sep="/"), sep=";", header=T, dec=",")
table = "Source_Comunas_Socioeconomic_Data"
nrowstable = sqlQuery(connection, paste("select count(*) from", table), errors=F)
if (nrowstable==-1){ # If table does not exist, then create it and populate it.
  sqlSave(connection, dat=dtCommunes, tablename=table, append=T, rownames=F, colnames=T)
} else { # Else drop it and populate it again.
  sqlDrop(connection, table)
  sqlSave(connection, dat=dtCommunes, tablename=table, append=T, rownames=F, colnames=T)
} 

odbcClose(connection)

Sys.time() - t0 # 2 seconds

# Step N° 12 - Load raw data from COD_ENSE_EducationType.csv.
# --------------------------------------------------------

t0 = Sys.time()

connection = odbcDriverConnect(ConnectionString)

dt_COD_ENSE_EducationType = fread(input=paste(RelativeDataPath, "COD_ENSE_EducationType.csv", sep="/"), sep=";", header=T, dec=",")
names(dt_COD_ENSE_EducationType)[1] = "COD_ENSE"
table = "Source_COD_ENSE_EducationType"
nrowstable = sqlQuery(connection, paste("select count(*) from", table), errors=F)
if (nrowstable==-1){ # If table does not exist, then create it and populate it.
  sqlSave(connection, dat=dt_COD_ENSE_EducationType, tablename=table, append=T, rownames=F, colnames=T)
} else { # Else drop it and populate it again.
  sqlDrop(connection, table)
  sqlSave(connection, dat=dt_COD_ENSE_EducationType, tablename=table, append=T, rownames=F, colnames=T)
} 

odbcClose(connection)

Sys.time() - t0 # 0.2 seconds

# Step N° 13 - Load raw data from COD_ENSE3_EducationLevel.csv.
# ----------------------------------------------------------

t0 = Sys.time()

connection = odbcDriverConnect(ConnectionString)

dt_COD_ENSE3_EducationLevel = fread(input=paste(RelativeDataPath, "COD_ENSE3_EducationLevel.csv", sep="/"), sep=";", header=T, dec=",")
names(dt_COD_ENSE3_EducationLevel)[1] = "COD_ENSE3"
table = "Source_COD_ENSE3_EducationLevel"
nrowstable = sqlQuery(connection, paste("select count(*) from", table), errors=F)
if (nrowstable==-1){ # If table does not exist, then create it and populate it.
  sqlSave(connection, dat=dt_COD_ENSE3_EducationLevel, tablename=table, append=T, rownames=F, colnames=T)
} else { # Else drop it and populate it again.
  sqlDrop(connection, table)
  sqlSave(connection, dat=dt_COD_ENSE3_EducationLevel, tablename=table, append=T, rownames=F, colnames=T)
} 

odbcClose(connection)

Sys.time() - t0 # 0.14 seconds



