# IO class

assert('IO', "class") do
  assert_equal(Class, IO.class)
end

assert('IO', 'Enumerable') do
  assert_true(IO.include?(Enumerable))
end

assert('IO', 'constants') do
  assert_equal(0, IO::SEEK_SET)
  assert_equal(1, IO::SEEK_CUR)
  assert_equal(2, IO::SEEK_END)
end

assert('IOError', 'superclass') do
  assert_equal(StandardError, IOError.superclass)
end
