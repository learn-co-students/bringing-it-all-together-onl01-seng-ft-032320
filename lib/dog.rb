class Dog
  
  attr_accessor :name, :breed , :id
   
  
  def initialize(name:, breed:, id: nil)
    #binding.pry 
    @name = name 
    @breed = breed 
    @id = id
    
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end 
  
  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end 
  
  def self.new_from_db(array)
    hash = { id: array[0], name: array[1], breed: array[2]
      
    }
     dog = Dog.new(hash)
     dog 
  end 
  
  def self.find_by_name(name)
    
    sql = "SELECT * FROM dogs WHERE name = ?"
      DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first 
    
  end 
  
  def self.find_or_create_by(args)
    sql = "Select * FROM dogs WHERE name = ? AND breed = ?"
    
    dog = DB[:conn].execute(sql, args[:name], args[:breed])
      
    if !dog.empty?
      #binding.pry
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      
    else
      dog = self.create(args)
    end
    dog
  end 
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE  id = ?"
     DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first 
    
  end 
  
  
  
  def update
    self.id 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
   
  end 
  
  def save 
     sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end 
end 