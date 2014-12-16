require 'rubyXL'

class XlsxDocWriter
  def initialize(filepath)
    self.doc = RubyXL::Workbook.new
    self.filepath = filepath
    self.doc.add_worksheet('Sheet1')
  end

  def add_array_as_column(array, column_index)
    sheet = self.doc.worksheets[0]
    array.each_with_index { |val,index | sheet.add_cell(index, column_index, val) }
  end

  def add_cell(row_index, column_index, val, sheet_index = 0)
    sheet = self.doc.worksheets[sheet_index]
    sheet.add_cell(row_index, column_index, val)
  end

  def add_row(row_index, cells)
    sheet = self.doc.worksheets[0]
    cells.each_with_index do |cell, index|
      sheet.add_cell(row_index, index, cell)
    end
    self.write_to_file
  end

  def write_to_file
    self.doc.write(filepath)
  end

  attr_accessor :doc, :filepath
end

