class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            ) 
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        new_dog = self.new(id:id, name:name, breed:breed)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
            SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)
        dog = Dog.new(hash)    
        dog.save
        dog
    end

    def update
        sql ="UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_by_id(id)
        sql = <<-SQL 
        SELECT * FROM dogs WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map {|row| self.new_from_db(row)}.first
    end

    def self.find_by_name(name)
        sql = <<-SQL 
        SELECT * FROM dogs WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? AND breed = ?
        SQL
  
        dog = DB[:conn].execute(sql, name, breed).first
        if dog
            dog = self.new_from_db(dog)
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end
end