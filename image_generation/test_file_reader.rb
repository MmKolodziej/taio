require 'csv'
require 'simple_xlsx_reader'

class TestFileReader
  def initialize(filepath)
    self.filepath = filepath
  end

  def read_lines
    case File.extname(filepath)
      when '.xlsx'
        read_excel
      when '.csv'
        read_csv
    end
  end

  private

  attr_accessor :filepath

  def read_csv
    CSV.read(filepath).map { |row| row.map(&:to_f) }
  end

  def read_excel
    doc = SimpleXlsxReader.open(filepath)
    sheet = doc.sheets.first
    sheet.rows.map { |row| row.map(&:to_f) }
  end
end