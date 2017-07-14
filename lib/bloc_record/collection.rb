module BlocRecord
  class Collection < Array
    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def destroy_all
      ids = self.map(&:id)
      if self.any?
        ids.each do |id|
          self.first.class.destroy(id)
        end
      else
        false
      end
    end

    def take(lim=1)
      if self.any?
        self[0...lim]
      else
        nil
      end
    end

    def where(*args)
      if args.count > 1
        expression = args.shift
        params = args
      else
        case args.first
        when String
          expression = args.first
        when Hash
          expression_hash = BlocRecord::Utility.convert_keys(args.first)
          expression = expression_hash.map {|key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")
        end
      end

      self.any? ? self.first.class.where(expression) : false
      #Within scope of Where
      def not(arg)
        expression_hash = BlocRecord::Utility.convert_keys(arg)
        key = expression_hash.keys.first
        value = expression_hash[key]

        sql = <<-SQL
          SELECT #{columns.join ","} FROM #{table}
          WHERE #{key} != #{value};
        SQL

        rows = connection.execute(sql, params)
        rows_to_array(rows)
      end
    end

  end
end
