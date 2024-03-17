Prepare combined Seurat objects
Since I have 4 separate runs and cell barcodes are duplicated between preps, I appended sample information before the barcode for as see below. This makes the barcodes across experiments unique.
# An example showing column renaming
# n1 is the name of the sample (the others are n2, n3, n4)

n1_data <- Read10X("data/EXPIDX1/")
n2_data <- Read10X("data/EXPIDX2/")
n3_data <- Read10X("data/EXPIDX3/")
n4_data <- Read10X("data/EXPIDX4/")

colnames(n1_data) <- paste("n1", colnames(n1_data), sep = "_")
colnames(n2_data) <- paste("n2", colnames(n2_data), sep = "_")
colnames(n3_data) <- paste("n3", colnames(n3_data), sep = "_")
colnames(n4_data) <- paste("n4", colnames(n4_data), sep = "_")

# Follow Seurat vignettes to aggregate 4 runs to generate "combined" Seurat object 

# add.cell.ids argument can be used when you perform the merge step instead of this approach of prefixing 
# Thanks to Jared for the suggestion
Correct VDJ-seq data barcodes
This is needed because in the previous chunk we manually changed the barcodes from something like this ATTAGGATTAGGTC to something like this n4_ATTAGGATTAGGTC. We need to make sure the VDJ data frame has matching cell barcodes. Also, the VDJ sequencing data have -1 at the end of the barcode name, which needs to removed for correct barcode matching.
# Load VDJ data (one csv per run)

n1_clone <- read.csv("data/EXPIDX1_filtered_contig_annotations.csv")
n2_clone <- read.csv("data/EXPIDX2_filtered_contig_annotations.csv")
n3_clone <- read.csv("data/EXPIDX3_filtered_contig_annotations.csv")
n4_clone <- read.csv("data/EXPIDX4_filtered_contig_annotations.csv")

# Create a function to trim unwanted "-1" and append sample information before barcodes

barcoder <- function(df, prefix,  trim="\\-1"){

  df$barcode <- gsub(trim, "", df$barcode)
  df$barcode <- paste0(prefix, df$barcode)

  df
}

# Override barcode data with the suitable replacement

n1_clone <- barcoder(n1_clone, prefix = "n1_")
n2_clone <- barcoder(n1_clone, prefix = "n2_")
n3_clone <- barcoder(n1_clone, prefix = "n3_")
n4_clone <- barcoder(n1_clone, prefix = "n4_")
Combine VDJ-seq data from separate runs and organize data
We will now bring together VDJ data from separate runs to be able to load it into the combined Seurat object. In the VDJ data I have, cell barcodes are duplicated in rows because the sequencing of TRA and TRB genes creates multiple data points for the same cell. Jared's tutorial removes duplicates and just utilizes the clonotype info, but some researchers may want to have a more granular detail level in the meta.data slot of the Seurat object (such as the actual V/D/J genes sequenced).
So, what we want to do now is concatenating all the unique data we'd like to keep (which result in the duplication of the cell barcodes in the data frame) and collapse the duplicate rows. I'm sure there are other (and maybe better) ways of doing this, but I ended up using the code below:
Combine VDJ data from 4 separate experiments
all_cln <- rbind(n1_clone,
                 n2_clone,
                 n3_clone,
                 n4_clone)

# Generate a function that will concatenate unique data entries and collapse duplicate rows
# To do this, I first factorize the data and then get factor levels as unique data points
# Then I paste these  data points together separated with "__" to access later on if needed

data_concater <- function(x){
  x<- levels(factor(x))
  paste(x, collapse = "__")
}

# Use data.table package for efficient calculations. Dplyr takes a long time in my experience.

suppressPackageStartupMessages(library(data.table))

all_cln <- as.data.table(all_cln)


# Prepare a progress bar to monitor progress (helpful for large aggregations)

grpn = uniqueN(all_cln$barcode)
pb <- txtProgressBar(min = 0, max = grpn, style = 3)

# This code applies data_concater function per  barcodes to create a 
# concatenated string with  the information we want to keep

all_cln_collapsed <- all_cln[, {setTxtProgressBar(pb,.GRP); lapply(.SD, data_concater)} , by=barcode]

# Or you can use the simple code below if you don't care about the progress bar
# all_cln_collapsed <- all_cln[, lapply(.SD, data_concater), by=barcode]

# Assign row names for merging into combined Seurat object

rownames(all_cln_collapsed) <- all_cln_collapsed$barcode
Assign VDJ data to Seurat object
Now we will assign all the VDJ-sequencing data to combined Seurat object. Individual columns of VDJ-seq data will be assigned as columns of combined@meta.data data frame.
combined <- AddMetaData(combined, metadata = all_cln_collapsed)
Hopefully, this helps to integrate VDJ-TCR seq data with genome-wide gene expression data in your experiments. Let me know if you have any suggestions.
Best,
Atakan
