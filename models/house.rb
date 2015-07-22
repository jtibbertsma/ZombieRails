require_relative '../zombie_record/sqlobject.rb'

class House < SQLObject
  has_many :humans, class_name: :Human

  finalize!
end