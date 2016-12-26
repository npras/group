# Design

Using an RDBMS seems to be the ideal scalable solution. So I've used the sqlite database and the Sequel gem to interact with the database.

The input file is processed one line at a time. Each row is 'processed', and then the processed row is written to an output csv file.


## Database Schema
The system uses this DB design:

People, Emails, Phones are the 3 tables.

A Person can have 1 or more emails and phones. person_id is a foreign key in emails and phones tables.

### People
DB.create_table(:people) do
  primary_key :id
  String :first_name
  String :last_name
  String :zip
end

### Emails
DB.create_table(:emails) do
  primary_key :id
  foreign_key :person_id, :people
  String :content
  index :content, unique: true
end

### Phones
DB.create_table(:phones) do
  primary_key :id
  foreign_key :person_id, :people
  String :content
  index :content, unique: true
end


## Row Processing
Depending on the matching type, for each row, first we query the tables (emails or phoes) to see if we have any records with the matching field(s) present.

If we find a matching record, then we just get the corresponding record's person's id (person_id). We then prefix it to the existing row and write it to the output filestream. If the incoming row has new phones and emails, then that person's email and phone records are updated accordingly (new rows inserted).

If we don't find a matching record, we just insert the row details as a new person record with corresponding email and phone records.


## Modular Components
All classes and modules for this app are wrapped in the main `Group` module.

The executable file `bin/group` calls the `process` thor command defined in the `Group::CLI` thor class.

This thor just acts as a proxy to the PORO `Group::Main` class whose `process!` method orchestrates the main functionality of the app.
