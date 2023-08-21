require 'minitest/autorun'
require_relative '../main'

class MainTest < Minitest::Test
  def test_is_number
    assert_equal false, is_number('a')
    assert_equal true, is_number('1')
  end

  def test_is_number_with_float
    assert_equal false, is_number('1.1')
  end

  def test_is_number_with_minus
    assert_equal false, is_number('-1')
  end

  def test_is_number_with_empty
    assert_equal false, is_number('')
  end
end
