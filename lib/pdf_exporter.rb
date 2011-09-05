# -*- coding: utf-8 -*-

module PdfExporter
  def self.evaluation_results(filepath, args)
    Prawn::Document.generate(filepath) do
      max_page = args[:users].count
      page_count = 0

      args[:users].each do |arg|
        font File.join(Rails.root, "ipag00303", "ipag.ttf")

        define_grid(:columns => 2, :rows => 6, :gutter => 10)

        b0 = grid(0,0)
        b1 = grid(0,1)

        page_width = b1.right - b0.left

        bounding_box(b0.top_left, :width => page_width, :height => b0.height) do
          font_size(18) do
            text I18n.t('eval_result')
          end
          move_down(8)
          font_size(10) do
            table([
                   [I18n.t('period'), args[:evaluation_term]],
                   [I18n.t('affiliation'), arg[:division]],
                   [I18n.t('fullname'), arg[:name]],
                   [I18n.t('qualification'), arg[:qualification]],
                  ],
                  :column_widths => [page_width * 0.2, page_width * 0.6],
                  :cell_style => { :borders => [:bottom]}) do
              cells.style :padding => 3
            end
          end
        end

        b0 = grid(1,0)
        b1 = grid(2,1)

        bounding_box(b0.top_left, :width => page_width, :height => b0.height + b1.height) do
          font_size(14) do
            text I18n.t('topdown_eval_result')
          end
          move_down(8)
          font_size(8) do
            table([[I18n.t('category'), I18n.t('eval_item'), I18n.t('fixed_score')]].
                  concat(PdfExporter.format_topdown_result(arg[:topdown_results])).
                  concat([["", I18n.t('score_total'), arg[:topdown_total].to_s]]),
                  :column_widths => [page_width * 0.2, page_width *0.6, page_width * 0.2]) do
              cells.style :padding => 3
              row(0).style :background_color => "d3e8c1", :align => :center
              PdfExporter.rowspaning_borders(arg[:topdown_results]).each do |e|
                style(rows(e).columns(0..0)) { |cell| cell.borders = [:left] }
              end
              PdfExporter.rowspaning_end_borders(arg[:topdown_results]).each do |e|
                style(rows(e).columns(0..0)) { |cell| cell.borders = [:left, :bottom] }
              end
              lastln = PdfExporter.count_topdown_result_rows(arg[:topdown_results]) + 1
              style(row(lastln).columns(0..0)) { |cell| cell.borders = [:left, :bottom] }
              style(row(lastln).columns(1..1)) { |cell| cell.borders = [:bottom] }
              rows(1..lastln).column(2).style :align => :right
              rows(lastln).column(1).style :align => :right
            end
          end
        end

        b0 = grid(3,0)
        b1 = grid(3,1)

        bounding_box(b0.top_left, :width => page_width, :height => b0.height + b1.height) do
          font_size(14) do
            text I18n.t('multifaceted_eval_score')
          end
          move_down(8)
          font_size(8) do
            if arg[:multifaceted_evaluators_number].zero?
              text I18n.t('desc_eval_score')
            else
              text I18n.t(:multifaceted_evaluators_number, :multifaceted_evaluators_number => arg[:multifaceted_evaluators_number])
            end
          end
          move_down(8)
          font_size(8) do
            table([[I18n.t('eval_item'), I18n.t('fixed_score_avg')]].
                  concat(PdfExporter.format_multifaceted_result(arg[:multifaceted_results])).
                  concat([[I18n.t('score_total'), arg[:multifaceted_total].to_s]]),
                  :column_widths => [page_width * 0.3, page_width * 0.2]) do
              cells.style :padding => 3
              row(0).style :background_color => "d3e8c1", :align => :center
              lastln = arg[:multifaceted_results].count + 1
              rows(1..lastln).column(1).style :align => :right
              row(lastln).column(0).style :align => :right
            end
          end
        end

        b0 = grid(4,0)
        b1 = grid(4,1)

        bounding_box(b0.top_left, :width => page_width, :height => b0.height + b1.height) do
          font_size(14) do
            text I18n.t('overall_eval')
          end
          move_down(8)
          font_size(8) do
            text I18n.t(:eval_expression, :topdown_evaluation_weight => args[:topdown_evaluation_weight], :multifaceted_evaluation_weight => args[:multifaceted_evaluation_weight])
            text I18n.t('desc_weight')
          end
          move_down(8)
          font_size(6) do
            table([[I18n.t('rank'), I18n.t('overall_fixed_score')]].concat(PdfExporter.format_ranks), :column_widths => [page_width * 0.2, page_width * 0.2]) do
              cells.style :padding => 3
              row(0).style :background_color => "d3e8c1", :align => :center
              lastln = Rank.all.count + 1
              rows(1..lastln).column(0).style :align => :center
            end
          end
        end
        bounding_box(b1.top_left, :width => b1.width, :height => b0.height + b1.height) do
          move_down(52)
          page_width = b0.width
          font_size(10) do
            table([
                   [I18n.t('topdown_eval_perfect_score'), arg[:topdown_perfect].to_s],
                   [I18n.t('multifaceted_eval_perfect_score'), arg[:multifaceted_perfect].to_s],
                   [I18n.t('eval_score'), arg[:score].to_s],
                   [I18n.t('adjustment_point'), arg[:adjustment_value].to_s],
                  ],
                  :column_widths => [page_width * 0.6, page_width * 0.4]) do
              cells.style :padding => 3, :borders => [:bottom]
              column(1).style :align => :right
            end
          end
          move_down(22)
          font_size(12) do
            table([
                   ["#{I18n.t('overall_eval_point')}  :  ", arg[:adjusted_score].to_s],
                   ["#{I18n.t('overall_eval')}  :  ", arg[:rank].to_s],
                  ],
                  :column_widths => [page_width *0.6, page_width * 0.4]) do
              cells.style :padding => 3, :borders => [:bottom]
              column(1).style :align => :right
            end
          end
        end

        if page_count < max_page - 1
          start_new_page
        end

        page_count += 1
      end
    end
  end

  def self.format_topdown_result(topdown_results)
    topdown_results.inject([]) do |rtn, each_category|
      first = true
      each_category[:items].inject(rtn) do |rtn, each_item|
        if first
          first = false
          rtn << [each_category[:category], each_item[:item], each_item[:score].to_s]
        else
          rtn << ["", each_item[:item], each_item[:score].to_s]
        end
      end
    end
  end

  def self.count_topdown_result_rows(topdown_results)
    topdown_results.inject(0) do |n, each_category|
      each_category[:items].inject(n) do |n, each_item|
        n += 1
      end
    end
  end

  def self.format_multifaceted_result(multifaceted_results)
    multifaceted_results.collect do |each_item|
      [each_item[:item], each_item[:score].to_s]
    end
  end

  def self.format_ranks
    Rank.all.collect do |rank|
      [rank.name, rank.description]
    end
  end

  def self.rowspaning_borders(topdown_results)
    n = 0
    topdown_results.inject([]) do |rtn, each_category|
      count = each_category[:items].count
      if count > 1
        rtn << ((n + 1)..(n + count - 1))
      end
      n += count
      rtn
    end
  end

  def self.rowspaning_end_borders(topdown_results)
    n = 0
    topdown_results.inject([]) do |rtn, each_category|
      count = each_category[:items].count
      if count > 1
        ln = n + count
        rtn << (ln..ln)
      end
      n += count
      rtn
    end
  end
end
