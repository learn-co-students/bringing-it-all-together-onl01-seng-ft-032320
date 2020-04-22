class Dog
   attr_accessor :id, :name, :breed

   def initialize(dog_hash)
      dog_hash.each{|k,v| self.send("#{k}=",v)}
   end
   
   def self.create(dog_hash)
      dog = {} #create empty hash
      dog = Dog.new(dog) #create new instance set to hash
      dog_hash.each{|k,v| dog.send("#{k}=",v)} #fill hash
      dog.save #save instnace
      
      dog 
   end

   def self.create_table
      sql = <<-SQL
      CREATE TABLE dogs(
         id INTEGER PRIMARY KEY,
         name TEXT,
         breed TEXT
      )
      SQL

      DB[:conn].execute(sql)
   end

   def self.drop_table
      sql = <<-SQL
      DROP TABLE dogs
      SQL

      DB[:conn].execute(sql)
   end

   def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
   end

   def save
      if self.id #if id exists 
         self.update #just update the instance
      else #otherwise save it 
         sql = <<-SQL
         INSERT INTO dogs (name,breed)
         VALUES (?,?)
         SQL

         DB[:conn].execute(sql,self.name,self.breed) #creates record in DB
         @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] #sets instance id to ID from DB
      end
      self
   end

   def self.new_from_db(row)
      #takes in row from query and creates instance 
      dog = {
         id: row[0],
         name: row[1],
         breed: row[2]
      }

      Dog.new(dog)
   end

   def self.find_by_name(name)
      sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      SQL

      DB[:conn].execute(sql,name).collect{|row| self.new_from_db(row)}.first
   end

   def self.find_by_id(id)
      sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      SQL

      DB[:conn].execute(sql,id).collect{|row| self.new_from_db(row)}.first
   end

   def self.find_or_create_by(name:,breed:)
      sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
      SQL

      result = DB[:conn].execute(sql,name,breed).flatten #set result to reg array of info

      if !result.empty?
         self.find_by_name(name) #simply return 
      else #otherwise create one
         dog = {
            id: result[0],
            name: result[1],
            breed: result[2]
         }
         self.create(dog)
      end
   end

end