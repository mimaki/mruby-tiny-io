# IO class

assert('IO', "class") do
  IO.class == Class
end

assert('IO', 'Enumerable') do
  IO.include?(Enumerable)
end

assert('IO', 'constants') do
  IO::SEEK_SET == 0 &&
  IO::SEEK_CUR == 1 &&
  IO::SEEK_END == 2
end

assert('IOError', 'superclass') do
  IOError.superclass == StandardError
end
