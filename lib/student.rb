require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  self.column_names.each do |col_name| #iterates on column_names (an array of column names) and turns each element into a symbol
    attr_accessor col_name.to_sym
  end

end
