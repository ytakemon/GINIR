
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!--You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date. `devtools::build_readme()` is handy for this. You could also use GitHub Actions to re-render `README.Rmd` every time you push. An example workflow can be found here: <https://github.com/r-lib/actions/tree/master/examples>. -->

# Genetic Interaction Network IdentifieR (GINIR)

<!-- badges: start -->

[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

![](./GINIR_hex_logo-02.png)

GINIR is an R package that leverages data generated by the [Cancer
Dependency Map (DepMap) project](https://depmap.org/portal/) to identify
cancer cell lines with mutations of interest and perform in-silico
genetic knockout screens. A manuscript describing the process is being
prepared.

Current DepMap data used by default is version 20Q1, which was
downloaded through the DepMap data portal. The data was distributed and
used under the terms and conditions of [CC Attribution 4.0
license](https://creativecommons.org/licenses/by/4.0/).

## Contributions

This repository is being developed and maintained by [Yuka
Takemon](https://github.com/ytakemon) at the [Dr. Marco
Marra](https://www.bcgsc.ca/labs/marra-lab)’s laboratory at the
[Canada’s Michael Smith Genome Sciences
Centre](https://www.bcgsc.ca/).

Please submit an [issue](https://github.com/ytakemon/GINIR/issues) for
all questions regarding GINIR.

<!-- Below this line are default template stuff that will be updated as the package comes together -->

## Package installation and data download

You can install the GINIR package from [GitHub](https://github.com)
with:

``` r
install.packages("devtools")
devtools::install_github("ytakemon/GINIR")
```

Data and the data documentation are provided on the [GINIR github
page](https://github.com/ytakemon/GINIR/) and can be installed directly
in terminal using the following:

``` bash
# Make a new directory/folder called GINIR_project and go into directory
mkdir GINIR_project
cd GINIR_project

# Download data and data documentation from the web
wget https://github.com/ytakemon/GINIR/raw/main/GINIR_data.tar.gz
wget https://github.com/ytakemon/GINIR/raw/main/GINIR_data_document.tar.gz

# Extract data and data documentation
tar -zcvf GINIR_data.tar.gz
tar -zcvf GINIR_data_document.tar.gz
```

## Workflows

### Genetic interaction mapping

1.  Install `GINIR` and download accompanying data
2.  Select mutant cell lines that carry mutations in the gene of
    interest and control cell lines.
      - (optional specifications) disease type, disease subtype, amino
        acid change
3.  Determine differential expression between mutant and control cell
    line groups.
      - (optional but recommended)
4.  Perform *in silico* genetic screen.
5.  Visualize results

### Co-essential network mapping

1.  Install `GINIR` and download accompanying data
2.  Run correlation coefficient analysis.
3.  Calculate inflection points of negative/positive curve to determine
    a threshold.
4.  Apply threshold.
5.  Visualize results

## Example: Identifying *ARID1A* genetic interactions

*ARID1A* encodes a member of the chromatin remodeling SWItch/Sucrose
Non-Fermentable (SWI/SNF) complex and is a frequently mutated gene in
cancer. It is known that *ARID1A* and its homolog, *ARID1B*, are
synthetic lethal to one another: The dual loss of ARID1A and its
homolog, ARID1B, in a cell is lethal; however, the loss of either gene
alone is not ([Helming et al., 2014](https://doi.org/10.1038/nm.3480)).
This example will demonstrate how we can identify synthetic lethal
interactors of *ARID1A* using `GINIR` and predict this known
interaction.

For this example you will need to call the following libraries

``` r
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
#> ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
#> ✓ tibble  3.1.6     ✓ dplyr   1.0.8
#> ✓ tidyr   1.2.0     ✓ stringr 1.4.0
#> ✓ readr   2.1.2     ✓ forcats 0.5.1
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(GINIR)
```

Then, assign a variable that points to where the `.rda` files are
stored.

``` r
GINIR_data_dir <- "/path/to/GINIR_project/GINIR_data/"
```

### Exploring cell lines

One way to explore cell lines that are available in DepMap is through
their [portal](https://depmap.org/portal/). However, there are some
simple built-in methods in GINI to provide users with a way to glimpse
the data using the series of `list_available` functions:
`list_available_mutations()`, `list_available_cancer_types()`,
`list_available_cancer_subtypes()`

Current DepMap data used by default is version 20Q1, which contains
whole-genome sequencing or whole-exome sequencing annotations for `1775`
cancer cell lines (`1270` cell lines with RNA-seq data, `378` cell lines
with quantitative proteomics data, and `739` cell lines with CRISPR-Cas9
knockout screen data)

``` r
# Find ARID1A hotspot mutations detected in all cell lines
list_available_mutations(Gene = "ARID1A", Is_hotspot = TRUE, data_dir = GINIR_data_dir) 
```

``` r
# List all available cancer types
list_available_cancer_types(data_dir = GINIR_data_dir)
#>  [1] "Ovarian Cancer"             "Leukemia"                  
#>  [3] "Colon/Colorectal Cancer"    "Skin Cancer"               
#>  [5] "Lung Cancer"                "Bladder Cancer"            
#>  [7] "Kidney Cancer"              "Breast Cancer"             
#>  [9] "Pancreatic Cancer"          "Myeloma"                   
#> [11] "Brain Cancer"               "Sarcoma"                   
#> [13] "Lymphoma"                   "Bone Cancer"               
#> [15] "Fibroblast"                 "Gastric Cancer"            
#> [17] "Engineered"                 "Thyroid Cancer"            
#> [19] "Neuroblastoma"              "Prostate Cancer"           
#> [21] "Rhabdoid"                   "Gallbladder Cancer"        
#> [23] "Endometrial/Uterine Cancer" "Head and Neck Cancer"      
#> [25] "Bile Duct Cancer"           "Esophageal Cancer"         
#> [27] "Liver Cancer"               "Cervical Cancer"           
#> [29] "Immortalized"               "Unknown"                   
#> [31] "Eye Cancer"                 "Adrenal Cancer"            
#> [33] "Liposarcoma"                "Embryonal Cancer"          
#> [35] "Teratoma"                   "Non-Cancerous"             
#> [37] NA

# List all available cancer subtypes
list_available_cancer_subtypes(input_disease = "Lung Cancer", data_dir = GINIR_data_dir)
#>  [1] "Non-Small Cell Lung Cancer (NSCLC), Adenocarcinoma"           
#>  [2] "Non-Small Cell Lung Cancer (NSCLC), Large Cell Carcinoma"     
#>  [3] "Mesothelioma"                                                 
#>  [4] "Small Cell Lung Cancer (SCLC)"                                
#>  [5] "Non-Small Cell Lung Cancer (NSCLC), unspecified"              
#>  [6] "Non-Small Cell Lung Cancer (NSCLC), Squamous Cell Carcinoma"  
#>  [7] "Non-Small Cell Lung Cancer (NSCLC), Adenosquamous Carcinoma"  
#>  [8] "Carcinoid"                                                    
#>  [9] "Non-Small Cell Lung Cancer (NSCLC), Bronchoalveolar Carcinoma"
#> [10] "Non-Small Cell Lung Cancer (NSCLC), Mucoepidermoid Carcinoma" 
#> [11] "Carcinoma"
```

### Selecting mutant and control cell line groups

As default `select_cell_lines()` will identify cancer cell lines with
loss-of-function alterations in the gene specified and group them into
six different groups.

Loss-of-function alterations include variants that are annotated as:
`"Nonsense_Mutation", "Frame_Shift_Ins", "Splice_Site",
"De_novo_Start_OutOfFrame", "Frame_Shift_Del", "Start_Codon_SNP",
"Start_Codon_Del",` and `"Start_Codon_Ins"`. Copy number alterations are
also taken into consideration and group as `"Deep_del", "Loss",
"Neutral",` or `"Amplified"`.

The cell line groups assigned by default are:

  - `Control` cell lines do not harbor any single nucleotide variations
    (SNVs) or insertions and deletions (InDels) with a neutral copy
    number (CN).
  - `HomDel` cell lines harbor one or more homozygous deleterious SNVs
    or have deep CN loss.
  - `T-HetDel` cell lines harbor two or more heterozygous deleterious
    SNVs/InDels with neutral or CN loss.
  - `HetDel` cell lines harbor one heterozygous deleterious SNV/InDel
    with neutral CN, or no SNV/InDel with CN loss.
  - `Amplified` cell lines harbor no SNVs/InDels with increased CN.
  - `Others` cell lines harbor deleterious SNVs with increased CN.

<!-- end list -->

``` r
ARID1A_groups <- select_cell_lines(Input_gene = "ARID1A", data_dir = GINIR_data_dir)
#> Selecting mutant groups for: ARID1A in all cancer cell lines

# Show number of cell lines in each group 
count(ARID1A_groups, Group)
#> # A tibble: 6 × 2
#>   Group               n
#>   <chr>           <int>
#> 1 Amplified          24
#> 2 ARID1A_HetDel     105
#> 3 ARID1A_HomDel      13
#> 4 ARID1A_T-HetDel    21
#> 5 Control           529
#> 6 Others             47
```

#### Optional filter for specific cancer types

``` r
# Find pancreatic cancer cell lines with ARID1A mutations
ARID1A_pancr_groups <- select_cell_lines(Input_gene = "ARID1A", 
                                         Input_disease = "Pancreatic Cancer",
                                         data_dir = GINIR_data_dir)
#> Selecting mutant groups for: ARID1A in Pancreatic Cancer,  cell lines

# Show number of cell lines in each group 
count(ARID1A_pancr_groups, Group)
#> # A tibble: 5 × 2
#>   Group               n
#>   <chr>           <int>
#> 1 ARID1A_HetDel       7
#> 2 ARID1A_HomDel       4
#> 3 ARID1A_T-HetDel     1
#> 4 Control            18
#> 5 Others              1
```

### Check for differential expression

Of the three mutant cancer cell line groups `ARID1A_HomDel`,
`ARID1A_T-HetDel`, and `ARID1A_HetDel`, cancer cell lines with
`ARID1A_HomDel` mutations are most likely to result in a loss or reduced
expression of *ARID1A*. Therefore, we want to check whether cell lines
in `ARID1A_HomDel` mutant group have significantly less *ARID1A* RNA or
protein expression compared to control cell lines.

``` r
# Select only HomDel and Control cell lines
ARID1A_HomDel_muts_and_ctrls <- ARID1A_groups %>% filter(Group %in% c("ARID1A_HomDel", "Control"))

# Get RNA expression 
ARID1A_HomDel_muts_and_ctrls_rna <- extract_rna_expr(
  Input_samples = ARID1A_HomDel_muts_and_ctrls$DepMap_ID, 
  Input_genes = "ARID1A",
  data_dir = GINIR_data_dir)
#> [1] "Following sample did not contain profile data: ACH-001151, ACH-001685, ACH-001956"
```

Not all cell lines contain RNA and/or protein expression profiles, and
not all proteins were detected by mass spectrometer. (Details on data
generation can be found on the [DepMap
site](https://depmap.org/portal/).)

``` r
# Get protein expression
ARID1A_HomDel_muts_and_ctrls_protein <- extract_protein_expr(
  Input_samples = ARID1A_HomDel_muts_and_ctrls$DepMap_ID,
  Input_genes = "ARID1A",
  data_dir = GINIR_data_dir)

# Produces an error message since ARID1A protein data is not available
```

Using Welch’s t-test, we can check to see whether *ARID1A* RNA
expression (in TPM) is significantly reduced in `ARID1A_HomDel` cell
lines compared to `Controls`.

``` r
# Append groups and test differential expression
ARID1A_HomDel_muts_and_ctrls_rna <- left_join(ARID1A_HomDel_muts_and_ctrls_rna,
                                              ARID1A_HomDel_muts_and_ctrls %>% select(DepMap_ID, Group))
#> Joining, by = "DepMap_ID"

# T-test 
t.test(ARID1A_8289 ~ Group, ARID1A_HomDel_muts_and_ctrls_rna)
#> 
#>  Welch Two Sample t-test
#> 
#> data:  ARID1A_8289 by Group
#> t = -5.4354, df = 12.591, p-value = 0.0001276
#> alternative hypothesis: true difference in means is not equal to 0
#> 95 percent confidence interval:
#>  -1.7621880 -0.7574242
#> sample estimates:
#> mean in group ARID1A_HomDel       mean in group Control 
#>                    3.557090                    4.816896

# plot 
ggplot(ARID1A_HomDel_muts_and_ctrls_rna, aes(x = Group, y = ARID1A_8289)) +
  geom_boxplot()
```

<img src="man/figures/README-Check_expression_rna_stats-1.svg" width="100%" />

### Perform *in silico* genetic screen

After determining cell lines in the `ARID1A_HomDel` group has
statistically significant reduction in RNA expression compared to
`Control` cell lines, the next step is to perform a *in silico* genetic
screen using `screen_results()`. This uses the dependency probabilities
(or **“lethality probabilities”**) generated from DepMap’s genome-wide
CRISPR-Cas9 knockout screen.

**Lethality probabilities** range from 0.0 to 1.0 and is quantified for
each gene knock out in every cancer cell line screened (There are 18,334
genes targeted in 739 cancer cell lines). A gene knock out with a
lethality probability of 0.0 indicates a non-essential for the cell
line, and a gene knock out with a 1.0 indicates an essential gene (ie.
very lethal). Details can be found in [Meyers, R., et
al., 2017](https://doi.org/10.1038/ng.3984)

At its core, `screen_results()` performs multiple Mann-Whitney U tests,
comparing lethality probabilities of each targeted gene between mutant
and control groups. This generates a data frame with the following
columns:

  - `GeneName_ID` - Hugo symbol with NCBI gene ID
  - `GeneNames` - Hugo symbol
  - `_median, _mean, _sd, _iqr` - Control and mutant group’s median,
    mean, standard deviation (sd), and interquartile range (iqr) of
    dependency probabilities. Dependency probabilities range from zero
    to one, where one indicates a essential gene (ie. KO of gene was
    lethal) and zero indicates a non-essential gene (KO of gene was not
    lethal)
  - `Pval` - P-value from Mann Whitney U test between control and mutant
    groups.
  - `Adj_pval` - BH-adjusted P-value.
  - `log2FC_by_median` - Log2 normalized median fold change of
    dependency probabilities (mutant / control).
  - `log2FC_by_mean` - Log2 normalized mean fold change of dependency
    probabilities (mutant / control).
  - `CliffDelta` - Cliff’s delta non-parametric effect size between
    mutant and control dependency probabilities. Ranges between -1 to 1.
  - `dip_pval` - Hartigan’s dip test p-value. Tests whether distribution
    of mutant dependency probability is unimodel. If dip test is
    rejected (p-value \< 0.05), this indicates that there is a
    multimodel dependency probability distribution and that there may be
    another factor contributing to this separation.
  - `Interaction_score` - Combined value generated from signed p-values:
    -log10(Pval) \* sign(log2FC\_by\_median). Negative scores indicate
    lethal genetic interaction, and positive scores indicate alleviating
    genetic interaction.

<!-- end list -->

``` r
ARID1A_mutant_IDs <- ARID1A_groups %>% filter(Group %in% c("ARID1A_HomDel")) %>% pull(DepMap_ID)
ARID1A_control_IDs <- ARID1A_groups %>% filter(Group %in% c("Control")) %>% pull(DepMap_ID)

# This can take several hours depending on number of lines/cores used. Best to run this overnight.
screen_results <- GINI_screen(
  control_IDs = ARID1A_mutant_IDs, 
  mutant_IDs = ARID1A_control_IDs, 
  core_num = 5, # depends on how many cores you have  
  output_dir = "path/to/results/folder/", # Will save your results here as well as in the variable
  data_dir = GINIR_data_dir,
  test = FALSE) # use TRUE to run a short test to make sure all will run overnight.
```

We can quickly determine whether any lethal genetic interactions were
predicted by `GINIR`. We use a `Pval` cut off of 0.05 and rank based on
the `Interaction_score`.

``` r
screen_results %>% 
  filter(Pval < 0.05) %>%
  arrange(-Interaction_score) %>% 
  select(GeneNames:Mutant_median, Pval, Interaction_score) %>% head
#> # A tibble: 6 × 5
#>   GeneNames Control_median Mutant_median         Pval Interaction_score
#>   <chr>              <dbl>         <dbl>        <dbl>             <dbl>
#> 1 ARID1B           0.0364        0.590   0.0000000342              7.47
#> 2 OR2M3            0.00912       0.0279  0.000255                  3.59
#> 3 C1QTNF5          0.0794        0.253   0.000334                  3.48
#> 4 LSM1             0.0273        0.112   0.000548                  3.26
#> 5 ONECUT1          0.00116       0.00451 0.00107                   2.97
#> 6 ANP32B           0.0160        0.0566  0.00119                   2.92
```

We immediately see that *ARID1B*, a known synthetic lethal interaction
of *ARID1A*, was a the top of this list.

### Visualize screen results

Finally once the *in silico* screen is complete, results can be quickly
visualized using `plot_screen()`. Positive genetic interaction scores
indicate potential synthetic lethal genetic interactors, and negative
scores indicate potential alleviating genetic interactors. As expected,
we identified *ARID1B* as a synthetic lethal interactor of *ARID1A*.

``` r
# Visualize results, turn on gene labels, 
# and label three genes each that are predicted to have 
# lethal and alleviating genetic interactions, respectively

plot_screen(result_df = screen_results, 
            label_genes = TRUE, 
            label_n = 3)
```

<img src="man/figures/README-plot-1.svg" width="100%" />

## Example: Identifying *ARID1A* co-essential genes

Perturbing genes that function in same/synergistic pathways or in the
same complex are said to show similar fitness effects, and these that
show effects are considered to be “co-essential”. The strategy of
mapping co-essential gene have been used by several studies to attribute
functions to previously annotated genes as well as to identify a novel
subunit of a large complex ([Wainberg et
al. 2021](https://doi.org/10.1038/s41588-021-00840-z); [Pan et
al. 2018](https://doi.org/10.1016/j.cels.2018.04.011)).

Given that ARID1A is known subunit of the mammalian SWI/SNF complex
([Mashtalir et al. 2018](https://doi.org/10.1016/j.cell.2018.09.032)),
we expect that members of the SWI/SNF complex would share
co-essentiality with *ARID1A*. This example will demonstrate how we can
map *ARID1A*’s co-essential gene network using `GINIR`.

## Identifying genes with highest correlation coefficients

To determine co-esseential genes, we will perform multiple Pearson
correlation coefficient analyses between *ARID1A* KO effects and the KO
effects of all 18,333 genes. A cut off will be determined by calculating
the inflection point of the ranked coefficient curve. As expected find
SWI/SNF subunit encoding genes, *SMARCE1* and *SMARCB1*, as the top two
co-essential genes.

``` r
# Map co-essential genes
coess_df <- coessential_map(
  Input_gene = "ARID1A", 
  core_num = 5, 
  data_dir = GINIR_data_dir, 
  output_dir = "path/to/results/folder/",
  test = FALSE)

# Calculate inflection points of positive and negative curve using co-essential gene results.
coess_inflection_df <- get_inflection_points(coess_df)
```

Next, we annotate the data frame containing the co-essential network
data and visualize.

``` r
# Combine and annotate data frame containg co-essential genes
coess_annotated_df <- annotate_coessential_df(coess_df, coess_inflection_df)

plot_coessential_genes(
  result_df = coess_annotated_df, 
  inflection_df = coess_inflection_df,
  label_genes = TRUE, # Should gene names be labled?
  label_n = 3) # Number of genes to display from each end
```

<img src="man/figures/README-combine_n_visualize-1.svg" width="100%" />

We also see that the top ten *ARID1A* co-essential genes include eight
known SWI/SNF subunits, namely *ARID1A*, *SMARCE1*, *SMARCB1*,
*SMARCC1*, *DPF2*, *SS18*, *SMARCC2*, and *SMARCD2*.

``` r
# Show top 10 co-essential genes. 
coess_annotated_df %>% arrange(Rank) %>% head(10)
#> # A tibble: 10 × 13
#>    GeneNameID_A GeneNameID_B estimate statistic  p.value parameter conf.low
#>    <chr>        <chr>           <dbl>     <dbl>    <dbl>     <int>    <dbl>
#>  1 ARID1A_8289  ARID1A_8289     1        Inf    0              724    1    
#>  2 ARID1A_8289  SMARCE1_6605    0.508     15.9  7.70e-49       724    0.452
#>  3 ARID1A_8289  SMARCB1_6598    0.488     15.0  1.07e-44       724    0.430
#>  4 ARID1A_8289  SMARCC1_6599    0.436     13.0  4.79e-35       724    0.375
#>  5 ARID1A_8289  DPF2_5977       0.395     11.6  1.62e-28       724    0.332
#>  6 ARID1A_8289  SS18_6760       0.300      8.47 1.32e-16       724    0.233
#>  7 ARID1A_8289  SMARCC2_6601    0.248      6.88 1.34e-11       724    0.178
#>  8 ARID1A_8289  SMARCD2_6603    0.227      6.27 6.16e-10       724    0.157
#>  9 ARID1A_8289  IER5L_389792    0.210      5.78 1.12e- 8       724    0.139
#> 10 ARID1A_8289  PRDM15_63977    0.206      5.66 2.20e- 8       724    0.135
#> # … with 6 more variables: conf.high <dbl>, method <chr>, alternative <chr>,
#> #   Rank <int>, Padj_BH <dbl>, Candidate_gene <lgl>
```

## Session Info

``` r
sessionInfo()
#> R version 4.0.2 (2020-06-22)
#> Platform: x86_64-centos7-linux-gnu (64-bit)
#> Running under: CentOS Linux 7 (Core)
#> 
#> Matrix products: default
#> BLAS:   /gsc/software/linux-x86_64-centos7/R-4.0.2/lib64/R/lib/libRblas.so
#> LAPACK: /gsc/software/linux-x86_64-centos7/R-4.0.2/lib64/R/lib/libRlapack.so
#> 
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
#>  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
#>  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
#>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
#>  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
#> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#>  [1] GINIR_0.1.0     forcats_0.5.1   stringr_1.4.0   dplyr_1.0.8    
#>  [5] purrr_0.3.4     readr_2.1.2     tidyr_1.2.0     tibble_3.1.6   
#>  [9] ggplot2_3.3.5   tidyverse_1.3.1
#> 
#> loaded via a namespace (and not attached):
#>  [1] matrixStats_0.59.0            fs_1.5.0                     
#>  [3] doMC_1.3.8                    lubridate_1.7.10             
#>  [5] doParallel_1.0.16             httr_1.4.2                   
#>  [7] tools_4.0.2                   backports_1.4.1              
#>  [9] utf8_1.2.2                    R6_2.5.1                     
#> [11] nortest_1.0-4                 DBI_1.1.2                    
#> [13] colorspace_2.0-3              withr_2.5.0                  
#> [15] tidyselect_1.1.2              Exact_2.1                    
#> [17] compiler_4.0.2                rcompanion_2.4.1             
#> [19] cli_3.2.0                     rvest_1.0.0                  
#> [21] expm_0.999-6                  xml2_1.3.3                   
#> [23] sandwich_3.0-1                labeling_0.4.2               
#> [25] inflection_1.3.5              diptest_0.76-0               
#> [27] scales_1.1.1                  lmtest_0.9-38                
#> [29] mvtnorm_1.1-2                 proxy_0.4-26                 
#> [31] multcompView_0.1-8            RootsExtremaInflections_1.2.1
#> [33] digest_0.6.29                 rmarkdown_2.9                
#> [35] pkgconfig_2.0.3               htmltools_0.5.2              
#> [37] highr_0.9                     dbplyr_2.1.1                 
#> [39] fastmap_1.1.0                 rlang_1.0.1                  
#> [41] readxl_1.3.1                  rstudioapi_0.13              
#> [43] farver_2.1.0                  generics_0.1.2               
#> [45] zoo_1.8-9                     jsonlite_1.7.2               
#> [47] magrittr_2.0.2                modeltools_0.2-23            
#> [49] Matrix_1.3-4                  Rcpp_1.0.8                   
#> [51] DescTools_0.99.42             munsell_0.5.0                
#> [53] fansi_1.0.2                   lifecycle_1.0.1              
#> [55] multcomp_1.4-17               stringi_1.7.6                
#> [57] yaml_2.2.1                    MASS_7.3-51.6                
#> [59] rootSolve_1.8.2.1             plyr_1.8.6                   
#> [61] grid_4.0.2                    parallel_4.0.2               
#> [63] ggrepel_0.9.1                 crayon_1.5.0                 
#> [65] lmom_2.8                      lattice_0.20-41              
#> [67] haven_2.4.1                   splines_4.0.2                
#> [69] hms_1.1.1                     knitr_1.37                   
#> [71] pillar_1.7.0                  boot_1.3-25                  
#> [73] gld_2.6.2                     stats4_4.0.2                 
#> [75] codetools_0.2-16              reprex_2.0.0                 
#> [77] glue_1.6.2                    evaluate_0.14                
#> [79] data.table_1.14.2             modelr_0.1.8                 
#> [81] vctrs_0.3.8                   tzdb_0.2.0                   
#> [83] foreach_1.5.2                 cellranger_1.1.0             
#> [85] gtable_0.3.0                  assertthat_0.2.1             
#> [87] xfun_0.29                     coin_1.4-1                   
#> [89] libcoin_1.0-8                 broom_0.7.12                 
#> [91] e1071_1.7-7                   class_7.3-17                 
#> [93] survival_3.1-12               iterators_1.0.14             
#> [95] TH.data_1.0-10                ellipsis_0.3.2
```
