require 'pry'

class Dog

    attr_accessor :id, :name, :breed

    def initialize(attributes)
        attributes.each { |k, v| self.send(("#{k}="), v)}
    end

    def self.create_table
        sql = "CREATE TABLE dogs (id INEGER PRIMARY KEY, name TEXT, breed TEXT)"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save 
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attributes)
        dog = self.new(attributes)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog_attributes = {:id => row[0],
        :name => row[1],
        :breed => row[2]}
        self.new(dog_attributes)
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        dog = DB[:conn].execute(sql, name, breed).first
        if  dog
            dog = self.new_from_db(dog)
        else 
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        DB[:conn].execute(sql, id).map { |row| self.new_from_db(row)}.first
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
        DB[:conn].execute(sql, name).map { |row| self.new_from_db(row)}.first 
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end