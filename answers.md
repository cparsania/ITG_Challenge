Answers
================
chirag parsania
10/1/2020

### Support/resource management/Shell

**1.** A user has several versions of R installed in their path. Each
version of R has a number of locally installed libraries. The user is
confused, and would like to know which library is installed for each
version of R. Can you write a command to help them out?

**Answer**:

``` bash

for i in `ls -d path/to/the/R/versions*` ; do echo $i ; ls -A $i/Resources/library/ ; done 

## Working example on my computer 

for i in `ls -d /Library/Frameworks/R.framework/Versions/*` ; do echo $i ; ls -A $i/Resources/library/ ; done
```

**2.** A common problem with shared filesystems is a disk quota
overflow. This can be due to 1) a large combined size on disk or 2) too
many files present on disk. We would like to help users who encounter
this problem to locate the problematic files/directories. Write a
command to sort all subdirectories of level `n` (`n` determined by the
user) by their human-readable size. Write another command to sort all
subdirectories of level `n` according to the number of files they
contain.

**Answer**:

  - Sort all sub directories by human-readable size.

<!-- end list -->

``` bash
level_n=2

find . -maxdepth $level_n -type d -exec ls -lSh "{}" \;
```

  - Sort all subdirectories of level `n` according to the number of
    files they contain.

<!-- end list -->

``` bash
level_n=2 

find . -maxdepth level_n -type f -exec ls -d "{}" \; | cut -d "/" -f 2 | sort | uniq -c | sort -n 
```

**3** A user wants to install an `R` package and gets the following
[error log](data/error.log). What is likely to cause the error and how
can they solve it?

**Answer**:

Probably the error occurred due to outdated G++ compiler. Therefore,
updating the G++ is one of the solutions. The aother way to solve the
error is install failed R packages from binary sources.

Install from binary

``` r
install.packages(c("minqa", "nloptr", "caTools", "mzR", "pcaMethods", "ggrepel", "lme4", "gplots", "MSnbase", "MSstats"),
                 type = "binary")
```

**4.** A user is running commands like this one `cat file1 <(cut -d " "
-f 1-15,17,18 file2) > file3`. What does this command do? It runs fine
on the command line, but then the user includes it into a file with
other commands, saves it and runs `chmod +x` on it. However, that line
of code throws the following error : `syntax error near unexpected token
'('`. What has the user forgotten?

**Answer**:

The given command will extract the columns 1 to 15, 17, and 18 from
space delimited file (file 2). Outout will be STDIN (\<) to command cat.
Finally, concatenated output of file1 and STDIN will be printed in
file3.

The error `syntax error near unexpected token '('` is probably due to
incorrect use of interpreter. User might have executed script via `sh`
which is meant for `bash`,however. Executing script via `bash` will
solve the error. Alternatively, user can also add bash Shebang line
`(#!/bin/bash)` on the top of script to indicate a bash interpreter for
execution under UNIX / Linux operating systems.

**5.** A collaborator has sent you [this script](data/EasyQCWrapper.sh).
It is a wrapper for a bioinformatics software called `EasyQC`. Running
it, you get the following error:

``` bash

    ./test.EasyQC-START.R: line 6: syntax error near unexpected token 'EasyQC'
    ./test.EasyQC-START.R: line 6: 'library(EasyQC)'
    
```

You need to run this script now, but your collaborator is unavailable
for a few days. What is causing the error? (Hint: Nothing is wrong with
the `.ecf` EasyQC script.)

**Answer**:

I think, the way R script is being executed is not correct. Line number
191 of [this script](data/EasyQCWrapper.sh) should be `Rscript
$1.EasyQC-START.R` instead of `./$1.EasyQC-START.R`.

**7.** Bioinformaticians often work on a computing cluster. The cluster
runs a software called a job scheduler that attributes resources to
users depending on the requirements of their jobs. In this case, let’s
imagine the cluster is running IBM LSF. You do not need to know it to
answer this question. The `bjobs` command lists all jobs submitted by
the user (manpage
[here](https://www.ibm.com/support/knowledgecenter/en/SSETD4_9.1.2/lsf_command_ref/bjobs.1.html)).
It gives this kind of output:

``` 
    JOBID   USER             STAT  QUEUE      FROM_HOST EXEC_HOST JOB_NAME SUBMIT_TIME
    9670681 current_user     RUN   basement   head_node node1     job1     Oct 24 10:24
    9740051 current_user     RUN   basement   head_node node1     job2     Oct 24 17:41
    9670681 current_user     RUN   normal     head_node node2     job3     Oct 24 10:24
    9740981 current_user     PEND  basement   head_node           job4     Oct 24 17:44
```

  - Given the [following output](data/farm-snapshot.txt) of `bjobs
    -all`, which users are the top 5 users of the cluster?
  - How many jobs does the user `pathpip` have running in all queues?
  - A user wants to know how many jobs they have pending (`PEND`) and
    running (`RUN`) in each queue. Write a command line to do that (You
    can use the log above to check your command line). How would they
    display this on their screen permanently, in real time?

**Answer**:

  - The top 5 users of the cluster found by following command are
    `km18`, `ro4`, `igs`, `pathpip`, and `so11`.

<!-- end list -->

``` bash

cut -f 2 -d " " farm-snapshot.txt  | sort | uniq -c | sort -nr | head -6

# NOTE : Top 5 users are found by number of jobs they submitted. 
```

  - The number of jobs running by `pathpip` are 1515.

<!-- end list -->

``` bash
cut -f 2 -d " " farm-snapshot.txt | grep "pathpip" | sort | uniq -c | sort -nr 
```

**8.** An analysis you need to run on the cluster requires a particular
python library, but you do not have administrator rights. IT is on
holiday. What do you do?

**Answer**: I will install required library at user level. As of now, I
don’t know how to install python libraries locally.

### Bioinformatics

1.  The [VCF
    format](http://www.internationalgenome.org/wiki/Analysis/vcf4.0/) is
    a popular format to describe genetic variations in a study group. It
    is often used in sequencing projects. Due to size concerns, it is
    often compressed using `gzip` and indexed using `tabix`. A binary
    version, BCF, also exists.
      - Write a command or script to remove duplicate positions in a VCF
        such as [this one](data/duplicates.vcf.gz), independently of
        their alleles. The positions can be duplicated an arbitrary
        number of times. Write code to keep the first, last and a random
        record among each set of duplicated records.
      - Same question, but make duplicate detection allele-specific.
        When it finds such an exact duplicate, your code should remove
        all of the corresponding records.

**Answer**:

  - The R function `vcf_remove_duplicates` to remove duplicates from VCF
    is given in [this file](R/scripts.R)

<!-- end list -->

``` r
## usage 
source("./R/scripts.R")

vcf_uniq_pos <- vcf_remove_duplicates(vcf_file = "data/duplicates.vcf.gz" ,keep_first_last_and_random = F)
vcf_uniq_pos
```

    ## # A tibble: 19,748 x 7
    ## # Groups:   CHROM, POS [19,748]
    ##    CHROM     POS ID        REF   ALT    QUAL FILTER
    ##    <dbl>   <dbl> <chr>     <chr> <chr> <dbl> <chr> 
    ##  1     1 1020639 1:1020639 C     T       118 PASS  
    ##  2     1 1097335 1:1097335 T     G       422 PASS  
    ##  3     1 1223385 1:1223385 G     C       292 PASS  
    ##  4     1 1288583 1:1288583 C     G       405 PASS  
    ##  5     1 1504560 1:1504560 T     A       242 PASS  
    ##  6     1 1695075 1:1695075 G     T       183 PASS  
    ##  7     1 1881510 1:1881510 C     T       455 PASS  
    ##  8     1 1894751 1:1894751 G     A       446 PASS  
    ##  9     1 2142731 1:2142731 C     G       315 PASS  
    ## 10     1 2276371 1:2276371 C     T       166 PASS  
    ## # … with 19,738 more rows

``` r
vcf_first_last_and_a_random <- vcf_remove_duplicates(vcf_file = "data/duplicates.vcf.gz" ,keep_first_last_and_random = T)
vcf_first_last_and_a_random
```

    ## # A tibble: 19,764 x 7
    ## # Groups:   CHROM, POS [19,748]
    ##    CHROM     POS ID        REF   ALT    QUAL FILTER
    ##    <dbl>   <dbl> <chr>     <chr> <chr> <dbl> <chr> 
    ##  1     1 1020639 1:1020639 C     T       118 PASS  
    ##  2     1 1097335 1:1097335 T     G       422 PASS  
    ##  3     1 1223385 1:1223385 G     C       292 PASS  
    ##  4     1 1288583 1:1288583 C     G       405 PASS  
    ##  5     1 1504560 1:1504560 T     A       242 PASS  
    ##  6     1 1695075 1:1695075 G     T       183 PASS  
    ##  7     1 1881510 1:1881510 C     T       455 PASS  
    ##  8     1 1894751 1:1894751 G     A       446 PASS  
    ##  9     1 2142731 1:2142731 C     G       315 PASS  
    ## 10     1 2276371 1:2276371 C     T       166 PASS  
    ## # … with 19,754 more rows