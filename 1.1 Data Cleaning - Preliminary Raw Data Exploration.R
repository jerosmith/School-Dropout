# CHILEAN SCHOOL DROPOUT

# R libraries:
library(data.table)

setwd("../Data")

# download.file("sgdce.mineduc.cl/descargar.php?id_doc=201408081610210", "2013_Matricula.csv")

students2013 = fread("2013_Matricula.csv")
students2014 = fread("2014_Matricula.csv")

attendance201412 = fread("201412_Asistencia.csv")

setkey(students2013, MRUN)
setkey(students2014, MRUN)
setkey(attendance201412, MRUN)

students = merge(students2013, students2014, all=TRUE)
students_attendance201412 = merge(students2014, attendance201412, all=TRUE)

students[1:100, c("MRUN", "FEC_NAC_ALU.x", "FEC_NAC_ALU.y"), with=F]
x = students[FEC_NAC_ALU.x!=FEC_NAC_ALU.y, c("MRUN", "FEC_NAC_ALU.x", "FEC_NAC_ALU.y"), with=F]
nrow(x)/nrow(students)*100 # Only 0.007% of the rows have different birth dates.

# The probability of this occurring by chance is extremely remote. Therefore we can safely assume that MRUN is the id of each student across different data sets, i.e. it is the same student in different data sets.

students_attendance201412[1:100, c("MRUN", "RBD.x", "RBD.y"), with=F]
x = students_attendance201412[RBD.x!=RBD.y, c("MRUN", "RBD.x", "RBD.y"), with=F]
nrow(x)/nrow(students_attendance201412)*100 # Only 4.8% of the rows have different RBD's.

# The probability of this occurring by chance is remote. Therefore we can safely assume that MRUN is the id of each student in the Matricula and Asistencia data sets.

attendance = fread("20130523_Asistencia_abril_2013_20130520_PUBL.csv")
