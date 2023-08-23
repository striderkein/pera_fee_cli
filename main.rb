# TODO: JSON ファイルを読み込む
$base_fee_adult = 1000
$base_fee_child = 500
$base_fee_senior = 800
$base_fee_adult_sp = 600
$base_fee_child_sp = 400
$base_fee_senior_sp = 500
$group_discount_rate = 0.9


def clear_console
  puts "\e[H\e[2J"
end

def is_number(str)
  return str.match?(/^[0-9]+$/)
end

def is_night()
  return Time.now.hour >= 17
end

# 休日かどうかを判定する
# 土日のみを休日とする
# @return [Boolean] 休日かどうか
def is_holiday()
  return Time.now.wday == 0 || Time.now.wday == 6
end

# 実行時点の曜日が月曜日または水曜日であるかを判定する
# @return [Boolean] 月曜日または水曜日か否か
def is_mon_wed()
  return Time.now.wday == 1 || Time.now.wday == 3
end

def decide_fee_type()
  if is_holiday() then
    return 'holiday'
  elsif is_mon_wed() then
    return 'mon_wed'
  elsif is_night() then
    return 'night'
  else
    return 'nodiscount'
  end
end

def base_fee(age_group)
  return age_group == 'adult' ? $base_fee_adult : age_group == 'child' ? $base_fee_child : $base_fee_senior
end

def base_fee_sp(age_group)
  return age_group == 'adult' ? $base_fee_adult_sp : age_group == 'child' ? $base_fee_child_sp : $base_fee_senior_sp
end

def decide_fee(age_group, is_special)
  discount_amount_mon_wed = 100
  discount_amount_night = 100
  increase_amount_holiday = 200
  fee = is_special ? base_fee_sp(age_group) : base_fee(age_group)

  discount_type = decide_fee_type()
  if discount_type == 'holiday' then
    return fee + increase_amount_holiday
  elsif discount_type == 'mon_wed' then
    return fee - discount_amount_mon_wed
  elsif discount_type == 'night' then
    return fee - discount_amount_night
  else
    return fee
  end
end

def is_group_discount(total_person)
  if !is_night() && !is_holiday() && !is_mon_wed() && total_person >= 10 then
    return true
  end
  return false
end

def calc_total_fee(adult_normal, child_normal, senior_normal, raw_fee)
  # 仕様: 団体割引 → 10人以上で10%割引（子供は 0.5 人換算とする）
  # 上記を計算するため「子供は 0.5 人」と換算した人数を（総合計人数とは別に）計算する
  total_person = adult_normal.to_i + child_normal.to_i / 2 + senior_normal.to_i
  if is_group_discount(total_person) then
    return raw_fee *= $group_discount_rate
  end
  return raw_fee
end

fee_adult = decide_fee('adult', false)
fee_adult_sp = decide_fee('adult', true)
DISCOUNT_ADULT_DECIDED = fee_adult - fee_adult_sp
fee_child = decide_fee('child', false)
fee_child_sp = decide_fee('child', true)
DISCOUNT_CHILD_DECIDED = fee_child - fee_child_sp
fee_senior = decide_fee('senior', false)
fee_senior_sp = decide_fee('senior', true)
DISCOUNT_SENIOR_DECIDED = fee_senior - fee_senior_sp

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
      number_of_visitor_adult = number_of_visitors
      number_of_coupon_adult = number_of_coupons
    elsif parameter['age_type']['en'] == 'child' then
      number_of_visitor_child = number_of_visitors
      number_of_coupon_child = number_of_coupons
    elsif parameter['age_type']['en'] == 'senior' then
      number_of_visitor_senior = number_of_visitors
      number_of_coupon_senior = number_of_coupons
    end
  end

  clear_console()

  total_person = number_of_visitor_adult.to_i + number_of_visitor_child.to_i + number_of_visitor_senior.to_i

  # 「通常」料金の合計を計算
  fee_adult_normal_total = (number_of_visitor_adult.to_i - number_of_coupon_adult.to_i) * base_fee('adult')
  fee_child_normal_total = (number_of_visitor_child.to_i - number_of_coupon_child.to_i) * base_fee('child')
  fee_senior_normal_total = (number_of_visitor_senior.to_i - number_of_coupon_senior.to_i) * base_fee('senior')
  # 「特別」料金の合計を計算
  fee_adult_sp_total = number_of_coupon_adult.to_i * fee_adult_sp
  fee_child_sp_total = number_of_coupon_child.to_i * fee_child_sp
  fee_senior_sp_total = number_of_coupon_senior.to_i * fee_senior_sp

  # 「入力された数値」×「チケット料金」で…
  # 割引前料金の合計を計算
  raw_fee_adult = number_of_visitor_adult.to_i * fee_adult
  raw_fee_child = number_of_visitor_child.to_i * fee_child
  raw_fee_senior = number_of_visitor_senior.to_i * fee_senior
  # 割引額の合計を計算
  discount_amount_adult_total = number_of_coupon_adult.to_i * DISCOUNT_ADULT_DECIDED
  discount_amount_child_total = number_of_coupon_child.to_i * DISCOUNT_CHILD_DECIDED
  discount_amount_senior_total = number_of_coupon_senior.to_i * DISCOUNT_SENIOR_DECIDED
  # raw_fee_total = raw_fee_adult + raw_fee_child + raw_fee_senior
  raw_fee_total = number_of_visitor_adult.to_i * base_fee('adult') + number_of_visitor_child.to_i * base_fee('child') + number_of_visitor_senior.to_i * base_fee('senior')

  # 全てのチケット料金を計算して、変数total_feeに代入
  total_fee = calc_total_fee(number_of_visitor_adult, number_of_visitor_child, number_of_visitor_senior, raw_fee_total)

  details = "|        |   入場人数（通常）   |   入場人数（特別）   |   割引合計   |   割増合計   |\n+--------+----------+----------+\n|  大人  |  #{number_of_visitor_adult} 名様 |  #{number_of_coupon_adult} 名様 |  ￥#{discount_amount_adult_total}  |\n|  子供  |  #{number_of_visitor_child} 名様 |  ￥#{discount_amount_child_total}  |\n| シニア |  #{number_of_visitor_senior} 名様 |  ￥#{discount_amount_senior_total}  |\n+--------+----------+----------+"
  puts "合計人数:#{total_person} 名"
  puts "合計人数（通常）:#{total_person - (number_of_coupon_adult.to_i + number_of_coupon_child.to_i + number_of_coupon_senior.to_i)} 名"
  puts "合計人数（特別）:#{number_of_coupon_adult.to_i + number_of_coupon_child.to_i + number_of_coupon_senior.to_i} 名"
  puts "団体割引:#{is_group_discount(total_person)}"
  puts "その他割引・割増:#{decide_fee_type()}"
  puts "販売合計金額:#{total_fee}"
  puts "金額変更前合計金額:#{raw_fee_total}"
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
