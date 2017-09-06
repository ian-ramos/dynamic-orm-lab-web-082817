require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize #takes name of class, turns ito into a string, downcase, and pluralizes
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')" #returns array of hashes, with each hash a different column Of particular importance, the name key

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row| #iterates on array and shovels value of name key into array
      column_names << row["name"]
    end
    column_names.compact #just in case we have any nil
  end

  def initialize(options={})
    options.each do |property, value| #iterates on each key/value pair
      self.send("#{property}=", value) #send calls the method (in this case the setter method for variable) and passes the value as the argument
    end
  end

  self.column_names.each do |col_name| #iterates on column_names (an array of column names) and turns each element into a symbol
   attr_accessor col_name.to_sym
 end

  def table_name_for_insert #instance method version of self.table_name (can't use a class method inside an instance method)
    self.class.table_name
  end

  def col_names_for_insert #in SQL, you separate the columns with a comma (SELECT column1, column2).  Also, we don't want to include id because we don't insert that
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name| #take each column name and use send to call the getter method of that column name
      values << "'#{send(col_name)}'" unless send(col_name).nil? #id would be nil before a record is saved
    end
    values.join(", ") #values that you're passing are comma separated and in single quotes (which is why send(col_name) is in single quotes)
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0] #array element index 0, value of key 0
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    attribute.each do |key, value|
      sql = "SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}'"
      return DB[:conn].execute(sql)
    end
  end

end
