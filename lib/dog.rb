class Dog

    attr_accessor :name, :breed, :id

    def initialize(id:  nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def save
        sql = "INSERT INTO dogs (name, breed) VALUES ( ?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def self.create(name: name, breed: breed) 
        attributes = {name: name, breed: breed}
        new_dog = self.new(attributes)
        new_dog.save
    end

    def self.new_from_db(row)
        new_dog = Dog.new(name: row[1], breed: row[2])
        new_dog.id = row[0]
        new_dog
    end

    def self.find_by_id(id_input)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id_input)[0]
        new_dog = self.new(id: id_input, name: row[1], breed: row[2])
        new_dog
    end

    def self.find_or_create_by(name: name, breed: breed)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"
        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            dog = dog[0]
            new_dog = self.new(id: dog[0], name: dog[1], breed: dog[2])
        else
            new_dog = self.create(name: name, breed: breed)
        end
        new_dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        dog = DB[:conn].execute(sql, name)
        self.new_from_db(dog[0])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    
end