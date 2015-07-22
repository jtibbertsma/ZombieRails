module Searchable
  def fragment_for_where
    <<-SQL
      SELECT
        *
      FROM
        #{table_name}
      WHERE
    SQL
  end

  def where(params)
    where_clause = params.keys.map { |key| "#{key} = ?" }.join(' AND ')
    results = DBConnection.execute(fragment_for_where + where_clause + "\n", params.values)
    parse_all(results)
  end
end