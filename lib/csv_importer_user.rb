# -*- coding: utf-8 -*-
module CsvImporterUser
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
    attributes
  rescue => e
    raise e
  end

  def self.builder(head)
    columns = { }

    indexes_attributes = head.collect do |col|
      case col
      when /ID.*/m
        f = lambda { |attributes, v| attributes.merge(:code => v) }
        columns[:code] ||= []
        columns[:code] << f
        f
      when /会社CD/m
      when /会社略称/m
      when /雇用区分/m
      when /^区分$/m
      when /役職名/m
      when /資格/m
      when /氏名/m
        f = lambda { |attributes, v| attributes.merge(:name => v.gsub("　", " ").gsub(/\s+/, "").toutf8) }
        columns[:name] ||= []
        columns[:name] << f
        f
      when /ﾌﾘｶﾞﾅ/m
        f = lambda { |attributes, v| attributes.merge(:kana => v.gsub("　", " ").gsub(/\s+/, "").toutf8) }
        columns[:kana] ||= []
        columns[:kana] << f
        f
      when /性別/m
      when /入社年月日/m
      when /部門CD/m
      when /区分CD/m
        columns[:division_code] ||= []
        case columns[:division_code].count
        when 0
          f = nil
        when 1
          f = lambda { |attributes, v|
            attributes.merge(:division_code => v)
          }
        else
          raise ArgumentError
        end
        columns[:division_code] << f
        f
      when /所属部門/m
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
