## Useful scripts ##

#### Quality check
1. [Quality check](/Useful_Scripts/All/integration_scTCR.R) - "FastQC aims to provide a simple way to do some quality control checks on raw sequence data coming from high throughput sequencing pipelines. It provides a modular set of analyses which you can use to give a quick impression of whether your data has any problems of which you should be aware before doing any further analysis." This script utilizes FASTQC within a Docker container. **Please note that you need to adjust the global variables to match your working directory**.
   
   ### Single cell 
1. [Integration single cell TCR with Seurat](/Useful_Scripts/All/fastqc.R) -The code below was written for 10X genomics single-cell sequencing data. In my case, I needed to load the TCR clonotype data after I created a combined Seurat object by aggregating 4 separate runs. This script can be edited to work with a Seurat object created from a single run; or alternatively for loading VDJ data early on before aggregating the samples.
