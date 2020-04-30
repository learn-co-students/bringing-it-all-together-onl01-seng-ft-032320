require 'pry'

class Dog
  
  attr_accessor :name, :breed, :id
  
  def initialize(attributes)
    
    attributes.each do |key, value|
      self.send(("#{key}="), value)
    end
  end
  
  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
    DB[:conn].execute(sql)
  end
  
   def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end
  
  def save
    sql = "INSERT INTO dogs(name, breed) VALUES (?, ?);"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
  end
  
   def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end
  
  def self.new_from_db(rows)
   attributes = {:id => rows[0], :name => rows[1], :breed => rows[2]}
   self.new(attributes)
  end
  
   def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    results = DB[:conn].execute(sql, id)[0]
    self.new(id: results[0], name: results[1], breed: results[2])
  end
  
  def self.find_or_create_by(name:, breed:)
     sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
     results = DB[:conn].execute(sql, name, breed)
    if !results.empty?
      dog = Dog.new_from_db(results.flatten)
    else
      attributes = {:name => name, :breed => breed}
      dog = self.create(attributes)
    end
    dog
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    results = DB[:conn].execute(sql, name)
    
    results.map {|row| self.new_from_db(row)}.first
  end

  
  def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end