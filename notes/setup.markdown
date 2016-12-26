# Setup

After cloning/unzipping the application, make sure you have ruby 2.3.1 installed in your system. The app uses it. After that, install the dependencies mentioned in the Gemfile using `bundle install`.


## Running the app

From the root path of this application, run this command to see the output:

> `./bin/group process data/input1.csv same_email`

This is of format:

> `./bin/group process input_csv_file_path matching_type`

where,

* `./bin/group` is the ruby executable. Make sure this file is executable. (`chmod +x bin/group`)

* `process` is the command name

* `input_csv_file_path` is the first argument to the above command. It is a string that represents the input csv's file path. Eg: 'data/input1.csv'. It is present in the `data` folder. This txt file contains the input csv strings to the program. There are also other input files: input{2, 3, 3-1}.csv

* `matching_type` is one of:
  - same_email
  - same_phone
  - same_email_or_phone

So a typical command would look like:

```
./bin/group process data/input1.csv same_email
```


## Output
Once the above command is run, the output csv file (which is a modified version of the input file) can be found in the `output` folder.

The name of the file can be found from the output of the above command. For example, this is the output seen in the terminal (stdout) when the above example command is run:

```
The output is saved in file: output/same_email-input2.csv.
```

The output file will have 'Id' column prefixed to all rows. The Ids will represent unique person depending on the matching_type mentioned.


## Documents
The `notes` folder has the setup and design document in markdown format.
