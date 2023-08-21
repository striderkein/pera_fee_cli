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

  def test_decide_fee
    ###################
    # 割引なしパターン
    ###################
    # 平日
    Time.stub(:now, Time.new(2023, 8, 22, 10, 0, 0)) do
      # 大人（通常）
      assert_equal 1000, decide_fee('adult', false)
      # 子供（通常）
      assert_equal 500, decide_fee('child', false)
      # シニア（通常）
      assert_equal 800, decide_fee('senior', false)
      # 大人（特別）
      assert_equal 600, decide_fee('adult', true)
      # 子供（特別）
      assert_equal 400, decide_fee('child', true)
      # シニア（特別）
      assert_equal 500, decide_fee('senior', true)
    end

    ###################
    # 割引ありパターン
    ###################
    # ナイト割（仮）
    Time.stub(:now, Time.new(2023, 8, 22, 17, 0, 0)) do
      # 大人（通常）
      assert_equal 900, decide_fee('adult', false)
      # 子供（通常）
      assert_equal 400, decide_fee('child', false)
      # シニア（通常）
      assert_equal 700, decide_fee('senior', false)
      # 大人（特別）
      assert_equal 500, decide_fee('adult', true)
      # 子供（特別）
      assert_equal 300, decide_fee('child', true)
      # シニア（特別）
      assert_equal 400, decide_fee('senior', true)
    end

    # 月水割（仮）
    Time.stub(:now, Time.new(2023, 8, 23, 10, 0, 0)) do
      # 大人（通常）
      assert_equal 900, decide_fee('adult', false)
      # 子供（通常）
      assert_equal 400, decide_fee('child', false)
      # シニア（通常）
      assert_equal 700, decide_fee('senior', false)
      # 大人（特別）
      assert_equal 500, decide_fee('adult', true)
      # 子供（特別）
      assert_equal 300, decide_fee('child', true)
      # シニア（特別）
      assert_equal 400, decide_fee('senior', true)
    end
  end
end
