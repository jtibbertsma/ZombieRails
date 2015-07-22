require_relative '../zombie_record/sqlobject.rb'

class Cat < SQLObject
  belongs_to :owner, class_name: :Human
  has_one_through :home, :owner, :house

  finalize!
end