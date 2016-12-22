module Group
  class Main

    DB = Sequel.connect('sqlite://group.db')


    def process!(args)
      Group.logger.info args
      @input_file = args.first
      @output_file = "output/#{File.basename(@input_file)}"
      @matching_type = args.last

      create_tables
      parse_csv
    end


    def parse_csv
      csv_opts = { headers: true, header_converters: :symbol }

      create_output_file do |out|
        headers = CSV.read(@input_file, headers: true).headers.unshift('Id')
        out << headers
        CSV.foreach(@input_file, csv_opts) do |row|
          out << processed_row(row)
        end
      end
    end


    def processed_row(row)
      emails = [row[:email], row[:email1], row[:email2]].compact
      phones = [row[:phone], row[:phone1], row[:phone2]].compact

      case @matching_type
      when 'same_email'
        same_person_id = DB[:emails].select(:id).where(content: emails).order(:id).limit(1).first
        if same_person_id
          row[:id] = same_person_id[:id]
        else
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
        end
      end

      [:id,
       :firstname,
       :lastname,
       :phone1,
       :phone2,
       :email1,
       :email2,
       :zip].map { |r| row[r] }
    end


    def create_output_file
      Dir.mkdir('output')
      CSV.open(@output_file, 'wb') { |f| yield(f) }
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
