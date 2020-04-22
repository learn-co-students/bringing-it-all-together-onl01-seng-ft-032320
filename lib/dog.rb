class Dog

    #### Attributes ####
    attr_accessor :name, :breed, :id

    #### Instance Methods ####
    def initialize(id=nil, hash)
        @id = id
        hash.each {|key,value| self.send(("#{key}="), value)}
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
            SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end


    #### Class Methods####
    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
            SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def self.create(hash)
        new_dog = self.new(hash)
        new_dog.save
    end

    def self.new_from_db(row)
        self.new(row[0], {:name => row[1], :breed => row[2]})
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            SQL

        dog = DB[:conn].execute(sql, id)[0]
        self.new({:id => dog[0], :name => dog[1], :breed => dog[2]})
    end

    def self.find_or_create_by(hash)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            AND breed = ?
            SQL

        result = DB[:conn].execute(sql, hash[:name], hash[:breed])
        if !result.empty?
            dog_data = result[0]
            dog = Dog.new(dog_data[0], {:name => dog_data[1], :breed => dog_data[2]})
        else
            dog = self.create(hash)
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            SQL

        result = DB[:conn].execute(sql, name)[0]
        Dog.new(result[0], {:name => result[1], :breed => result[2]})
    end
end
