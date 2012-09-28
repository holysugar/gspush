require 'gspush'

describe Gspush do
  let(:url) { 'http://example.com/ '} # FIXME
  let(:gspush) { Gspush.new(url) }

  describe "#push" do
    it "append gspush.lines" do
      expect { gspush.push "values 999" }.to change{ gspush.lines.size }.by(1)
    end
  end

  describe "#parse_lines" do
    before do
      gspush.push "foo 123"
      gspush.push "bar 456"
      gspush.push "baz 789"
    end

    subject { gspush.parse_lines }
    it { should == [['foo', '123'], ['bar', '456'], ['baz', '789']] }

    context 'with prepend_timestamp option' do
      let(:gspush) { Gspush.new(url, :prepend_timestamp => true) }
      specify "time prepended" do
        subject[0][0].should match(/\d{4}-\d\d-\d\d \d\d:\d\d:\d\d/)
      end
    end
  end

  describe "#save" do
    it "update spreadsheet"
  end

  describe "separate" do
    context "without delimiter option" do
      it "separates in blank" do
        gspush.separate("0 bar,1 baz").should == ["0", "bar,1", "baz"]
      end
    end
    context "with delimiter option" do
      let(:gspush) { Gspush.new(url, :delimiter => ",") }
      it "separates in given delimter" do
        gspush.separate("0 bar,1 baz").should == ["0 bar", "1 baz"]
      end
    end
  end
end
