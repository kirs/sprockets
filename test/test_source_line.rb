require "test_helper"

class SourceLineTest < Test::Unit::TestCase
  def test_line_that_begins_with_double_slash_should_be_a_comment
    assert source_line("//").comment?
    assert source_line("//test").comment?
    assert source_line("//= require").comment?
    assert source_line("//= require <foo>").comment?
    assert source_line(" //").comment?
    assert source_line("\t//").comment?
  end

  def test_line_that_begins_a_multiline_comment
    assert !source_line(" /*").begins_multiline_comment?
    assert source_line(" /**").begins_multiline_comment?
  end

  def test_line_that_closes_a_multiline_comment
    assert !source_line(" */").closes_multiline_comment?
    assert source_line(" **/").closes_multiline_comment?
  end

  def test_line_that_contains_but_does_not_begin_with_double_slash_should_not_be_a_comment
    assert !source_line("f //").comment?
    assert !source_line("f //= require <foo>").comment?
  end

  def test_comment_should_be_extracted_from_comment_lines
    assert_equal "test", source_line("//test").comment
    assert_equal " test", source_line("// test").comment
    assert_equal nil, source_line("f //test").comment
  end
  
  def test_line_that_contains_require_comment_should_be_a_require
    assert source_line("//= require <foo>").require?
    assert !source_line("//= require<foo>").require?
    assert source_line("//= require \"foo\"").require?
    assert !source_line("//= require <foo> f").require?
  end
  
  def test_require_should_be_extracted_from_require_lines
    assert_nil source_line("//= require").require
    assert_equal "<foo>", source_line("//= require <foo>").require
    assert_equal "<foo>", source_line("//= require   <foo> ").require
    assert_equal "\"foo\"", source_line("//= require \"foo\"").require
  end

  def test_inspect_should_include_source_file_location_and_line_number
    environment = environment_for_fixtures
    pathname    = Sprockets::Pathname.new(environment, "/a/b/c.js")
    source_file = Sprockets::SourceFile.new(environment, pathname)
    assert_equal "line 25 of /a/b/c.js", source_line("hello", source_file, 25).inspect
  end
end
