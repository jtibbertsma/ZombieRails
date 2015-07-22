require_relative 'db_connection'
require_relative 'searchable'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  extend Searchable
  extend Associatable

  def self.convert_hash(hash)
    hash.each_with_object({}) do |(key, value), new_hash|
      new_hash[key.to_sym] = value
    end
  end

  def self.columns
    DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    .first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |name|
      define_method(name) do
        attributes[name]
      end

      define_method("#{name}=") do |value|
        attributes[name] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map { |hash| new(convert_hash(hash)) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id: id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = :id
    SQL
    parse_all(results).first
  end

  def self.max_id
    DBConnection.execute(<<-SQL)
      SELECT
        MAX(id)
      FROM
        #{table_name}
    SQL
    .first.values.first
  end

  def self.insert_values
    "(#{columns.map(&:inspect).join(', ')})"
  end

  def self.insert_into_string
    "#{table_name} (#{columns.join(', ')})"
  end

  def self.update_values
    cols = columns
    cols.delete(:id)

    cols.map { |symbol| "#{symbol.to_s} = #{symbol.inspect}" }
    .join(', ')
  end

  def initialize(params = {})
    params.each_key do |key|
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(key)
    end

    attributes.merge!(params)
  end

  def attributes
    if @attributes.nil?
      @attributes = {}
      self.class.columns.each { |key| @attributes[key] = nil }
    end

    @attributes
  end

  def attribute_values
    attributes.values
  end

  def insert
    attributes[:id] ||= self.class.max_id + 1
    DBConnection.execute(<<-SQL, attributes)
      INSERT INTO
        #{self.class.insert_into_string}
      VALUES
        #{self.class.insert_values}
    SQL
    self
  end

  def update
    params = attributes
    params.delete(:id)

    DBConnection.execute(<<-SQL, params)
      UPDATE
        #{self.class.table_name}
      SET
        #{self.class.update_values}
    SQL
    self
  end

  def save
    if attributes[:id]
      update
    else
      insert
    end
  end
end
