module Finders
  
  DEFAULT_LIMIT = 25

  def raw_query(query_array) 
    sanitized_query = ActiveRecord::Base.send(:sanitize_sql_array, query_array)
    ActiveRecord::Base.connection.execute(sanitized_query)
  end

  def raw_query_flat(query_array)
    (raw_query query_array).entries.flatten
  end

  def raw_query_value(query_array)
    raw_query(query_array).entries.flatten[0]
  end
end

ActiveRecord::Base.extend(Finders)