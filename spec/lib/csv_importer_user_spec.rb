# -*- coding: utf-8 -*-

require 'spec_helper'

describe CsvImporterUser do
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
      @attributes = CsvImporterUser.read_csv(@file)
    end

    it "should returns Array object" do
      @attributes.should be_a_kind_of(Array)
    end
  end

  describe ".builder" do
    before :each do
      @columns = ["ID№","会社CD","会社略称","雇用区分","区分","役職名","資格","氏名","ﾌﾘｶﾞﾅ","性別","入社年月日","部門CD","区分CD","区分CD","所属部門"]
      @builder = CsvImporterUser.builder(@columns)
    end

    it "should returns Proc object" do
      @builder.should be_a_kind_of(Proc)
    end

    describe "returns Proc" do
      it "should read a csv row and return division attributes" do
        row = ["344","1","本社","社員","管理職","本部長","E1","岩道光","ｲﾜﾐﾁ ﾋｶﾙ","男","S60.4.1","1000","1100","1111","営業戦略部"]
        attributes = @builder.call row
        attributes[:code].should == "344"
        attributes[:name].should == "岩道光"
        attributes[:kana].should == "イワミチヒカル"
        attributes[:division_code].should == "1111"
      end
    end
  end

  # describe ".validate_uniquness_of_code" do
  #   before :each do
  #     @attributes = [{:code => "123", :name => "test1"}, {:code => "123", :name => "test2"}]
  #   end

  #   it "raises an exception if duplicated code exists" do
  #     lambda { CsvImporterUser.validate_uniquness_of_code(@attributes) }.should raise_error(RuntimeError)
  #   end
  # end

end
