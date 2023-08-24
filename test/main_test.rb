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

  def test_base_fee
    fee = Fee.new(1000, 500, 800, 600, 400, 500)
    assert_equal 1000, fee.base_fee('adult')
    assert_equal 500, fee.base_fee('child')
    assert_equal 800, fee.base_fee('senior')
  end

  def test_base_fee_sp
    fee = Fee.new(1000, 500, 800, 600, 400, 500)
    assert_equal 600, fee.base_fee_sp('adult')
    assert_equal 400, fee.base_fee_sp('child')
    assert_equal 500, fee.base_fee_sp('senior')
  end

  def test_decide_fee
    ###################
    # 割引なしパターン
    ###################
    # 平日
    Time.stub(:now, Time.new(2023, 8, 22, 10, 0, 0)) do
      fee = Fee.new(1000, 500, 800, 600, 400, 500)
      # 大人（通常）
      assert_equal 1000, fee.decide_fee('adult', false)
      # 子供（通常）
      assert_equal 500, fee.decide_fee('child', false)
      # シニア（通常）
      assert_equal 800, fee.decide_fee('senior', false)
      # 大人（特別）
      assert_equal 600, fee.decide_fee('adult', true)
      # 子供（特別）
      assert_equal 400, fee.decide_fee('child', true)
      # シニア（特別）
      assert_equal 500, fee.decide_fee('senior', true)
    end

    ###################
    # 割引ありパターン
    ###################
    # ナイト割（仮）
    Time.stub(:now, Time.new(2023, 8, 22, 17, 0, 0)) do
      fee = Fee.new(1000, 500, 800, 600, 400, 500)
      # 大人（通常）
      assert_equal 900, fee.decide_fee('adult', false)
      # 子供（通常）
      assert_equal 400, fee.decide_fee('child', false)
      # シニア（通常）
      assert_equal 700, fee.decide_fee('senior', false)
      # 大人（特別）
      assert_equal 500, fee.decide_fee('adult', true)
      # 子供（特別）
      assert_equal 300, fee.decide_fee('child', true)
      # シニア（特別）
      assert_equal 400, fee.decide_fee('senior', true)
    end

    # 休日（土日）割増
    Time.stub(:now, Time.new(2023, 8, 20, 10, 0, 0)) do # 日曜日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)
      # 大人（通常）
      assert_equal 1200, fee.decide_fee('adult', false)
      # 子供（通常）
      assert_equal 700, fee.decide_fee('child', false)
      # シニア（通常）
      assert_equal 1000, fee.decide_fee('senior', false)
      # 大人（特別）
      assert_equal 800, fee.decide_fee('adult', true)
      # 子供（特別）
      assert_equal 600, fee.decide_fee('child', true)
      # シニア（特別）
      assert_equal 700, fee.decide_fee('senior', true)
    end

    # 月水割（仮）
    Time.stub(:now, Time.new(2023, 8, 23, 10, 0, 0)) do
      fee = Fee.new(1000, 500, 800, 600, 400, 500)
      # 大人（通常）
      assert_equal 900, fee.decide_fee('adult', false)
      # 子供（通常）
      assert_equal 400, fee.decide_fee('child', false)
      # シニア（通常）
      assert_equal 700, fee.decide_fee('senior', false)
      # 大人（特別）
      assert_equal 500, fee.decide_fee('adult', true)
      # 子供（特別）
      assert_equal 300, fee.decide_fee('child', true)
      # シニア（特別）
      assert_equal 400, fee.decide_fee('senior', true)
    end
  end

  def test_price_change_type
    # is_night == true
    Time.stub(:now, Time.new(2023, 8, 22, 17, 0, 0)) do
      fee = Fee.new(1000, 500, 800, 600, 400, 500)
      assert_equal 'night', fee.price_change_type
    end

    # is_holiday == true
    Time.stub(:now, Time.new(2023, 8, 20, 10, 0, 0)) do # 日曜日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)
      assert_equal 'holiday', fee.price_change_type
    end

    # is_wednesday == true
    Time.stub(:now, Time.new(2023, 8, 23, 10, 0, 0)) do # 水曜日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)
      assert_equal 'mon_wed', fee.price_change_type
    end

    # is_night == false && is_holiday == false && is_wednesday == false
    Time.stub(:now, Time.new(2023, 8, 22, 10, 0, 0)) do # 土日・月水以外の昼間
      fee = Fee.new(1000, 500, 800, 600, 400, 500)
      assert_equal 'nodiscount', fee.price_change_type
    end
  end

  # def test_calc_total_fee
  #   # 団体割引（仮）
  #   Time.stub(:now, Time.new(2023, 8, 22, 10, 0, 0)) do # 平日
  #     assert_equal 9000, calc_total_fee(10, 0, 0, 10000)
  #     assert_equal 5000, calc_total_fee(0, 10, 0, 5000) # 子供は 0.5 人換算なので団体割引にならない
  #     assert_equal 7200, calc_total_fee(0, 0, 10, 8000)
  #     assert_equal 13500, calc_total_fee(10, 10, 10, 15000)
  #   end

  #   # ナイト割（仮） -> 団体割引との併用は不可
  #   Time.stub(:now, Time.new(2023, 8, 22, 17, 0, 0)) do
  #     assert_equal 9000, calc_total_fee(10, 0, 0, 9000)
  #     assert_equal 4000, calc_total_fee(0, 10, 0, 4000)
  #     assert_equal 7000, calc_total_fee(0, 0, 10, 7000)
  #     assert_equal 13500, calc_total_fee(10, 10, 10, 13500)
  #   end

  #   # 休日（土日）割増 -> 団体割引との併用は不可
  #   Time.stub(:now, Time.new(2023, 8, 20, 10, 0, 0)) do # 日曜日
  #     assert_equal 12000, calc_total_fee(10, 0, 0, 12000)
  #     assert_equal 7000, calc_total_fee(0, 10, 0, 7000)
  #     assert_equal 10000, calc_total_fee(0, 0, 10, 10000)
  #     assert_equal 21000, calc_total_fee(10, 10, 10, 21000)
  #   end

  #   # 月水割（仮） -> 団体割引との併用は不可
  #   Time.stub(:now, Time.new(2023, 8, 23, 10, 0, 0)) do
  #     assert_equal 9000, calc_total_fee(10, 0, 0, 9000)
  #     assert_equal 4000, calc_total_fee(0, 10, 0, 4000)
  #     assert_equal 7000, calc_total_fee(0, 0, 10, 7000)
  #     assert_equal 13500, calc_total_fee(10, 10, 10, 13500)
  #   end
  # end
end
