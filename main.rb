# TODO: JSON ファイルを読み込む
$base_fee_adult = 1000
$base_fee_child = 500
$base_fee_senior = 800
$base_fee_adult_sp = 600
$base_fee_child_sp = 400
$base_fee_senior_sp = 500

def clear_console
  puts "\e[H\e[2J"
end

def is_not_number(str)
  return str.match(/[^0-9]+/)
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

def decide_fee(age_group, is_special)
  discount_amount_mon_wed = 100
  discount_amount_night = 100
  increase_amount_holiday = 200
  # base_fee = age_group == 'adult' ? $base_fee_adult : age_group == 'child' ? $base_fee_child : $base_fee_senior
  fee = age_group == 'adult' ? (is_special ? $base_fee_adult_sp : $base_fee_adult) : age_group == 'child' ? (is_special ? $base_fee_child_sp : $base_fee_child) : (is_special ? $base_fee_senior_sp : $base_fee_senior)

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

GROUP_DISCOUNT_RATE = 0.9

fee_adult = decide_fee('adult', false)
fee_adult_sp = decide_fee('adult', true)
DISCOUNT_ADULT_DECIDED = fee_adult - fee_adult_sp
fee_child = decide_fee('child', false)
fee_child_sp = decide_fee('child', true)
DISCOUNT_CHILD_DECIDED = fee_child - fee_child_sp
fee_senior = decide_fee('senior', false)
fee_senior_sp = decide_fee('senior', true)
DISCOUNT_SENIOR_DECIDED = fee_senior - fee_senior_sp

total_fee = 0
raw_fee = 0
details = ''

process_end = false

clear_console()

while !process_end
  puts "########################\nチケット料金を計算します\n########################"

  # 大人
  while true
    print '大人の人数を入力> '
    adult_normal = gets.chomp
    if is_not_number(adult_normal) then
      puts '数値を入力してください'
      next
    else
      break
    end
  end

  clear_console()

  while true
    print 'チラシの枚数（大人）を入力> '
    adult_special = gets.chomp
    if is_not_number(adult_special) then
      puts '数値を入力してください'
      next
    else
      break
    end
  end

  clear_console()

  # 子供
  while true
    print '子供の人数を入力> '
    child_normal = gets.chomp
    if is_not_number(child_normal) then
      puts '数値を入力してください'
      next
    else
      break
    end
  end

  clear_console()

  while true
    print 'チラシの枚数（子供）を入力> '
    child_special = gets.chomp
    if is_not_number(child_special) then
      puts '数値を入力してください'
      next
    else
      break
    end
  end

  clear_console()

  # シニア
  while true
    print 'シニアの人数を入力> '
    senior_normal = gets.chomp
    if is_not_number(senior_normal) then
      puts '数値を入力してください'
      next
    else
      break
    end
  end

  clear_console()

  while true
    print 'チラシの枚数（シニア）を入力> '
    senior_special = gets.chomp
    if is_not_number(senior_special) then
      puts '数値を入力してください'
      next
    else
      break
    end
  end

  clear_console()

  total_person = adult_normal.to_i + child_normal.to_i + senior_normal.to_i
  # 仕様: 団体割引 → 10人以上で10%割引（子供は 0.5 人換算とする）
  # 上記を計算するため「子供は 0.5 人」と換算した人数を（総合計人数とは別に）計算する
  total_person_for_discount = adult_normal.to_i + child_normal.to_i / 2 + senior_normal.to_i
  is_group_discount = total_person_for_discount >= 10

  # raw_base_fee_adult = adult_normal.to_i * $base_fee_adult
  # raw_base_fee_child = child_normal.to_i * $base_fee_child
  # raw_base_fee_senior = senior_normal.to_i * $base_fee_senior
  # 「入力された数値」×「チケット料金」で…
  # 「通常」の料金の合計を計算
  raw_fee_adult = adult_special.to_i * fee_adult_sp + (adult_normal.to_i - adult_special.to_i) * fee_adult
  raw_fee_child = child_special.to_i * fee_child_sp + (child_normal.to_i - child_special.to_i) * fee_child
  raw_fee_senior = senior_special.to_i * fee_senior_sp + (senior_normal.to_i - senior_special.to_i) * fee_senior
  # 「特別」の料金の合計を計算
  # raw_fee_adult_sp = adult_special.to_i * fee_adult_sp
  # raw_fee_child_sp = child_special.to_i * fee_child_sp
  # raw_fee_senior_sp = senior_special.to_i * fee_senior_sp
  discount_amount_adult_total = adult_special.to_i * DISCOUNT_ADULT_DECIDED
  discount_amount_child_total = child_special.to_i * DISCOUNT_CHILD_DECIDED
  discount_amount_senior_total = senior_special.to_i * DISCOUNT_SENIOR_DECIDED
  # TODO: 全てのチケット料金を計算して、変数total_feeに代入
  total_fee =
    # raw_fee_adult - discount_amount_adult_total +
    # raw_fee_child - discount_amount_child_total +
    # raw_fee_senior - discount_amount_senior_total
    raw_fee_adult +
    raw_fee_child +
    raw_fee_senior 

  # raw_fee = total_fee
  # raw_fee = raw_fee_adult + raw_fee_child + raw_fee_senior + raw_fee_adult_sp + raw_fee_child_sp + raw_fee_senior_sp
  raw_fee = raw_fee_adult + raw_fee_child + raw_fee_senior

  # 割引の計算
  if !is_night() && !is_holiday() && !is_mon_wed() then
    if is_group_discount then
      total_fee *= GROUP_DISCOUNT_RATE
    end
  end

  details = "|        |   通常   |   割引   |   割増   |\n+--------+----------+----------+\n|  大人  |  #{adult_normal} 名様 |  ￥#{discount_amount_adult_total}  |\n|  子供  |  #{child_normal} 名様 |  ￥#{discount_amount_child_total}  |\n| シニア |  #{senior_normal} 名様 |  ￥#{discount_amount_senior_total}  |\n+--------+----------+----------+"
  # puts "大人:#{adult_normal}\n子供:#{child_normal}\nシニア:#{senior_normal}\n大人（特別）:#{adult_special}\n子供（特別）:#{child_special}\nシニア（特別）:#{senior_special}"
  # TODO: impl
  puts "合計人数:#{total_person} 名"
  puts "合計人数（通常）:#{total_person - (adult_special.to_i + child_special.to_i + senior_special.to_i)} 名"
  puts "合計人数（特別）:#{adult_special.to_i + child_special.to_i + senior_special.to_i} 名"
  puts "団体割引:#{is_group_discount}"
  puts "その他割引・割増:#{decide_fee_type()}"
  puts "販売合計金額:#{total_fee}"
  puts "金額変更前合計金額:#{raw_fee}"
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
