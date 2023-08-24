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
    fee = Fee.new(1000, 500, 800, 600, 400, 500)
    ###################
    # 割引なしパターン
    ###################
    # 平日
    Time.stub(:now, Time.new(2023, 8, 22, 10, 0, 0)) do
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
    fee = Fee.new(1000, 500, 800, 600, 400, 500)

    # is_night == true
    Time.stub(:now, Time.new(2023, 8, 22, 17, 0, 0)) do
      assert_equal 'night', fee.price_change_type
    end

    # is_holiday == true
    Time.stub(:now, Time.new(2023, 8, 20, 10, 0, 0)) do # 日曜日
      assert_equal 'holiday', fee.price_change_type
    end

    # is_wednesday == true
    Time.stub(:now, Time.new(2023, 8, 23, 10, 0, 0)) do # 水曜日
      assert_equal 'mon_wed', fee.price_change_type
    end

    # is_night == false && is_holiday == false && is_wednesday == false
    Time.stub(:now, Time.new(2023, 8, 22, 10, 0, 0)) do # 土日・月水以外の昼間
      assert_equal 'nodiscount', fee.price_change_type
    end
  end

  def test_total_visitors
    fee = Fee.new(1000, 500, 800, 600, 400, 500)

    admission = Admission.new(10, 0, 0, 0, 0, 0, fee)
    assert_equal 10, admission.total_visitors()

    admission = Admission.new(0, 10, 0, 0, 0, 0, fee)
    assert_equal 10, admission.total_visitors()

    admission = Admission.new(0, 0, 10, 0, 0, 0, fee)
    assert_equal 10, admission.total_visitors()

    admission = Admission.new(10, 10, 10, 0, 0, 0, fee)
    assert_equal 30, admission.total_visitors()
  end

  def test_visitors_for_group_discount
    fee = Fee.new(1000, 500, 800, 600, 400, 500)

    admission = Admission.new(10, 0, 0, 0, 0, 0, fee)
    assert_equal 10, admission.total_visitors_for_group_discount()

    admission = Admission.new(0, 10, 0, 0, 0, 0, fee)
    assert_equal 5, admission.total_visitors_for_group_discount()

    admission = Admission.new(0, 0, 10, 0, 0, 0, fee)
    assert_equal 10, admission.total_visitors_for_group_discount()

    admission = Admission.new(5, 2, 4, 0, 0, 0, fee)
    assert_equal 10, admission.total_visitors_for_group_discount()

    admission = Admission.new(5, 2, 4, 2, 1, 2, fee)
    assert_equal 10, admission.total_visitors_for_group_discount()
  end

  def test_total_normal_visitors
    fee = Fee.new(1000, 500, 800, 600, 400, 500)

    admission = Admission.new(10, 0, 0, 0, 0, 0, fee)
    assert_equal 10, admission.total_normal_visitors(nil)

    admission = Admission.new(0, 10, 0, 0, 0, 0, fee)
    assert_equal 10, admission.total_normal_visitors(nil)

    admission = Admission.new(0, 0, 10, 0, 0, 0, fee)
    assert_equal 10, admission.total_normal_visitors(nil)

    admission = Admission.new(5, 2, 4, 0, 0, 0, fee)
    assert_equal 11, admission.total_normal_visitors(nil)

    admission = Admission.new(5, 2, 4, 2, 1, 2, fee)
    assert_equal 6, admission.total_normal_visitors(nil)
  end

  def test_total_normal_visitors_formatted
    fee = Fee.new(1000, 500, 800, 600, 400, 500)

    admission = Admission.new(10, 0, 0, 0, 0, 0, fee)
    assert_equal '        10 名様', admission.total_normal_visitors_formatted(nil)

    admission = Admission.new(5, 2, 4, 2, 1, 2, fee)
    assert_equal '         6 名様', admission.total_normal_visitors_formatted(nil)
  end

  def test_total_special_visitors
    fee = Fee.new(1000, 500, 800, 600, 400, 500)

    admission = Admission.new(10, 0, 0, 0, 0, 0, fee)
    assert_equal 0, admission.total_special_visitors(nil)
    admission = Admission.new(0, 10, 0, 0, 0, 0, fee)
    assert_equal 0, admission.total_special_visitors(nil)
    admission = Admission.new(0, 0, 10, 0, 0, 0, fee)
    assert_equal 0, admission.total_special_visitors(nil)
    admission = Admission.new(5, 2, 4, 0, 0, 0, fee)
    assert_equal 0, admission.total_special_visitors(nil)
    admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
    assert_equal 3, admission.total_special_visitors('adult')
    addmission = Admission.new(5, 2, 4, 3, 1, 2, fee)
    assert_equal 1, admission.total_special_visitors('child')
    admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
    assert_equal 2, admission.total_special_visitors('senior')
  end

  def test_total_special_visitors_formatted
    fee = Fee.new(1000, 500, 800, 600, 400, 500)

    admission = Admission.new(10, 0, 0, 0, 0, 0, fee)
    assert_equal '         0 名様', admission.total_special_visitors_formatted(nil)
    admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
    assert_equal '         3 名様', admission.total_special_visitors_formatted('adult')
    admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
    assert_equal '         1 名様', admission.total_special_visitors_formatted('child')
    admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
    assert_equal '         2 名様', admission.total_special_visitors_formatted('senior')
  end

  def test_total_fee_normal
    # 平日昼間
    Time.stub(:now, Time.new(2023, 8, 22, 10, 0, 0)) do # 平日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      admission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal 9000, admission.total_fee_normal(nil)
      admission = Admission.new(0, 2, 0, 0, 0, 0, fee)
      assert_equal 1000, admission.total_fee_normal(nil)
      admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
      assert_equal 4100, admission.total_fee_normal(nil)
      admission = Admission.new(5, 2, 4, 3, 2, 1, fee)
      assert_equal 4400, admission.total_fee_normal(nil)
    end

    # 月水土日以外の夜間
    Time.stub(:now, Time.new(2023, 8, 22, 17, 0, 0)) do # 平日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      admission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal 8100, admission.total_fee_normal(nil)
      admission = Admission.new(0, 2, 0, 0, 0, 0, fee)
      assert_equal 800, admission.total_fee_normal(nil)
      admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
      assert_equal 3600, admission.total_fee_normal(nil)
      admission = Admission.new(5, 2, 4, 3, 2, 1, fee)
      assert_equal 3900, admission.total_fee_normal(nil)
    end

    # 土日・祝日の昼間
    Time.stub(:now, Time.new(2023, 8, 20, 10, 0, 0)) do # 日曜日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      addmission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal 10800, addmission.total_fee_normal(nil)
      addmission = Admission.new(0, 2, 0, 0, 0, 0, fee)
      assert_equal 1400, addmission.total_fee_normal(nil)
      addmission = Admission.new(5, 2, 4, 3, 1, 2, fee)
      assert_equal 5100, addmission.total_fee_normal(nil)
      addmission = Admission.new(5, 2, 4, 3, 2, 1, fee)
      assert_equal 5400, addmission.total_fee_normal(nil)
    end

    # 土日・祝日の夜間
    Time.stub(:now, Time.new(2023, 8, 20, 17, 0, 0)) do # 日曜日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      admission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal 8100, admission.total_fee_normal(nil)
      admission = Admission.new(0, 2, 0, 0, 0, 0, fee)
      assert_equal 800, admission.total_fee_normal(nil)
      admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
      assert_equal 3600, admission.total_fee_normal(nil)
      admission = Admission.new(5, 2, 4, 3, 2, 1, fee)
      assert_equal 3900, admission.total_fee_normal(nil)
    end
  end

  def test_total_fee_special
    # 平日昼間
    Time.stub(:now, Time.new(2023, 8, 22, 10, 0, 0)) do # 平日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      admission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal 0, admission.total_fee_special('adult')
      admission = Admission.new(0, 2, 0, 0, 0, 0, fee)
      assert_equal 0, admission.total_fee_special(nil)
      admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
      assert_equal 3200, admission.total_fee_special(nil)
      admission = Admission.new(5, 2, 4, 3, 2, 1, fee)
      assert_equal 3100, admission.total_fee_special(nil)
    end

    # 月水土日以外の夜間
    Time.stub(:now, Time.new(2023, 8, 22, 17, 0, 0)) do # 平日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      admission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal 0, admission.total_fee_special(nil)
      admission = Admission.new(0, 2, 0, 0, 0, 0, fee)
      assert_equal 0, admission.total_fee_special(nil)
      admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
      assert_equal 2600, admission.total_fee_special(nil)
      admission = Admission.new(5, 2, 4, 3, 2, 1, fee)
      assert_equal 2500, admission.total_fee_special(nil)
    end

    # 土日・祝日の昼間
    Time.stub(:now, Time.new(2023, 8, 20, 10, 0, 0)) do # 日曜日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      addmission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal 0, addmission.total_fee_special(nil)
      addmission = Admission.new(0, 2, 0, 0, 0, 0, fee)
      assert_equal 0, addmission.total_fee_special(nil)
      addmission = Admission.new(5, 2, 4, 3, 1, 2, fee)
      assert_equal 4400, addmission.total_fee_special(nil)
      addmission = Admission.new(5, 2, 4, 3, 2, 1, fee)
      assert_equal 4300, addmission.total_fee_special(nil)
    end

    # 土日・祝日の夜間
    Time.stub(:now, Time.new(2023, 8, 20, 17, 0, 0)) do # 日曜日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      admission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal 0, admission.total_fee_special(nil)
      admission = Admission.new(0, 2, 0, 0, 0, 0, fee)
      assert_equal 0, admission.total_fee_special(nil)
      admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
      assert_equal 2600, admission.total_fee_special(nil)
      admission = Admission.new(5, 2, 4, 3, 2, 1, fee)
      assert_equal 2500, admission.total_fee_special(nil)
    end
  end

  def test_total_change_amount
    # 平日昼間
    Time.stub(:now, Time.new(2023, 8, 22, 10, 0, 0)) do # 平日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      admission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal 0, admission.total_change_amount(nil)
      admission = Admission.new(0, 2, 0, 0, 0, 0, fee)
      assert_equal 0, admission.total_change_amount(nil)
      admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
      assert_equal 730, admission.total_change_amount(nil)
      admission = Admission.new(5, 2, 4, 3, 2, 1, fee)
      assert_equal 750, admission.total_change_amount(nil)
    end

    # 月水土日以外の夜間
    Time.stub(:now, Time.new(2023, 8, 22, 17, 0, 0)) do # 平日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      admission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal 2700, admission.total_change_amount(nil)
      admission = Admission.new(0, 2, 0, 0, 0, 0, fee)
      assert_equal 600, admission.total_change_amount(nil)
      admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
      assert_equal 3300, admission.total_change_amount(nil)
      admission = Admission.new(5, 2, 4, 3, 2, 1, fee)
      assert_equal 3300, admission.total_change_amount(nil)
    end

    # 土日・祝日の昼間
    Time.stub(:now, Time.new(2023, 8, 20, 10, 0, 0)) do # 日曜日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      addmission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal -5400, addmission.total_change_amount(nil)
      addmission = Admission.new(0, 2, 0, 0, 0, 0, fee)
      assert_equal -1200, addmission.total_change_amount(nil)
      addmission = Admission.new(5, 2, 4, 3, 1, 2, fee)
      assert_equal -6600, addmission.total_change_amount(nil)
      addmission = Admission.new(5, 2, 4, 3, 2, 1, fee)
      assert_equal -6600, addmission.total_change_amount(nil)
    end

    # 土日・祝日の夜間
    Time.stub(:now, Time.new(2023, 8, 20, 17, 0, 0)) do # 日曜日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      admission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal 2700, admission.total_change_amount(nil)
      admission = Admission.new(0, 2, 0, 0, 0, 0, fee)
      assert_equal 600, admission.total_change_amount(nil)
      admission = Admission.new(5, 2, 4, 3, 1, 2, fee)
      assert_equal 3300, admission.total_change_amount(nil)
      admission = Admission.new(5, 2, 4, 3, 2, 1, fee)
      assert_equal 3300, admission.total_change_amount(nil)
    end

    # 平日昼間（団体割引）
    Time.stub(:now, Time.new(2023, 8, 22, 10, 0, 0)) do # 平日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      admission = Admission.new(10, 0, 0, 0, 0, 0, fee)
      assert_equal 1000, admission.total_change_amount('group')
      admission = Admission.new(0, 10, 0, 0, 0, 0, fee)
      assert_equal 0, admission.total_change_amount('group')
      admission = Admission.new(0, 0, 10, 0, 0, 0, fee)
      assert_equal 800, admission.total_change_amount('group')
      admission = Admission.new(10, 10, 10, 0, 0, 0, fee)
      assert_equal 2300, admission.total_change_amount('group')
    end
  end

  def test_total_discount_amount_formatted
    # 平日昼間
    Time.stub(:now, Time.new(2023, 8, 22, 10, 0, 0)) do # 平日
      fee = Fee.new(1000, 500, 800, 600, 400, 500)

      admission = Admission.new(9, 0, 0, 0, 0, 0, fee)
      assert_equal '￥     0', admission.total_discount_amount_formatted('adult')
      admission = Admission.new(0, 10, 0, 0, 0, 0, fee)
      assert_equal '￥     0', admission.total_discount_amount_formatted('child')
      admission = Admission.new(0, 0, 9, 0, 0, 0, fee)
      assert_equal '￥     0', admission.total_discount_amount_formatted('senior')
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
