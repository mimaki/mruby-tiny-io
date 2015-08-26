#include <stdio.h>
#include <string.h>
#include "mruby.h"
#include "mruby/variable.h"
#include "mruby/class.h"
#include "mruby/data.h"
#include "mruby/string.h"
#include "mruby/array.h"

#define READ_BUF_SIZE 256
#define E_IO_ERROR (mrb_class_get(mrb, "IOError"))

static void
mrb_file_free(mrb_state *mrb, void *ptr)
{
  if (ptr) fclose((FILE*)ptr);
}

const static struct mrb_data_type mrb_file_type = {"File", mrb_file_free};

// /*
//  *  call-seq:
//  *     File.delete(*files)  # => Fixnum
//  *     File.unlink(*files)  # => Fixnum
//  *
//  *  Delete files.
//  *
//  *  Parameters:
//  *    +files+   File names to delete.
//  *
//  *  Returns number of deleted files.
//  */
// static mrb_value
// mrb_file_delete(mrb_state *mrb, mrb_value self)
// {
//   mrb_value *files;
//   mrb_int i, len;
//
//   mrb_get_args(mrb, "*", &files, &len);
//
//   for (i=0; i<len; i++) {
//     if (!mrb_string_p(files[i])) {
//       mrb_raise(mrb, E_TYPE_ERROR, "File name error.");
//     }
//     if (remove(mrb_str_to_cstr(mrb, files[i])) != 0) {
//       mrb_raise(mrb, E_IO_ERROR, "File delete error.");
//     }
//   }
//
//   return mrb_fixnum_value(len);
// }

MRB_API void
mrb_file_attach(mrb_value self, FILE *fp)
{
  DATA_TYPE(self) = &mrb_file_type;
  DATA_PTR(self) = fp;
}

/*
 *  call-seq:
 *     File.new(path, mode='r')  # => File
 *
 *  Opens a file indicated by filename.
 *
 *  Parameters:
 *    +path+    File name.
 *    +mode+    file access mode.
 *      'r'       Open a file for reading. (read from start)
 *      'w'       Create a file for writing. (destroy contents)
 *      'a'       Append to a file. (write to end)
 *      'r+'      Open a file for read/write. (read from start)
 *      'w+'      Create a file for read/write. (destroy contents)
 *      'a+'      Open a file for read/write. (write to end)
 *
 *  Returns File object.
 */
static mrb_value
mrb_file_init(mrb_state *mrb, mrb_value self)
{
  char *name;
  char *mode = "r";
  mrb_int perm = 0666;
  FILE *fp;

  mrb_get_args(mrb, "z|zi", &name, &mode, &perm);

  // DATA_TYPE(self) = &mrb_file_type;
  // DATA_PTR(self) = fopen(name, mode);
  fp = fopen(name, mode);
  if (fp == NULL) {
    mrb_raisef(mrb, E_IO_ERROR, "File cannot open. (%S)", mrb_str_new_cstr(mrb, name));
  }
  mrb_file_attach(self, fp);

  return self;
}

/*
 *  call-seq:
 *     file.close  # => nil
 *
 *  close file.
 *
 *  Parameters: none
 *
 *  Returns nil.
 */
static mrb_value
mrb_file_close(mrb_state *mrb, mrb_value self)
{
  mrb_file_free(mrb, DATA_PTR(self));
  DATA_PTR(self) = NULL;
  return mrb_nil_value();
}

/*
 *  call-seq:
 *     file.closed?  # => true | false
 *
 *  Check file is closed.
 *
 *  Parameters: none
 *
 *  Returns true or false.
 */
static mrb_value
mrb_file_is_closed(mrb_state *mrb, mrb_value self)
{
  return mrb_bool_value(DATA_PTR(self) == NULL);
}

/*
 *  call-seq:
 *     file.read(len=nil, buf="")  # => nil
 *
 *  Read data from file.
 *
 *  Parameters:
 *    +len+     Read data length.
 *      nil       Read until EOF.
 *    +buf+     Read buffer.
 *
 *  Returns nil.
 */
static mrb_value
mrb_file_read(mrb_state *mrb, mrb_value self)
{
  FILE *fp = (FILE*)DATA_PTR(self);
  mrb_value olen = mrb_nil_value();
  mrb_value buf = mrb_str_new_cstr(mrb, "");
  mrb_int len;

  if (fp == NULL) {
    mrb_raise(mrb, E_IO_ERROR, "File read error.");
  }

  mrb_get_args(mrb, "|oS", &olen, &buf);

  if (mrb_nil_p(olen)) {
    long cur, end;
    cur = ftell(fp);
    fseek(fp, 0, SEEK_END);
    end = ftell(fp);
    fseek(fp, cur, SEEK_SET);
    len = (mrb_int)(end - cur);
  }
  else {
    len = mrb_fixnum(olen);
  }

  mrb_str_resize(mrb, buf, len);

  len = fread(RSTRING_PTR(buf), 1, len, fp);

  if (len > 0) {
    mrb_str_resize(mrb, buf, len);
    return buf;
  }
  return mrb_nil_value();
}

/*
 *  call-seq:
 *     file.write(s)  # => Fixnum
 *
 *  Write data to file.
 *
 *  Parameters:
 *    +s+       data for write.
 *
 *  Returns lengh of written.
 */
static mrb_value
mrb_file_write(mrb_state *mrb, mrb_value self)
{
  FILE *fp = (FILE*)DATA_PTR(self);
  mrb_value str;
  mrb_int len;

  if (fp == NULL) {
    mrb_raise(mrb, E_IO_ERROR, "File write error.");
  }

  mrb_get_args(mrb, "S", &str);
  len = fwrite(RSTRING_PTR(str), 1, RSTRING_LEN(str), fp);
  if (len < RSTRING_LEN(str)) {
    mrb_raise(mrb, E_IO_ERROR, "File write error.");
  }

  return mrb_fixnum_value(len);
}

/*
 *  call-seq:
 *     file.flush  # => self
 *
 *  Flush to file.
 *
 *  Parameters: none
 *
 *  Returns self.
 */
static mrb_value
mrb_file_flush(mrb_state *mrb, mrb_value self)
{
  FILE *fp = (FILE*)DATA_PTR(self);

  if (fp == NULL) {
    mrb_raise(mrb, E_IO_ERROR, "File access error.");
  }
  fflush(fp);

  return self;
}

/*
 *  call-seq:
 *     file.gets(limit=0)  # => String | nil
 *
 *  Get one line from file.
 *
 *  Parameters:
 *    +limit+   Maximum data length of line.
 *      0         Read until "\n" or EOF.
 *
 *  Returns read line data.
 */
static mrb_value
mrb_file_gets(mrb_state *mrb, mrb_value self)
{
  FILE *fp = (FILE*)DATA_PTR(self);
  mrb_int lim = 0;
  mrb_value s;

  if (fp == NULL) {
    mrb_raise(mrb, E_IO_ERROR, "File read error.");
  }

  mrb_get_args(mrb, "|i", &lim);

  if (lim > 0) {
    s = mrb_str_buf_new(mrb, lim);
    if (fgets(RSTRING_PTR(s), lim, fp) == NULL) {
      return mrb_nil_value();
    }
    mrb_str_resize(mrb, s, strlen(RSTRING_PTR(s)));
  }
  else {
    mrb_value buf = mrb_str_buf_new(mrb, READ_BUF_SIZE);
    char *p;
    s = mrb_str_new_cstr(mrb, "");

    while (fgets(RSTRING_PTR(buf), READ_BUF_SIZE, fp) != NULL) {
      mrb_str_resize(mrb, buf, strlen(RSTRING_PTR(buf)));
      mrb_str_cat_str(mrb, s, buf);
      p = RSTRING_PTR(s);
      if (p[strlen(p) - 1] == '\n') {
        return s;
      }
    }
    if (RSTRING_LEN(s) == 0) {
      return mrb_nil_value();
    }
  }
  return s;
}

/*
 *  call-seq:
 *     file.tell  # => Fixnum
 *     file.pos   # => Fixnum
 *
 *  Get position of file pointer.
 *
 *  Parameters: none
 *
 *  Returns position of file pointer.
 */
static mrb_value
mrb_file_tell(mrb_state *mrb, mrb_value self)
{
  FILE *fp = (FILE*)DATA_PTR(self);
  long pos;

  if (fp == NULL) {
    mrb_raise(mrb, E_IO_ERROR, "File access error.");
  }
  pos = ftell(fp);
  return mrb_fixnum_value((mrb_int)pos);
}

/*
 *  call-seq:
 *     file.seek(offset, whence=IO::SEEK_SET)  # => 0
 *
 *  Reposition a file-position indicator in a file.
 *
 *  Parameters:
 *    +offset+  number of bytes to shift the position relative to whence
 *    +whence+  position to which offset is added.
 *      IO::SEEK_SET    seeking from beginning of the file
 *      IO::SEEK_CUR    seeking from the current file position
 *      IO::SEEK_END    seeking from end of the file
 *
 *  Returns 0.
 */
static mrb_value
mrb_file_seek(mrb_state *mrb, mrb_value self)
{
  FILE *fp = (FILE*)DATA_PTR(self);
  mrb_int pos;
  mrb_int whence = SEEK_SET;

  if (fp == NULL) {
    mrb_raise(mrb, E_IO_ERROR, "File access error.");
  }

  mrb_get_args(mrb, "i|i", &pos, &whence);
  fseek(fp, pos, whence);

  return mrb_fixnum_value(0);
}

void
mrb_mruby_tiny_io_gem_init(mrb_state *mrb)
{
  struct RClass *io;
  struct RClass *file;

  /* IO class */
  io = mrb_define_class(mrb, "IO", mrb->object_class);
  mrb_include_module(mrb, io, mrb_module_get(mrb, "Enumerable"));

  /* constants */
  mrb_define_const(mrb, io, "SEEK_SET", mrb_fixnum_value(SEEK_SET));
  mrb_define_const(mrb, io, "SEEK_CUR", mrb_fixnum_value(SEEK_CUR));
  mrb_define_const(mrb, io, "SEEK_END", mrb_fixnum_value(SEEK_END));

  /* File class */
  file = mrb_define_class(mrb, "File", io);
  MRB_SET_INSTANCE_TT(file, MRB_TT_DATA);

  // mrb_define_class_method(mrb, file, "delete",  mrb_file_delete,  MRB_ARGS_ANY());
  // mrb_define_class_method(mrb, file, "unlink",  mrb_file_delete,  MRB_ARGS_ANY());

  mrb_define_method(mrb, file, "initialize",  mrb_file_init,      MRB_ARGS_ARG(1, 2));
  mrb_define_method(mrb, file, "close",       mrb_file_close,     MRB_ARGS_NONE());
  mrb_define_method(mrb, file, "closed?",     mrb_file_is_closed, MRB_ARGS_NONE());
  mrb_define_method(mrb, file, "read",        mrb_file_read,      MRB_ARGS_OPT(2));
  mrb_define_method(mrb, file, "write",       mrb_file_write,     MRB_ARGS_REQ(1));
  mrb_define_method(mrb, file, "flush",       mrb_file_flush,     MRB_ARGS_NONE());
  mrb_define_method(mrb, file, "gets",        mrb_file_gets,      MRB_ARGS_OPT(1));
  mrb_define_method(mrb, file, "pos",         mrb_file_tell,      MRB_ARGS_NONE());
  mrb_define_method(mrb, file, "tell",        mrb_file_tell,      MRB_ARGS_NONE());
  mrb_define_method(mrb, file, "seek",        mrb_file_seek,      MRB_ARGS_ARG(1, 1));
}

void
mrb_mruby_tiny_io_gem_final(mrb_state *mrb)
{
}
