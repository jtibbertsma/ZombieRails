require_relative '../zombie_record/sqlobject.rb'

class Human < SQLObject
  belong_to :house
  has_many :cats

  self.table_name = 'humans'
  finalize!
end