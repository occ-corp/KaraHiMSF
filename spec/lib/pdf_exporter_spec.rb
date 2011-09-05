# -*- coding: utf-8 -*-

require 'spec_helper'

describe PdfExporter do
  describe ".format_topdown_result" do
    it "returns expected one" do
      result = PdfExporter.format_topdown_result([
                                                  {
                                                    :category => "あいうえお",
                                                    :items => [
                                                               {:item => "こうもく1", :score => 1.0},
                                                               {:item => "こうもく2", :score => 2.0},
                                                              ]
                                                  },
                                                  {
                                                    :category => "かきくけこ",
                                                    :items => [
                                                               {:item => "こうもく1", :score => 1.0},
                                                               {:item => "こうもく2", :score => 2.0},
                                                               {:item => "こうもく3", :score => 3.0},
                                                              ]
                                                  },
                                                 ])
      expected = [
                  ["あいうえお", "こうもく1", "1.0"],
                  ["", "こうもく2", "2.0"],
                  ["かきくけこ", "こうもく1", "1.0"],
                  ["", "こうもく2", "2.0"],
                  ["", "こうもく3", "3.0"],
                 ]
      result.should == expected
    end
  end

  describe ".rowspaning_borders" do
    it "returns expected one" do
      PdfExporter.rowspaning_borders([
                                          {
                                            :category => "あいうえお",
                                            :items => [
                                                       {:item => "こうもく1", :score => 1.0},
                                                      ]
                                          },
                                          {
                                            :category => "かきくけこ",
                                            :items => [
                                                       {:item => "こうもく1", :score => 1.0},
                                                       {:item => "こうもく2", :score => 2.0},
                                                      ]
                                          },
                                          {
                                            :category => "さしすせそ",
                                            :items => [
                                                       {:item => "こうもく1", :score => 1.0},
                                                       {:item => "こうもく2", :score => 2.0},
                                                       {:item => "こうもく3", :score => 3.0},
                                                      ]
                                          },
                                         ]).should == [2..2, 4..5]
    end
  end

  describe ".rowspaning_end_borders" do
    it "returns expected one" do
      PdfExporter.rowspaning_end_borders([
                                           {
                                             :category => "あいうえお",
                                             :items => [
                                                        {:item => "こうもく1", :score => 1.0},
                                                       ]
                                           },
                                           {
                                             :category => "かきくけこ",
                                             :items => [
                                                        {:item => "こうもく1", :score => 1.0},
                                                        {:item => "こうもく2", :score => 2.0},
                                                       ]
                                           },
                                           {
                                             :category => "さしすせそ",
                                             :items => [
                                                        {:item => "こうもく1", :score => 1.0},
                                                        {:item => "こうもく2", :score => 2.0},
                                                        {:item => "こうもく3", :score => 3.0},
                                                       ]
                                           },
                                          ]).should == [3..3, 6..6]
    end
  end

  describe ".count_topdown_result_rows" do
    it "returns expected one" do
      PdfExporter.count_topdown_result_rows([
                           {
                             :category => "あいうえお",
                             :items => [
                                        {:item => "こうもく1", :score => 1.0},
                                        {:item => "こうもく2", :score => 2.0},
                                       ]
                           },
                           {
                             :category => "かきくけこ",
                             :items => [
                                        {:item => "こうもく1", :score => 1.0},
                                        {:item => "こうもく2", :score => 2.0},
                                        {:item => "こうもく3", :score => 3.0},
                                       ]
                           },
                          ]).should equal(5)
    end
  end

  describe ".evaluation_results" do
    it "generates a PDF file" do
      args = [
              {
                :name => "あいうえお",
                :division => "あいうえお",
                :qualification => "あいうえお",
                :topdown_results => [
                                     {
                                       :category => "あいうえお",
                                       :items => [
                                                  {:item => "こうもく1", :score => 1.0},
                                                  {:item => "こうもく2", :score => 2.0},
                                                 ]
                                     },
                                     {
                                       :category => "かきくけこ",
                                       :items => [
                                                  {:item => "こうもく1", :score => 1.0},
                                                  {:item => "こうもく2", :score => 2.0},
                                                 ]
                                     },
                                    ],
                :topdown_total => 1.0,
                :multifaceted_results => [
                                          {:item => "こうもく1", :score => 1.0},
                                          {:item => "こうもく2", :score => 2.0},
                                          {:item => "こうもく3", :score => 3.0},
                                         ],
                :multifaceted_total => 1.0,
                :topdown_perfect => 1.0,
                :multifaceted_perfect => 1.0,
                :score => 1.0,
                :adjustment_value => 1.0,
                :adjusted_score => 1.0,
                :rank => "A",
                :multifaceted_evaluators_number => 3,
              },
             ]
      filepath = File.join(Rails.root, "tmp", "generate_a_pdf_file.pdf")
      PdfExporter.evaluation_results filepath,
      :evaluation_term => "111 - 111",
      :topdown_evaluation_weight => 0.85,
      :multifaceted_evaluation_weight => 1.5,
      :users => args
      pending "PDF file has been SUCCESSFULLY generated. You can see that at #{filepath}"
    end

    it "corresponds to a case that an evaluatee does not have the multifaceted results" do
      args = [
              {
                :name => "あいうえお",
                :division => "あいうえお",
                :qualification => "あいうえお",
                :topdown_results => [
                                     {
                                       :category => "あいうえお",
                                       :items => [
                                                  {:item => "こうもく1", :score => 1.0},
                                                  {:item => "こうもく2", :score => 2.0},
                                                 ]
                                     },
                                     {
                                       :category => "かきくけこ",
                                       :items => [
                                                  {:item => "こうもく1", :score => 1.0},
                                                  {:item => "こうもく2", :score => 2.0},
                                                  {:item => "こうもく3", :score => 3.0},
                                                 ]
                                     },
                                    ],
                :topdown_total => 1.0,
                :multifaceted_results => [
                                          {:item => "こうもく1", :score => "-"},
                                          {:item => "こうもく2", :score => "-"},
                                          {:item => "こうもく3", :score => "-"},
                                         ],
                :multifaceted_total => 1.0,
                :topdown_perfect => 1.0,
                :multifaceted_perfect => 1.0,
                :score => 1.0,
                :adjustment_value => 1.0,
                :adjusted_score => 1.0,
                :rank => "A",
                :multifaceted_evaluators_number => 0,
              },
             ]
      filepath = File.join(Rails.root, "tmp", "corresponds_to_a_case_that_an_evaluatee_does_not_have_the_multifaceted_results.pdf")
      PdfExporter.evaluation_results filepath,
      :evaluation_term => "111 - 111",
      :topdown_evaluation_weight => 0.85,
      :multifaceted_evaluation_weight => 1.5,
      :users => args
      pending "PDF file has been SUCCESSFULLY generated. You can see that at #{filepath}"
    end

    it "corresponds to multiple pages" do
      args = [
              {
                :name => "てすと1",
                :division => "てすと1",
                :qualification => "てすと1",
                :topdown_results => [
                                     {
                                       :category => "あいうえお",
                                       :items => [
                                                  {:item => "こうもく1", :score => 1.0},
                                                  {:item => "こうもく2", :score => 2.0},
                                                 ]
                                     },
                                     {
                                       :category => "かきくけこ",
                                       :items => [
                                                  {:item => "こうもく1", :score => 1.0},
                                                  {:item => "こうもく2", :score => 2.0},
                                                 ]
                                     },
                                    ],
                :topdown_total => 1.0,
                :multifaceted_results => [
                                          {:item => "こうもく1", :score => 1.0},
                                          {:item => "こうもく2", :score => 2.0},
                                          {:item => "こうもく3", :score => 3.0},
                                         ],
                :multifaceted_total => 1.0,
                :topdown_perfect => 1.0,
                :multifaceted_perfect => 1.0,
                :score => 1.0,
                :adjustment_value => 1.0,
                :adjusted_score => 1.0,
                :rank => "A",
                :multifaceted_evaluators_number => 3,
              },
              {
                :name => "てすと2",
                :division => "てすと2",
                :qualification => "てすと2",
                :topdown_results => [
                                     {
                                       :category => "あいうえお",
                                       :items => [
                                                  {:item => "こうもく1", :score => 1.0},
                                                  {:item => "こうもく2", :score => 2.0},
                                                 ]
                                     },
                                     {
                                       :category => "かきくけこ",
                                       :items => [
                                                  {:item => "こうもく1", :score => 1.0},
                                                  {:item => "こうもく2", :score => 2.0},
                                                 ]
                                     },
                                    ],
                :topdown_total => 1.0,
                :multifaceted_results => [
                                          {:item => "こうもく1", :score => 1.0},
                                          {:item => "こうもく2", :score => 2.0},
                                          {:item => "こうもく3", :score => 3.0},
                                         ],
                :multifaceted_total => 1.0,
                :topdown_perfect => 1.0,
                :multifaceted_perfect => 1.0,
                :score => 1.0,
                :adjustment_value => 1.0,
                :adjusted_score => 1.0,
                :rank => "A",
                :multifaceted_evaluators_number => 3,
              }
             ]
      filepath = File.join(Rails.root, "tmp", "corresponds_to_multiple_pages.pdf")
      PdfExporter.evaluation_results filepath,
      :evaluation_term => "111 - 111",
      :topdown_evaluation_weight => 0.85,
      :multifaceted_evaluation_weight => 1.5,
      :users => args
      pending "PDF file has been SUCCESSFULLY generated. You can see that at #{filepath}"
    end

  end

end
