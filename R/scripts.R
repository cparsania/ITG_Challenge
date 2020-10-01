
library(tidyverse)
library(vcfR)

#' Remove duplicates positions from given vcf file.
#'
#' @param vcf_file A string denoting path to vcf file 
#' @param keep_first_last_and_random  logical to indicate weather to keep first, last and duplicate from each duplicate
#'
#' @return a tibble of unique positions 
#' @export
#'
#' @examples
vcf_remove_duplicates  <- function(vcf_file , keep_first_last_and_random = F){
         
         stopifnot(file.exists(vcf_file))
         
         vcf <- vcfR::read.vcfR( vcf_file, verbose = FALSE )
         
         x1 <- vcfR::getFIX(vcf) %>% 
                 tibble::as_tibble() %>% 
                 readr::type_convert(col_types = cols(CHROM = "d" ,POS = "d",ID = "c")) %>% 
                 dplyr::arrange(CHROM,POS) %>%
                 dplyr::group_by(CHROM,POS) %>% 
                 dplyr::mutate(row_num = row_number()) %>%
                 dplyr::slice(1, n() , sample(2:(n()-1),1)) %>% ## keep 1st, last and a random record 
                 dplyr::select(- row_num) %>% ## remove extra column
                 unique()
                 
         
         ## keep_first_last_and_random = F (default) remove all duplicates by pos.
         if(!keep_first_last_and_random){
                 x1 <- x1 %>% dplyr::slice(1)
         }
                 
         return(x1)
}

vcf_remove_duplicates("data/duplicates.vcf.gz" , keep_first_last_and_random = T)
