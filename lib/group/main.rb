module Group
  class Main

    DB = Sequel.connect('sqlite://group.db')

    def process!(args)
      Group.logger.info args
      @input_file = args.first
      @matching_type = args.last
      @format_row = false
      input_basename = File.basename(@input_file)
      @output_file = "output/#{input_basename}"

      create_tables
      parse_csv
    end


    def parse_csv
      csv_opts = { headers: true, header_converters: :symbol }

      create_output_file do |out|
        headers = CSV.read(@input_file, headers: true).headers.unshift('Id')
        out << headers
        @format_row = true if headers.include?('Email')
        CSV.foreach(@input_file, csv_opts) do |row|
          process_row(row: row, out: out)
        end
      end
    end

    def create_output_file
      csv_out = CSV.open(@output_file, 'wb')
      yield(csv_out)
      csv_out.close
    end


    def process_row(row:, out:)
      emails = [row[:email], row[:email1], row[:email2]].compact
      phones = [row[:phone], row[:phone1], row[:phone2]].compact

      person_id = DB[:people].insert(
        first_name: row[:firstname],
        last_name: row[:lastname],
        zip: row[:zip],
      )
      row[:id] = person_id
      phones.each do |phone|
        DB[:phones].insert(person_id: person_id, content: phone) rescue SQLite3::ConstraintException
      end
      emails.each do |email|
        DB[:emails].insert(person_id: person_id, content: email) rescue SQLite3::ConstraintException
      end
      out << [:id, :firstname, :lastname, :phone1, :phone2, :email1, :email2, :zip].map { |r| row[r] }
    end

    def create_tables
      create_table_people
      create_table_phones
      create_table_emails
    end

    def create_table_people
      return if DB.table_exists?(:people)
      DB.create_table(:people) do
        primary_key :id
        String :first_name
        String :last_name
        String :zip
      end
    end

    def create_table_phones
      return if DB.table_exists?(:phones)
      DB.create_table(:phones) do
        primary_key :id
        foreign_key :person_id, :people
        String :content
        index :content, unique: true
      end
    end

    def create_table_emails
      return if DB.table_exists?(:emails)
      DB.create_table(:emails) do
        primary_key :id
        foreign_key :person_id, :people
        String :content
        index :content, unique: true
      end
    end

  end
end
