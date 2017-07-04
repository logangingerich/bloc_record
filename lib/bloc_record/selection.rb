require 'sqlite3'

module Selection
  def find(*ids)
    if ids.length == 0
      raise "No ids provided."
    elsif ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end
  end

  def find_one(id)
    if id <= 0
      raise "Not a valid ID"
    else
      row = connection.get_first_row <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id = #{id};
      SQL

      init_object_from_row(row)
    end
  end

  def find_by(attribute, value)
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
    SQL

    init_object_from_row(row)
  end

  def take(num=1)
    raise "Not a valid num_record" if num.is_a? String
    if num > 1
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY random()
        LIMIT #{num};
      SQL

      rows_to_array(rows)
    else
      take_one
    end
  end

  def take_one
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def first
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id
      ASC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id
      DESC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def all
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table};
    SQL

    rows_to_array(rows)
  end

  def find_each(*options)
    items = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{options.size} OFFSET #{options.start};
    SQL
    items.each do |item|
      yield init_object_from_row(item)
    end
  end

  def find_in_batches(options = {})
    items = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{options.size} OFFSET #{options.start};
    SQL

    if items.nil?
      nil
    else
      yield rows_to_array(items)
    end
  end

  private
  def init_object_from_row(row)
    if row
      data = Hash[columns.zip(row)]
      new(data)
    end
  end

  def rows_to_array(rows)
    rows.map { |row| new(Hash[columns.zip(row)]) }
  end

  def method_missing(m, *args, &block)
    if m.match(/find_by_/)
      name = m.to_s.split('find_by_')[1]
      if columns.include?(name)
        find_by(name, *args)
      else
        raise "#{name} is not a valid method."
      end
    end
  end
end
