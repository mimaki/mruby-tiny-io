# File class

assert('File', "class") do
  File.class == Class
end

assert('File', 'Enumerable') do
  File.include?(Enumerable)
end

assert('File', 'superclass') do
  File.superclass == IO
end

assert('File', 'new: cannot open') do
  e = nil
  begin
    File.new('./cannot_open')
  rescue => e
  end
  e.class == IOError
end

assert('File', 'new') do
  File.new('./test')
  File.new('./dummy', 'w')
end

assert('File', 'open: cannot open') do
  e = nil
  begin
    File.open('./cannot_open')
  rescue => e
  end
  e.class == IOError
end

assert('File', 'open') do
  File.open('./test')
  File.open('./dummy', 'w')
end

assert('File', 'close') do
  File.open('./test').close == nil
end

assert('File', 'closed?') do
  f = File.open('./test')
  a = f.closed?
  f.close
  b = f.closed?
  !a && b
end

assert('File', 'write') do
  len = 0
  File.open('./temp', 'w') do |f|
    len = f.write('12345')
  end
  len == 5
end

assert('File', 'read') do
  t = 'abcdefghijklmnopqrstuvwxyz'
  s = ''
  File.open('./temp', 'w') {|f| f.write(t)}
  File.open('./temp', 'r') {|f| s = f.read}
  s == t
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
  s == t
end

assert('File', 'read: buf') do
  t = '1234567890'
  s = ''
  File.open('./temp', 'w') {|f| f.write(t)}
  File.open('./temp', 'r') {|f| f.read(100, s)}
  s == t
end

assert('File', '<< str') do
  t = 'abc'
  s = ''
  File.open('./temp', 'w') {|f| f << t}
  File.open('./temp', 'r') {|f| s = f.read}
  s == t
end

assert('File', '<< obj') do
  t = [1,2,3]
  s = ''
  File.open('./temp', 'w') {|f| f << t}
  File.open('./temp', 'r') {|f| s = f.read}
  s == t.to_s
end

assert('File', 'flush') do
  e = nil
  begin
    File.open('./temp', 'w') {|f|
      f.write '12345'
      f.flush
    }
  rescue => e
  end
  !e
end

assert('File', 'putc') do
  t = "abcdefghijklmnopqrstuvwxyz"
  s = ''
  File.open('./temp', 'w') {|f|
    t.each_char {|c| f.putc(c)}
  }
  File.open('./temp', 'r') {|f| s=f.read}
  s == t
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
  s == t
end

assert('File', 'print') do
  t = ['abc', 123, 4.56]
  s = ''
  File.open('./temp', 'w') {|f| f.print(t[0], t[1], t[2])}
  File.open('./temp', 'r') {|f| s = f.read}
  s == t.inject("") {|s, v| s += v.to_s}
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
  s == tt
end

# assert('File', 'printf') do
#   s = ''
#   File.open('./temp', 'w') {|f| f.printf("%d-%s", 123, 'ABC')}
#   File.open('./temp', 'w') {|f| s = f.read}
#   s == '123-ABC'
# end

assert('File', 'gets') do
  t = "123456789\n1234567890\nabcdefghijklmnopqrstuvwxyz\nABCDEFGHIJKLMNOPQRSTUVWXYZ"
  b = true
  File.open('./temp', 'w') {|f| f.write(t)}
  File.open('./temp', 'r') {|f|
    b &= (f.gets == "123456789\n")
    b &= (f.gets == "1234567890\n")
    b &= (f.gets == "abcdefghijklmnopqrstuvwxyz\n")
    b &= (f.gets == "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  }
  b
end

assert('File', 'gets(limit)') do
  t = "123456789\n1234567890\nabcdefghijklmnopqrstuvwxyz\nABCDEFGHIJKLMNOPQRSTUVWXYZ"
  b = true
  File.open('./temp', 'w') {|f| f.write(t)}
  File.open('./temp', 'r') {|f|
    b &= (f.gets(20) == "123456789\n")
    b &= (f.gets(20) == "1234567890\n")
    b &= (f.gets(20) == "abcdefghijklmnopqrs")
    b &= (f.gets(20) == "tuvwxyz\n")
    b &= (f.gets(20) == "ABCDEFGHIJKLMNOPQRS")
    b &= (f.gets(20) == "TUVWXYZ")
  }
  b
end

assert('File', 'tell/pos') do
  t = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  b = true
  p0,p1,p25,p26 = [],[],[],[]
  File.open('./temp', 'w') {|f| f.write(t)}
  File.open('./temp', 'r') {|f|
    b &= (f.tell == 0)
    b &= (f.pos  == 0)
    f.read(1)
    b &= (f.tell == 1)
    b &= (f.pos  == 1)
    f.read(24)
    b &= (f.tell == 25)
    b &= (f.pos  == 25)
    f.read(100)
    b &= (f.tell == 26)
    b &= (f.pos  == 26)
  }
  b
end

assert('File', 'seek: SEEK_SET') do
  t = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  b = true
  File.open('./temp', 'w') {|f|
    f.write(t)
    f.seek(0, IO::SEEK_SET)
    b &= (f.pos == 0)
    f.seek(10, IO::SEEK_SET)
    b &= (f.pos == 10)
    f.seek(26, IO::SEEK_SET)
    b &= (f.pos == 26)
    f.seek(100, IO::SEEK_SET)
    b &= (f.pos == 100)
    f.seek(0)
    b &= (f.pos == 0)
  }
  b
end

assert('File', 'seek: SEEK_CUR') do
  t = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  b = true
  File.open('./temp', 'w') {|f|
    f.write(t)
    f.seek(0, IO::SEEK_CUR)
    b &= (f.pos == 26)
    f.seek(-25, IO::SEEK_CUR)
    b &= (f.pos == 1)
    f.seek(-1, IO::SEEK_CUR)
    b &= (f.pos == 0)
    f.seek(100, IO::SEEK_CUR)
    b &= (f.pos == 100)
  }
  b
end

assert('File', 'seek: SEEK_END') do
  t = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  b = true
  File.open('./temp', 'w') {|f|
    f.write(t)
    f.seek(0, IO::SEEK_END)
    b &= (f.pos == 26)
    f.seek(-26, IO::SEEK_END)
    b &= (f.pos == 0)
    f.seek(-10, IO::SEEK_END)
    b &= (f.pos == 16)
    f.seek(100, IO::SEEK_END)
    b &= (f.pos == 126)
  }
  b
end

assert('File', 'pos=') do
  t = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  b = true
  File.open('./temp', 'w') {|f|
    f.write(t)
    f.pos = 0
    b &= (f.pos == 0)
    f.pos = 10
    b &= (f.pos == 10)
    f.pos = 26
    b &= (f.pos == 26)
    f.pos = 100
    b &= (f.pos == 100)
  }
  b
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
