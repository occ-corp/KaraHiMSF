# -*- coding: utf-8 -*-

require 'spec_helper'

describe CsvImporterDivision do
  describe ".read" do
    before :each do
      @file = Object.new
      @file.stub(:read) { <<-EOS }
"ID№","会社CD","会社略称","雇用区分","区分","役職名","資格","氏名","ﾌﾘｶﾞﾅ","性別","入社年月日","部門CD","区分CD","区分CD","所属部門"
344,1,"本社","社員","管理職","本部長","E1","岩道光","ｲﾜﾐﾁ ﾋｶﾙ","男",S60.4.1,1000,1000,1000,"営業戦略部"
285,1,"本社","社員","管理職","部長","E3","坂白香代子","ｻｶｼﾞﾛ ｶﾖｺ","男",S57.4.6,1000,1200,1200,"営業戦略部販売促進"
513,1,"本社","社員","管理職","ｴｷｽﾊﾟｰﾄ","E3","牛塚国廣","ｳｼﾂﾞｶ ｸﾆﾋﾛ","男",H2.4.2,1000,1200,1200,"営業戦略部販売促進"
581,1,"本社","社員","管理職","ｴｷｽﾊﾟｰﾄ","E3","上運天嘉則","ｳｴｳﾝﾃﾝ ｶｽﾞﾉﾘ","男",H6.4.1,1000,1200,1200,"営業戦略部販売促進"
EOS
      @attributes = CsvImporterDivision.read_csv(@file)
    end

    it "should returns Array object" do
      @attributes.should be_a_kind_of(Array)
    end

    it "should returns unified attributes" do
      @attributes.select { |attribute| attribute[:name] == "営業戦略部販売促進".toutf8 }.count.should equal(1)
    end
  end

  describe ".guess_parent_code" do
    it "guesses parent division code from sub sub sub division code" do
      CsvImporterDivision.guess_parent_code("2111").should == "2110"
    end

    it "guesses parent division code from sub sub division code" do
      CsvImporterDivision.guess_parent_code("2110").should == "2100"
    end

    it "guesses parent division code from sub division code" do
      CsvImporterDivision.guess_parent_code("2100").should == "2000"
    end

    it "guesses parent division code from head division code" do
      CsvImporterDivision.guess_parent_code("2000").should == "2000"
    end
  end


  describe ".guess_head_code" do
    it "returns head division code from sub sub sub division code" do
      CsvImporterDivision.guess_head_code("2111").should == "2000"
    end

    it "returns head division code from sub sub division code" do
      CsvImporterDivision.guess_head_code("2110").should == "2000"
    end

    it "guesses head division code from sub division code" do
      CsvImporterDivision.guess_head_code("2100").should == "2000"
    end

    it "guesses head division code from head division code" do
      CsvImporterDivision.guess_head_code("2000").should == "2000"
    end
  end

  describe ".builder" do
    before :each do
      @columns = ["ID№","会社CD","会社略称","雇用区分","区分","役職名","資格","氏名","ﾌﾘｶﾞﾅ","性別","入社年月日","部門CD","区分CD","区分CD","所属部門"]
      @builder = CsvImporterDivision.builder(@columns)
    end

    it "should returns Proc object" do
      @builder.should be_a_kind_of(Proc)
    end

    describe "returns Proc" do
      it "should read a csv row and return division attributes" do
        row = ["344","1","本社","社員","管理職","本部長","E1","岩道光","ｲﾜﾐﾁ ﾋｶﾙ","男","S60.4.1","1000","1100","1111","営業戦略部"]
        attributes = @builder.call row
        attributes[:name].should == "営業戦略部"
        attributes[:fiscal_code].should == "1000"
        attributes[:code].should == "1100"
        attributes[:convenience_code].should == "1111"
      end
    end

  end

end
