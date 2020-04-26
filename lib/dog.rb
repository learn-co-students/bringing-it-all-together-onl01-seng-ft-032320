class Dog
  attr_accessor :name, :breed, :id
  
  def initialize(hash)
    
    hash.each do |key, value|
      self.send(("#{key}="), value)
    end
    self.id ||= nil
    
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
    
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL
      
    DB[:conn].execute(sql)
    
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
  
  def self.create(hash)
    
    new_dog = self.new(hash)
    new_dog.save
    
    new_dog
    
  end
  
  def self.new_from_db(row)
    
    hash = {
      id: row[0],
      name: row[1],
      breed: row[2]
    }
    
    self.new(hash)
    
  end
  
  def self.find_by_id(id)
    
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      SQL
      
    DB[:conn].execute(sql, id).collect do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(name:name, breed:breed)
    
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      LIMIT 1
      SQL

    dog = DB[:conn].execute(sql, name, breed)


    if !dog.empty?
      dog = dog[0]
      new_dog = Dog.new(id:dog[0], name:dog[1], breed:dog[2])
    else
      new_dog = self.create(name:name, breed:breed)
    end
      
    new_dog
    
  end
  
  def self.find_by_name(name)
    
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      SQL
      
    DB[:conn].execute(sql, name).collect do |row|
      self.new_from_db(row)
    end.first
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL
      
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
end