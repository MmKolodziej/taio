require 'test/unit'
require 'simple_xlsx_reader'

class XlsxReaderTest < Test::Unit::TestCase
  TEST_FILE_PATH = '../jastrzebska/Native.xlsx'

  # Fake test
  def test_load
    doc = SimpleXlsxReader.open(TEST_FILE_PATH)
    sheet = doc.sheets.first
    puts sheet.rows[0]
  end
end