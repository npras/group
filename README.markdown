# Programming Exercise - Grouping

The goal of this exercise is to identify rows in a CSV file that
__may__ represent the __same person__ based on a provided __Matching Type__ (definition below).

The resulting program should allow us to test at least three matching types:
 - one that matches records with the same email address - same_email
 - one that matches records with the same phone phone number - same_phone
 - one that matches records with the same email address OR the same phone number - same_email_or_phone


### CSV Files

Three sample input files are included. All files should be successfully
processed by the resulting code.

### Matching Type

* same_email
* same_phone
* same_email_or_phone


## Interface

At a high level, the program should take two parameters. The input file
and the matching type.


## Output

The expected output is a copy of the original CSV file with the unique 
identifier of the person each row represents prepended to the row.
