# cgp_new_sel_nci_pred.R
# Function to take predictions and graph them

library(data.table)
library(reshape2)
library(ggplot2)

Function.NRMSE <- function(pred, actual){

  NRMSE <- sqrt(mean((pred-actual)^2)) / diff(range(actual))
  return(NRMSE)
}

#####################################################################################
# LOAD DATA

cgp_table   <- readRDS("/home/zamalloa/Documents/FOLDER/CGP_FILES/080716_cgp_new_feat.rds")
nci60.gi50  <- readRDS("/home/zamalloa/Documents/FOLDER/CGP_FILES/080716.nci.gi50.rds")
nci_to_cgp  <- readRDS("/home/zamalloa/Documents/FOLDER/CGP_FILES/080716.nci60_names_to_cgp.rds")

args        <- commandArgs(trailingOnly = TRUE)
target_drug <- args[1]
out_table   <- "/home/zamalloa/Documents/FOLDER/CGP_FILES/CGP_NEW_FIGURES/"
in_folder   <- "/home/zamalloa/Documents/FOLDER/CGP_FILES/CGP_NEW_RESULTS/"

date_out    <- Sys.Date()
#####################################################################################
# EXECUTE

drug_table     <- fread(paste0(in_folder, "cgp_new_modeling_nci_", drug_target))

# Predict for all
drug_all_pred  <- drug_table[,list(NRMSE = Function.NRMSE(Predicted, Actual),
                                   Cor   = cor(Predicted, Actual, method="pearson")), by = "Compound"]

#Predict for common
main_table     <- merge(nci.gi50, nci_to_cgp, by="NSC")
main_table     <- main_table[ ,c("cell_name", "Compound", "SCALE.ACT"),with=F]
main_table     <- merge(main_table, cgp_table, by=c("Compound", "cell_name"))
common_cells   <- main_table$cell_name

drug_table_com <- drug_table[cell_name %in% common_cells,]
drug_comb_pred <- drug_table_com[,list(NRMSE = Function.NRMSE(Predicted, Actual),
                                       Cor   = cor(Predicted, Actual, method="pearson")), by = "Compound"]

# Plot
pdf(paste0(out_folder, date_out, "cgp_new_modeling_nci_" , target_drug), width=12, height=8)

ggplot(drug_table, aes(Predicted, Actual)) + geom_point(size=0.4) +
  theme_bw() +
  ggtitle(paste0("CGP based prediction on NCI-60 Compound: ", target_drug ,
                 "- Cor:", drug_all_pred$Cor, "\n", "All NCI-60 Cells" ))

ggplot(drug_table_com, aes(Predicted, Actual)) + geom_point(size=0.4) +
 theme_bw() +
 ggtitle(paste0("CGP based prediction on NCI-60 Compound: ", target_drug ,
                "- Cor:", drug_all_pred$Cor, "\n", "Common CGP/NCI-60 Cells" ))

dev.off()

print("Done plotting")