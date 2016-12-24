module Group
  class Main


    DB = Sequel.connect('sqlite://group.db')
    #DB.loggers << Logger.new($stdout)


    def process!(args)
      Group.logger.info args
      @input_file = args.first
      @matching_type = args.last
      @output_file = "output/#{@matching_type}-#{File.basename(@input_file)}"

      @out_fields = nil
      @formatted_rows = [:id, :firstname, :lastname, :phone, :email, :zip]
      @unformmated_rows = [:id, :firstname, :lastname, :phone1, :phone2, :email1, :email2, :zip]

      create_tables
      the_work
      delete_tables
    end


    def the_work
      csv_opts = { headers: true, header_converters: :symbol }

      create_output_file do |out|
        headers = CSV.read(@input_file, headers: true).headers.unshift('Id')
        out << headers
        @out_fields = headers.include?('Email') ? @formatted_rows : @unformmated_rows
        CSV.foreach(@input_file, csv_opts) { |row| out << processed_row(row) }
      end
    end


    def processed_row(row)
      emails = [row[:email], row[:email1], row[:email2]].compact
      phones = [row[:phone], row[:phone1], row[:phone2]].compact

      same_person = case @matching_type
                    when 'same_email'
                      person_with_any_matching(:emails, emails)
                    when 'same_phone'
                      person_with_any_matching(:phones, phones)
                    when 'same_email_or_phone'
                      person_with_any_matching(:emails, emails) ||
                        person_with_any_matching(:phones, phones)
                    end

      row[:id] = if same_person
                   insert_details(same_person[:person_id],
                                  emails: emails,
                                  phones: phones)
                   same_person[:person_id]
                 else
                   insert_person_details(row, emails: emails, phones: phones)
                 end

      @out_fields.map { |r| row[r] }
    end


    def insert_person_details(row, phones: [], emails: [])
      person_id = DB[:people].insert(first_name: row[:firstname], last_name: row[:lastname], zip: row[:zip])
      insert_details(person_id, phones: phones, emails: emails)
      person_id
    end


    def insert_details(person_id, phones: [], emails: [])
      phones.each { |n| DB[:phones].insert(person_id: person_id, content: n) rescue SQLite3::ConstraintException }
      emails.each { |e| DB[:emails].insert(person_id: person_id, content: e) rescue SQLite3::ConstraintException }
    end


    def person_with_any_matching(table_entity, entities)
      DB[table_entity]
        .select(:person_id)
        .where(content: entities)
        .order(:id)
        .limit(1)
        .first
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
      [:phones,
       :emails,
       :people].each { |table| DB.drop_table(table) }
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
