class Range
  # Public: Convert both ends of range to integers.
  def to_i_range
    self.begin.to_i..self.end.to_i
  end

  # Public: Convert both ends of range to times.
  def to_time_range
    Time.at(self.begin)..Time.at(self.end)
  end

  def int_range?
    self.begin.is_a?(Integer)
  end

  # Public: Check if range elements are times.
  def time_range?
    self.begin.is_a?(Time)
  end

  # Public: Calculate the differentce between ends of the range.
  def difference
    self.end - self.begin
  end

  # Public: Make up a range for previous n periods.
  # Start of new range would be start of current - difference between
  # start and end * number of periods, end of new range would be start of
  # current.
  #
  # Example
  #
  #   (1200..1300).previous
  #   # => 1100..1200
  def previous(n = 1)
    new_begin = self.begin - difference * n
    new_end = self.end - difference * n
    new_begin..new_end
  end

  def -(what)
    (self.begin - what)..(self.end - what)
  end
end