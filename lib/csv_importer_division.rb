# -*- coding: utf-8 -*-
module CsvImporterDivision

  def self.read_csv(file)
    builder = nil
    head = true
    attributes = []
    CSV.parse(file.read.toutf8.gsub(/\r/, "")) do |row|
      if head
        builder = builder(row)
        head = false
      else
        attributes << builder.call(row)
      end
    end
    unify(attributes)
  rescue => e
    raise e
  end

  def self.unify(attributes)
    unified_attributes = attributes.inject({ }) do |unified_attributes, attribute|
      if unified_attributes[attribute[:convenience_code]]
        unified_attributes
      else
        unified_attributes.merge(attribute[:convenience_code] => attribute)
      end
    end
    unified_attributes.values.sort { |a, b| a[:convenience_code] <=> b[:convenience_code] }
  end

  def self.guess_parent_code(code)
    if code.to_s != (code = ((code.to_f * 0.1).truncate * 10.0).to_i.to_s)
      code
    elsif code.to_s != (code = ((code.to_f * 0.01).truncate * 100.0).to_i.to_s)
      code
    elsif code.to_s != (code = ((code.to_f * 0.001).truncate * 1000.0).to_i.to_s)
      code
    else
      code
    end
  end

  def self.guess_head_code(code)
    ((code.to_f * 0.001).truncate * 1000.0).to_i.to_s
  end

  def self.builder(head)
    columns = { }

    indexes_attributes = head.collect do |col|
      case col
      when /ID.*/m
      when /会社CD/m
      when /会社略称/m
      when /雇用区分/m
      when /^区分$/m
      when /役職名/m
      when /資格/m
      when /氏名/m
      when /ﾌﾘｶﾞﾅ/m
      when /性別/m
      when /入社年月日/m
      when /部門CD/m
        f = lambda { |attributes, v| attributes.merge(:fiscal_code => v) }
        columns[:fiscal_code] ||= []
        columns[:fiscal_code] << f
        f
      when /区分CD/m
        columns[:convenience_code] ||= []
        case columns[:convenience_code].count
        when 0
          f = lambda { |attributes, v|
            attributes.merge(:code => v)
          }
        when 1
          f = lambda { |attributes, v|
            attributes.merge(:convenience_code => v)
          }
        else
          raise ArgumentError
        end
        columns[:convenience_code] << f
        f
      when /所属部門/m
        f = lambda { |attributes, v| attributes.merge(:name => v) }
        columns[:name] ||= []
        columns[:name] << f
        f
      else
      end
    end

    indexes_attributes.flatten!

    lambda do |row|
      attributes = { }
      row.each_index do |i|
        proc = indexes_attributes[i]
        if proc
          attributes = proc.call(attributes, row[i]) || attributes
        end
      end
      attributes
    end
  end

end
