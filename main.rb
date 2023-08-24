# TODO: JSON ファイルを読み込む
$base_fee_adult = 1000
$base_fee_child = 500
$base_fee_senior = 800
$base_fee_adult_sp = 600
$base_fee_child_sp = 400
$base_fee_senior_sp = 500
$group_discount_rate = 0.9

class Fee
  attr_accessor :base_adult, :base_child, :base_senior, :base_adult_sp, :base_child_sp, :base_senior_sp, :adult_decided, :child_decided, :senior_decided, :adult_sp_decided, :child_sp_decided, :senior_sp_decided, :price_change_type
  def initialize(fee_adult, fee_child, fee_senior, fee_adult_sp, fee_child_sp, fee_senior_sp)
    @base_adult = fee_adult.to_i
    @base_child = fee_child.to_i
    @base_senior = fee_senior.to_i
    @base_adult_sp = fee_adult_sp.to_i
    @base_child_sp = fee_child_sp.to_i
    @base_senior_sp = fee_senior_sp.to_i
    @adult_decided = decide_fee('adult', false).to_i
    @child_decided = decide_fee('child', false).to_i
    @senior_decided = decide_fee('seinior', false).to_i
    @adult_sp_decided = decide_fee('adult', true).to_i
    @child_sp_decided = decide_fee('child', true).to_i
    @senior_sp_decided = decide_fee('senior', true).to_i
    @price_change_type = price_change_type()
  end

  def base_fee(age_type)
    return age_type == 'adult' ? $base_fee_adult : age_type == 'child' ? $base_fee_child : $base_fee_senior
  end

  def base_fee_sp(age_type)
    return age_type == 'adult' ? $base_fee_adult_sp : age_type == 'child' ? $base_fee_child_sp : $base_fee_senior_sp
  end

  def decide_fee(age_type, is_special)
    discount_amount_mon_wed = 100
    discount_amount_night = 100
    increase_amount_holiday = 200
    fee = is_special ? base_fee_sp(age_type) : base_fee(age_type)

    type = price_change_type()
    if type == 'holiday' then
      return fee + increase_amount_holiday
    elsif type == 'mon_wed' then
      return fee - discount_amount_mon_wed
    elsif type == 'night' then
      return fee - discount_amount_night
    else
      return fee
    end
  end

  def price_change_type()
    is_night = Time.now.hour >= 17
    is_holiday = Time.now.wday == 0 || Time.now.wday == 6
    is_mon_wed = Time.now.wday == 1 || Time.now.wday == 3

    if is_night then
      return 'night'
    elsif is_holiday then
      return 'holiday'
    elsif is_mon_wed then
      return 'mon_wed'
    else
      return 'nodiscount'
    end
  end
end

# 「入場」という単位で、入場者の人数および入場料金を管理するクラス
class Admission
  attr_accessor :number_of_visitor_adult,
    :number_of_visitor_child,
    :number_of_visitor_senior,
    :number_of_coupon_adult,
    :number_of_coupon_child,
    :number_of_coupon_senior,
    :fee,
    :total_fee,
    :total_visitors,
    :total_normal_visitors,
    :total_special_visitors,
    :base_fee_total,
    :raw_fee_total

  def initialize(number_of_visitor_adult, number_of_visitor_child, number_of_visitor_senior, number_of_coupon_adult, number_of_coupon_child, number_of_coupon_senior, fee)
    @number_of_visitor_adult = number_of_visitor_adult
    @number_of_visitor_child = number_of_visitor_child
    @number_of_visitor_senior = number_of_visitor_senior
    @number_of_coupon_adult = number_of_coupon_adult
    @number_of_coupon_child = number_of_coupon_child
    @number_of_coupon_senior = number_of_coupon_senior
    @fee = fee
  end

  # @reuurn [Integer] 入場者の総合計人数
  def total_visitors()
    return number_of_visitor_adult + number_of_visitor_child + number_of_visitor_senior
  end

  # @reuurn [Integer] 団体割引適用の根拠とするための総合計人数（子供を 0.5 人とカウント）
  def total_visitors_for_group_discount()
    # 仕様: 団体割引 → 10人以上で10%割引（子供は 0.5 人換算とする）
    # 上記を計算するため「子供は 0.5 人」と換算した人数を（総合計人数とは別に）計算する
    return number_of_visitor_adult.to_i + number_of_visitor_child.to_i / 2 + number_of_visitor_senior.to_i
  end

  def total_normal_visitors(age_type)
    if age_type == 'adult' then
      return number_of_visitor_adult - number_of_coupon_adult
    elsif age_type == 'child' then
      return number_of_visitor_child - number_of_coupon_child
    elsif age_type == 'senior' then
      return number_of_visitor_senior - number_of_coupon_senior
    end
    return number_of_visitor_adult + number_of_visitor_child + number_of_visitor_senior - (number_of_coupon_adult + number_of_coupon_child + number_of_coupon_senior)
  end

  def total_normal_visitors_formatted(age_type)
    return "#{self.total_normal_visitors(age_type).to_s.rjust(10)} 名様"
  end

  def total_special_visitors(age_type)
    if age_type == "adult" then
      return number_of_coupon_adult
    elsif age_type == "child" then
      return number_of_coupon_child
    elsif age_type == "senior" then
      return number_of_coupon_senior
    end
    return number_of_coupon_adult + number_of_coupon_child + number_of_coupon_senior
  end

  def total_special_visitors_formatted(age_type)
    return "#{self.total_special_visitors(age_type).to_s.rjust(10)} 名様"
  end

  def total_fee_normal(age_type)
    total_normal = self.total_normal_visitors(age_type)
    if age_type == 'adult' then
      return fee.adult_decided * total_normal
    elsif age_type == 'child' then
      return fee.child_decided * total_normal
    elsif age_type == 'senior' then
      return fee.senior_decided * total_normal
    end
    return fee.adult_decided * self.total_normal_visitors('adult') + fee.child_decided * self.total_normal_visitors('child') + fee.senior_decided * self.total_normal_visitors('senior')
  end

  def total_fee_special(age_type)
    if age_type == 'adult' then
      return fee.adult_sp_decided * self.total_special_visitors(age_type)
    elsif age_type == 'child' then
      return fee.child_sp_decided * self.total_special_visitors(age_type)
    elsif age_type == 'senior' then
      return fee.senior_sp_decided * self.total_special_visitors(age_type)
    end
    return fee.adult_sp_decided * self.total_special_visitors('adult') + fee.child_sp_decided * self.total_special_visitors('child') + fee.senior_sp_decided * self.total_special_visitors('senior')
  end

  def total_change_amount(age_type)
    normal = self.total_normal_visitors(age_type)
    special = self.total_special_visitors(age_type)
    if self.is_group_discount() then
      return self.raw_fee_total(age_type) - self.raw_fee_total(age_type) * $group_discount_rate
    end

    if age_type == 'adult' then
      return (normal * fee.base_adult + special * fee.base_adult_sp) - (normal * fee.adult_decided + special * fee.adult_sp_decided)
    elsif age_type == 'child' then
      return (normal * fee.base_child + special * fee.base_child_sp) - (normal * fee.child_decided + special * fee.child_sp_decided)
    elsif age_type == 'senior' then
      return (normal * fee.base_senior + special * fee.base_senior_sp) - (normal * fee.senior_decided + special * fee.senior_sp_decided)
    end
    return (normal * fee.base_adult + special * fee.base_adult_sp) - (normal * fee.adult_decided + special * fee.adult_sp_decided) + (normal * fee.base_child + special * fee.base_child_sp) - (normal * fee.child_decided + special * fee.child_sp_decided) + (normal * fee.base_senior + special * fee.base_senior_sp) - (normal * fee.senior_decided + special * fee.senior_sp_decided)
  end

  def total_discount_amount_formatted(age_type)
    total_change = self.total_change_amount(age_type).to_i
    if total_change > 0 then
      return "￥#{total_change.to_s.rjust(6)}"
    end
    return "￥#{'0'.rjust(6)}"
  end

  def total_surcharge_amount_formatted(age_type)
    total_change = self.total_change_amount(age_type)
    if total_change < 0 then
      return "￥#{(total_change *= -1).to_s.rjust(6)}"
    end
    return "￥#{'0'.rjust(6)}"
  end

  def base_fee_total()
    return (number_of_visitor_adult - number_of_coupon_adult) * fee.base_adult+
      (number_of_visitor_child - number_of_coupon_child) * fee.base_child +
      (number_of_visitor_senior - number_of_coupon_senior) * fee.base_senior +
      number_of_coupon_adult * fee.base_adult_sp +
      number_of_coupon_child * fee.base_child_sp +
      number_of_coupon_senior * fee.base_senior_sp
  end

  def raw_fee_total(age_type)
    # 「入力された数値」×「チケット料金」で…
    # 割引前料金の合計を計算
    raw_fee_adult = (number_of_visitor_adult - number_of_coupon_adult) * fee.adult_decided + number_of_coupon_adult * fee.adult_sp_decided
    raw_fee_child = (number_of_visitor_child - number_of_coupon_child) * fee.child_decided + number_of_coupon_child * fee.child_sp_decided
    raw_fee_senior = (number_of_visitor_senior - number_of_coupon_senior) * fee.senior_decided + number_of_coupon_senior * fee.senior_sp_decided
    if age_type == 'adult' then
      return raw_fee_adult
    elsif age_type == 'child' then
      return raw_fee_child
    elsif age_type == 'senior' then
      return raw_fee_senior
    end
    return raw_fee_adult + raw_fee_child + raw_fee_senior
  end

  def total_fee(age_type)
    raw_fee = raw_fee_total(age_type)
    # nil の場合は総合計を返却したいので団体割引を計算する
    if age_type == nil then
      if self.is_group_discount() then
        return (raw_fee *= $group_discount_rate).to_i
      end
    end
    return raw_fee.to_i
  end

  def is_group_discount()
    # 仕様: 団体割引とその他割引の併用はできない
    if fee.price_change_type() == 'nodiscount' && self.total_visitors_for_group_discount() >= 10 then
      return true
    end
    return false
  end
end

def clear_console
  puts "\e[H\e[2J"
end

def is_number(str)
  return str.match?(/^[0-9]+$/)
end

paremeters = [
  { "age_type" => { "ja" => "大人", "en" => "adult" } },
  { "age_type" => { "ja" => "子供", "en" => "child" } },
  { "age_type" => { "ja" => "シニア", "en" => "senior" } }
]

total_fee = 0
raw_fee = 0
details = ''

process_end = false

clear_console()

while !process_end
  puts "########################\nチケット料金を計算します\n########################"

  # adult, child, senior の各人数を入力
  for parameter in paremeters do
    print "#{parameter['age_type']['ja']}の人数を入力> "
    while !is_number(number_of_visitors = gets.chomp) do
      puts '数値を入力してください'
      print "#{parameter['age_type']['ja']}の人数を入力> "
    end

    print "チラシの枚数（#{parameter['age_type']['ja']}）を入力> "
    while !is_number(number_of_coupons = gets.chomp) do
      puts '数値を入力してください'
      print "チラシの枚数（#{parameter['age_type']['ja']}）を入力> "
    end
    if parameter['age_type']['en'] == 'adult' then
      number_of_visitor_adult = number_of_visitors.to_i
      number_of_coupon_adult = number_of_coupons.to_i
    elsif parameter['age_type']['en'] == 'child' then
      number_of_visitor_child = number_of_visitors.to_i
      number_of_coupon_child = number_of_coupons.to_i
    elsif parameter['age_type']['en'] == 'senior' then
      number_of_visitor_senior = number_of_visitors.to_i
      number_of_coupon_senior = number_of_coupons.to_i
    end

    clear_console()
  end

  # 初期設定値から Fee クラスのインスタンスを生成
  fee = Fee.new($base_fee_adult, $base_fee_child, $base_fee_senior, $base_fee_adult_sp, $base_fee_child_sp, $base_fee_senior_sp)
  # オペレーターからの入力をパラメータとして Admission クラスのインスタンスを生成
  admission = Admission.new(number_of_visitor_adult, number_of_visitor_child, number_of_visitor_senior, number_of_coupon_adult, number_of_coupon_child, number_of_coupon_senior, fee)


  details = "|        | 入場人数（通常） | 入場人数（特別） |  割引合計  |  割増合計  |\n+--------+------------------+------------------+------------+------------+\n|  大人  | #{admission.total_normal_visitors_formatted('adult')}  | #{admission.total_special_visitors_formatted('adult')}  |  #{admission.total_discount_amount_formatted('adult')}  |  #{admission.total_surcharge_amount_formatted('adult')}  |\n|  子供  | #{admission.total_normal_visitors_formatted('child')}  | #{admission.total_special_visitors_formatted('child')}  |  #{admission.total_discount_amount_formatted('child')}  |  #{admission.total_surcharge_amount_formatted('child')}  |\n| シニア | #{admission.total_normal_visitors_formatted('senior')}  | #{admission.total_special_visitors_formatted('senior')}  |  #{admission.total_discount_amount_formatted('senior')}  |  #{admission.total_surcharge_amount_formatted('senior')}  |\n+--------+------------------+------------------+------------+------------+"
  puts "合計人数:#{admission.total_visitors()} 名"
  puts "合計人数（通常）:#{admission.total_normal_visitors(nil)} 名"
  puts "合計人数（特別）:#{admission.total_special_visitors(nil)} 名"
  puts "団体割引:#{admission.is_group_discount()}"
  puts "その他割引・割増:#{admission.fee.price_change_type}"
  puts "販売合計金額:#{admission.total_fee(nil)}"
  puts "金額変更前合計金額:#{admission.base_fee_total()}"
  puts "金額変更明細:\n#{details}\n"

  while true
    print "処理を継続しますか？(yes | no)> "
    answer = gets.chomp
    if answer == 'yes' then
      clear_console()
      break
    elsif answer == 'no' then
      process_end = true
      break
    else
      puts 'yes か no を入力してください'
      next
    end
  end
end

puts '終了します'

clear_console()
