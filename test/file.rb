# File class

assert('File', "class") do
  assert_equal(Class, File.class)
end

assert('File', 'Enumerable') do
  assert_true(File.include?(Enumerable))
end

assert('File', 'superclass') do
  assert_equal(IO, File.superclass)
end

assert('File', 'new: cannot open') do
  assert_raise(IOError) {
    File.new('./cannot_open')
  }
end

assert('File', 'new') do
  assert_nothing_raised {
    File.new('./test')
    File.new('./dummy', 'w')
  }
end

assert('File', 'open: cannot open') do
  assert_raise(IOError) {
    File.open('./cannot_open')
  }
end

assert('File', 'open') do
  assert_nothing_raised {
    File.open('./test')
    File.open('./dummy', 'w')
  }
end

assert('File', 'close') do
  assert_nothing_raised {
    assert_nil(File.open('./test').close)
  }
end

assert('File', 'closed?') do
  f = File.open('./test')
  assert_false(f.closed?)
  f.close
  assert_true(f.closed?)
end

assert('File', 'write') do
  len = 0
  File.open('./temp', 'w') do |f|
    len = f.write('12345')
  end
  assert_equal(5, len)
end

assert('File', 'read') do
  t = 'abcdefghijklmnopqrstuvwxyz'
  s = ''
  File.open('./temp', 'w') {|f| f.write(t)}
  File.open('./temp', 'r') {|f| s = f.read}
  assert_equal(t, s)
end

assert('File', 'read: size') do
  t = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  s = ''
  File.open('./temp', 'w') {|f| f.write(t)}
  File.open('./temp', 'r') {|f|
    s = f.read(10)
    s += f.read(10)
    s += f.read(10)
  }
  assert_equal(t, s)
end

assert('File', 'read: buf') do
  t = '1234567890'
  s = ''
  File.open('./temp', 'w') {|f| f.write(t)}
  File.open('./temp', 'r') {|f| f.read(100, s)}
  assert_equal(t, s)
end

assert('File', '<< str') do
  t = 'abc'
  s = ''
  File.open('./temp', 'w') {|f| f << t}
  File.open('./temp', 'r') {|f| s = f.read}
  assert_equal(t, s)
end

assert('File', '<< obj') do
  t = [1,2,3]
  s = ''
  File.open('./temp', 'w') {|f| f << t}
  File.open('./temp', 'r') {|f| s = f.read}
  assert_equal(t.to_s, s)
end

assert('File', 'flush') do
  assert_nothing_raised {
    File.open('./temp', 'w') {|f|
      f.write '12345'
      f.flush
    }
  }
end

assert('File', 'putc') do
  t = "abcdefghijklmnopqrstuvwxyz"
  s = ''
  File.open('./temp', 'w') {|f|
    t.each_char {|c| f.putc(c)}
  }
  File.open('./temp', 'r') {|f| s=f.read}
  assert_equal(t, s)
end

assert('File', 'getc') do
  t = '1234567890'
  s = ''
  File.open('./temp', 'w') {|f| f.write(t)}
  File.open('./temp', 'r') {|f|
    while c = f.getc
      s += c
    end
  }
  assert_equal(t, s)
end

assert('File', 'print') do
  t = ['abc', 123, 4.56]
  s = ''
  File.open('./temp', 'w') {|f| f.print(t[0], t[1], t[2])}
  File.open('./temp', 'r') {|f| s = f.read}
  tt = t.inject("") {|s, v| s += v.to_s}
  assert_equal(tt, s)
end

assert('File', 'puts') do
  t = ['abc', 123, "ABC\n", 4.56]
  tt = ''
  t.each {|v|
    tt += v.to_s
    tt += "\n" unless (v.to_s)[-1] == "\n"
  }
  s = ''
  File.open('./temp', 'w') {|f| f.puts(t[0], t[1], t[2], t[3])}
  File.open('./temp', 'r') {|f| s = f.read}
  assert_equal(tt, s)
end

# assert('File', 'printf') do
#   s = ''
#   File.open('./temp', 'w') {|f| f.printf("%d-%s", 123, 'ABC')}
#   File.open('./temp', 'w') {|f| s = f.read}
#   s == '123-ABC'
# end

assert('File', 'gets') do
  t = "123456789\n1234567890\nabcdefghijklmnopqrstuvwxyz\nABCDEFGHIJKLMNOPQRSTUVWXYZ"
  File.open('./temp', 'w') {|f| f.write(t)}
  File.open('./temp', 'r') {|f|
    assert_equal("123456789\n", f.gets)
    assert_equal("1234567890\n", f.gets)
    assert_equal("abcdefghijklmnopqrstuvwxyz\n", f.gets)
    assert_equal("ABCDEFGHIJKLMNOPQRSTUVWXYZ", f.gets)
  }
end

assert('File', 'gets(limit)') do
  t = "123456789\n1234567890\nabcdefghijklmnopqrstuvwxyz\nABCDEFGHIJKLMNOPQRSTUVWXYZ"
  File.open('./temp', 'w') {|f| f.write(t)}
  File.open('./temp', 'r') {|f|
    assert_equal("123456789\n", f.gets(20))
    assert_equal("1234567890\n", f.gets(20))
    assert_equal("abcdefghijklmnopqrs", f.gets(20))
    assert_equal("tuvwxyz\n", f.gets(20))
    assert_equal("ABCDEFGHIJKLMNOPQRS", f.gets(20))
    assert_equal("TUVWXYZ", f.gets(20))
  }
end

assert('File', 'tell/pos') do
  t = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  p0,p1,p25,p26 = [],[],[],[]
  File.open('./temp', 'w') {|f| f.write(t)}
  File.open('./temp', 'r') {|f|
    assert_equal(0, f.tell)
    assert_equal(0, f.pos)
    f.read(1)
    assert_equal(1, f.tell)
    assert_equal(1, f.pos)
    f.read(24)
    assert_equal(25, f.tell)
    assert_equal(25, f.pos)
    f.read(100)
    assert_equal(26, f.tell)
    assert_equal(26, f.pos)
  }
end

assert('File', 'seek: SEEK_SET') do
  t = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  File.open('./temp', 'w') {|f|
    f.write(t)
    f.seek(0, IO::SEEK_SET)
    assert_equal(0, f.pos)
    f.seek(10, IO::SEEK_SET)
    assert_equal(10, f.pos)
    f.seek(26, IO::SEEK_SET)
    assert_equal(26, f.pos)
    f.seek(100, IO::SEEK_SET)
    assert_equal(100, f.pos)
    f.seek(0)
    assert_equal(0, f.pos)
  }
end

assert('File', 'seek: SEEK_CUR') do
  t = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  File.open('./temp', 'w') {|f|
    f.write(t)
    f.seek(0, IO::SEEK_CUR)
    assert_equal(26, f.pos)
    f.seek(-25, IO::SEEK_CUR)
    assert_equal(1, f.pos)
    f.seek(-1, IO::SEEK_CUR)
    assert_equal(0, f.pos)
    f.seek(100, IO::SEEK_CUR)
    assert_equal(100, f.pos)
  }
end

assert('File', 'seek: SEEK_END') do
  t = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  File.open('./temp', 'w') {|f|
    f.write(t)
    f.seek(0, IO::SEEK_END)
    assert_equal(26, f.pos)
    f.seek(-26, IO::SEEK_END)
    assert_equal(0, f.pos)
    f.seek(-10, IO::SEEK_END)
    assert_equal(16, f.pos)
    f.seek(100, IO::SEEK_END)
    assert_equal(126, f.pos)
  }
end

assert('File', 'pos=') do
  t = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  File.open('./temp', 'w') {|f|
    f.write(t)
    f.pos = 0
    assert_equal(0, f.pos)
    f.pos = 10
    assert_equal(10, f.pos)
    f.pos = 26
    assert_equal(26, f.pos)
    f.pos = 100
    assert_equal(100, f.pos)
  }
end

# assert('File', 'delete') do
#   f = ['./temp1', './temp2', './temp3', './temp4']
#   f.each {|f| File.open(f, 'w') {|f| f.write '123'}}
#   File.delete(f.shift, f.shift, f.shift, f.shift) == 4
# end
#
# assert('File', 'unlink') do
#   f = ['./temp5', './temp6', './temp7', './temp8']
#   f.each {|f| File.open(f, 'w') {|f| f.write 'abc'}}
#   File.unlink(f.shift, f.shift, f.shift, f.shift) == 4
# end
