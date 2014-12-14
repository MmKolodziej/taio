require 'test/unit'
require 'simple_xlsx_reader'
require 'rubyXL'

class XlsxOperationsTest < Test::Unit::TestCase
  def test_simple_xlsx_reader
    filepath = 'test_data/read_test_file.xlsx'
    doc = SimpleXlsxReader.open(filepath)
    sheet = doc.sheets.first
    assert_not_nil(sheet.rows[0])
  end

  def test_ruby_xl_reader
    filepath = 'test_data/write_test_file.xlsx'
    File.delete(filepath) if File.exists?(filepath)

    doc = RubyXL::Workbook.new
    doc.add_worksheet('Sheet1')
    sheet = doc.worksheets[0]
    sheet.add_cell(0, 0, 'A1')
    doc.write(filepath)
    assert_equal(true, File.exists?(filepath))
    
    File.delete(filepath) if File.exists?(filepath)
  end
end