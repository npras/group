module Group
  class Main


    DB = Sequel.connect('sqlite://group.db')
    #DB.loggers << Logger.new($stdout)


    def process!(args)
      Group.logger.info args
      @input_file = args.first
      @output_file = "output/#{File.basename(@input_file)}"
      @matching_type = args.last
      @format_row = false

      create_tables
      the_work
      delete_tables
    end


    def the_work
      csv_opts = { headers: true, header_converters: :symbol }

      create_output_file do |out|
        headers = CSV.read(@input_file, headers: true).headers.unshift('Id')
        out << headers
        @format_row = true if headers.include?('Email') # or 'Phone'
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
        if (same_person_id = DB[:emails].select(:id).where(content: emails).order(:id).limit(1).first)
          row[:id] = same_person_id[:id]
        else
          row[:id] = DB[:people].insert(first_name: row[:firstname], last_name: row[:lastname], zip: row[:zip])
          emails.each { |e| DB[:emails].insert(person_id: row[:id], content: e) rescue SQLite3::ConstraintException }
        end
      when 'same_phone'
        if (same_person_id = DB[:phones].select(:id).where(content: phones).order(:id).limit(1).first)
          row[:id] = same_person_id[:id]
        else
          row[:id] = DB[:people].insert(first_name: row[:firstname], last_name: row[:lastname], zip: row[:zip])
          phones.each { |ph| DB[:phones].insert(person_id: row[:id], content: ph) rescue SQLite3::ConstraintException }
        end
      when 'same_email_or_phone'
      end

      fields = if @format_row
                 [:id, :firstname, :lastname, :phone, :email, :zip]
               else
                 [:id, :firstname, :lastname, :phone1, :phone2, :email1, :email2, :zip]
               end
      fields.map { |r| row[r] }
    end


    def create_output_file
      Dir.mkdir('output') unless Dir.exists?('output')
      CSV.open(@output_file, 'wb') { |f| yield(f) }
    end


    def create_tables
      create_table_people
      create_table_phones
      create_table_emails
    end


    def delete_tables
      [:phones, :emails, :people].each do |table|
        DB.drop_table(table)
      end
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
