require_relative 'assoc_options'

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method name do
      item = send(options.foreign_key) || 'NULL'
      results = DBConnection.execute(<<-SQL)
        SELECT
          t2.*
        FROM
          #{self.class.table_name} t1
        INNER JOIN
          #{options.table_name} t2
        ON
          t1.#{options.foreign_key} = t2.#{options.primary_key}
        WHERE
          #{item} = t2.#{options.primary_key}
      SQL
      options.model_class.parse_all(results).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method name do
      results = DBConnection.execute(<<-SQL)
        SELECT
          t1.*
        FROM
          #{options.model_class.table_name} t1
        INNER JOIN
          #{self.class.table_name} t2
        ON
          t2.#{options.primary_key} = t1.#{options.foreign_key}
        WHERE
          t2.#{options.primary_key} = #{send(options.primary_key)}
      SQL
      options.model_class.parse_all(results)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]
    define_method name do
      item = self.send(through_options.foreign_key)
      source_options = through_options.model_class.assoc_options[source_name]
      results = DBConnection.execute(<<-SQL, item)
        SELECT
          t1.*
        FROM
          #{source_options.table_name} t1
        INNER JOIN
          #{through_options.table_name} t2
        ON
          t1.#{source_options.primary_key} = t2.#{through_options.primary_key}
        WHERE
          t2.#{through_options.primary_key} = ?
      SQL
      source_options.model_class.parse_all(results).first
    end
  end
end