library(RSQLite)
library(DBI)
#Create ATB database ####
antibiotic_db <- dbConnect(drv = RSQLite::SQLite(),
                           "databases_WLF/ATB.db")
#Create the tables that will populate the ATB database
#Create Antibiotic_Table containing antibiotics and class ####
dbExecute(antibiotic_db,
          "CREATE TABLE Antibiotic_Table(
          antibioticType varchar(20) NOT NULL PRIMARY KEY,
          antibioticClass varchar(20));")

#Create Bacteria table containing bacteria,
#gram stain, gene target and gene mutation ####
dbExecute(antibiotic_db,
          "CREATE TABLE Bacteria(
            bacteria varchar(10) NOT NULL PRIMARY KEY,
          gram_stain varchar(10),
          gene_target varchar(10),
          gene_mutation varchar(15),
          serial_num real);") 

#create microbial fitness table ####
dbExecute(antibiotic_db,
"CREATE TABLE microbial_fitness (
  fitness varchar(10) NOT NULL PRIMARY KEY,
  MIC real,
  Selection_coefficient real,
  SE real,
  gene_mutation varchar(50),
  antibiotic varchar(50),
  FOREIGN KEY (gene_mutation) REFERENCES Bacteria (gene_mutation),
  FOREIGN KEY (antibiotic) REFERENCES Antibiotic(antibiotic)
);")


#create Laboratory standard table
dbExecute(antibiotic_db,
          "CREATE TABLE Laboratory_standard(
          strain_reference varchar(25),
          technique varchar(20),
          medium varchar(20),
          serial_num real,
          FOREIGN KEY (serial_num) REFERENCES Bacteria (serial_num));")

DBI::dbListTables(antibiotic_db)#returns a list of all the table in the dragons database
library(tidyverse)

# Select the data from costR that will be entered into each table
costR <-  read.csv("Raw_data/costR.csv", stringsAsFactors = FALSE)

atbdf <-  costR %>% 
  select(antibioticType, antibioticClass) %>% 
  distinct()

distinctBac <- costR %>% 
  select(bacteria, gram_stain, gene_target, gene_mutation) %>% 
  distinct()

FIT <-  costR %>% 
  select(MIC, Selection_coefficient,
         fitness, SE, gene_mutation, antibioticType) %>% 
  distinct()

REF <-  costR %>% 
  select(strain_reference, technique, medium) %>% 
  distinct()

# Populate each table of the ATB.db with the selected data ####
dbWriteTable(antibiotic_db, "Antibiotic_Table", atbdf, overwrite = TRUE)
dbWriteTable(antibiotic_db, "Bacteria", distinctBac, overwrite = TRUE)
dbWriteTable(antibiotic_db, "microbial_fitness", FIT, overwrite = TRUE)  
dbWriteTable(antibiotic_db, "Laboratory_standard", REF, overwrite = TRUE)


dbListFields(antibiotic_db, "Antibiotic_Table")
dbListFields(antibiotic_db, "Bacteria")


dbReadTable(antibiotic_db, "microbial_fitness")
dbReadTable(antibiotic_db, "Bacteria")

antibiotic <-  dbGetQuery(antibiotic_db, "SELECT * FROM Antibiotic_Table;")
head(antibiotic)

fitnessLevel <-  dbGetQuery(antibiotic_db, "SELECT * FROM microbial_fitness;")
head(fitnessLevel)

bacteria <-  dbGetQuery(antibiotic_db, "SELECT * FROM Bacteria;")
head(bacteria)

references <-  dbGetQuery(antibiotic_db, "SELECT * FROM Laboratory_standard;")
head(references)


