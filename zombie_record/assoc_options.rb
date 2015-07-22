class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end

  def primary_key_default
    :id
  end

  def class_name_default(name)
    name.to_s.singularize.titleize
  end

  def foreign_key_default(name)
    (name.to_s.underscore + "_id").to_sym
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    self.foreign_key = options[:foreign_key] || foreign_key_default(name)
    self.class_name  = options[:class_name]  || class_name_default(name)
    self.primary_key = options[:primary_key] || primary_key_default
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self.foreign_key = options[:foreign_key] || foreign_key_default(self_class_name)
    self.class_name  = options[:class_name]  || class_name_default(name)
    self.primary_key = options[:primary_key] || primary_key_default
  end
end