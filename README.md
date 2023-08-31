---
output:
  word_document: default
  html_document: default
---
# DoddLabRawMS (Dodd Lab Raw Mass Spectrometry Data Processing)
- Author: Zhiwei Zhou (zhouzw@stanford.edu)
- Created: 04/10/2023
- Last modified: 04/10/2023

## Introduction
This document is a part of DoddLabMetabolomics project. This part/package is aimed to steamlize the raw data processing workflow for untargeted metabolomics projects. 

The **R** based workflow is developed by Zhiwei Zhou. Please feel free to reach out Zhiwei (zhouzw@stanford.edu) if you have any questions.

## Data Preparsion
- Converted raw MS datda
- Supported formats: mzML/mzXML

## Demo Data
The subset of IBD project. The raw data is acquired in **HILIC** column & **poisitive** mode. 
- There are 2 groups, 'group1' and 'group2' (to mimic real situtation)
- **Note:** If there more than 2 groups, please create new folder for each group.


## Installation
The installation of required packages depends on the platform you use. This workflow is based on R, which requires installing some dependent packages first. 

##### Note: if you run in the Docker, all packages are well configured. Please go ahead to the Example Code part directly.

### R/RStudio
```
# intall public packages
if (!require(devtools)){
    install.packages("devtools")
}

if (!require(BiocManager)){
    install.packages("BiocManager")
}

# Required packages
required_pkgs <- c("dplyr","tidyr","readr", "stringr", "tibble", "purrr",
"ggplot2", "igraph", "pbapply", "Rdisop", "randomForest", "pryr", "BiocParallel", "magrittr", "rmarkdown", "caret")
BiocManager::install(required_pkgs)

devtools::install_github("DoddLab/DoddLabRawMS")
```

### Docker
#### 1. Install the WSL & Docker desktop
https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers

#### 2. Load the `doddlabmetabolomics` images
Download the newest docker [image](https://drive.google.com/drive/folders/1EQmXRtd57-uywytf_J8d7GXtBfkO_rKX?usp=share_link) 
```
# load downloaded image
docker load --input .\doddlabmetabolomics_1.0.01.tar

# check the image whether installed
docker images
```

#### 3. Run docker container
```
# Run docker & open the 
# Note: please replace path with the working directory. In the demo code, the working directory is ~/Project/00_IBD_project/Data/20230327_raw_data_processing_test/DemoData

docker run --rm -ti -e PASSWORD="123456" -p 8787:8787 -e DISABLE_AUTH=true -v ~/Project/00_IBD_project/Data/20230327_raw_data_processing_test/DemoData:/home/rstudio/ doddlabmetabolomics:1.0.01
```

#### 4. Open broswer
- Open the RStudio server with http://localhost:8787/

![](https://raw.githubusercontent.com/JustinZZW/blogImg/main/202304101016826.png)


## Example Codes

```
# load required packages
library(tidyverse)
library(DoddLabRawMS)

# load parameter set
parameter_set <- initialize_raw_parameter_class(column = 'hilic')

# run raw data processing
process_raw_data(parameter_set = parameter_set, 
                 path = '~/Project/00_IBD_project/Data/20230327_raw_data_processing_test/DemoData/')
```


## Parameters
- It is easy to load the parameter set for raw data processing via calling `initialize_annotation_parameter_class`. Currently, it contains two parameter set for "hilic" and "c18" column. 
- If one want to customize the parameters, you can assign new parameters to parameter_set_annotation. e.g. `parameter_set@para_peak_detection$ppm <- 25`

All **parameters** will be transmit to `xcms`. The optimized parameters in the parameter sets are listed below:
- Peak detection
    - method: Defaule 'centWave'
    - ppm: 20
    - peakwidth: c(10, 44) for hilic, c(10, 78) for c18 
    - mzdiff: -0.001 for hilic, -0.02 for c18
    - nSlaves: 6
- RT correction
    - method: "obiwarp"
    - plottype: "deviation"
    - profStep: 0.1
- Peak grouping
    - method: "density"
    - bw: 5
    - mzwid: 0.015
    - minfrac: 0.5

 
## Results
All raw data processing result would be put in the `00_raw_data_processing` folder. There are 3 files:
- `00_intermediate_data`: a folder contains all intermediate data. Only used for debug.
- `Peak-table`: a excel table contains all metabolics feature & peak areas among different samples
- `rt_correction_obiwarp`: A plot to demonstrate RT correction performance

#### Columns in peak-table.csv
- name: feature name, usually represents MzRT "MxxTxx"
- mzmed: median m/z
- mzmin: minimum detected m/z of this peak
- mzmax: maximum detected m/z of this peak
- rtmed: median RT, in second
- rtmin: minimum detected RT of this peak
- rtmax: maximum deteceted RT of this peak
- npeaks: sum of peak appeared
- group1: number of peak appeared samples in group1
- group2: number of peak appeared samples in group1
- maxint: maximum of peak height
- B011...: peak areas in each sample

![](https://raw.githubusercontent.com/JustinZZW/blogImg/main/202304101240785.png)


## License
<a rel="license" href="https://creativecommons.org/licenses/by-nc-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" /></a> 
This work is licensed under the Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
