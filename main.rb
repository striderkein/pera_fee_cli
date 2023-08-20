# print 'hello (print)' # 改行なしで出力
# puts 'hello(put)' # 改行ありで出力
# p 'hello(p)' # デバッグ用出力（データ形式がわかる）

# TODO: JSON ファイルを読み込む
# 定数
fee_adult = 1000
fee_adult_sp = 600
DISCOUNT_ADULT = fee_adult - fee_adult_sp
fee_child = 500
fee_child_sp = 400
DISCOUNT_CHILD = fee_child - fee_child_sp
fee_senior = 800
fee_senior_sp = 500
DISCOUNT_SENIOR = fee_senior - fee_senior_sp

total_fee = 0
raw_fee = 0
details = 'なし'

process_end = false

def clear_console
  puts "\e[H\e[2J"
end

def is_not_number(str)
	return str.match(/[^0-9]+/)
end

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

	# TODO: 団体割引 → 10人以上で10%割引（子供は 0.5 人換算とする）
	# TODO: 夕方料金 → 17時以降は 100円 引き
	#   - 現在時刻を取得して変数nowに代入 → now = Time.now
	# TODO: 休日料金 → 土日祝は 200円 増し
	# TODO: 月水割引 → 月曜と水曜は 100円 引き
	raw_fee_adult = adult_normal.to_i * fee_adult
	raw_fee_child = child_normal.to_i * fee_child
	raw_fee_senior = senior_normal.to_i * fee_senior
	discount_adult_total = adult_special.to_i * DISCOUNT_ADULT
	discount_child_total = child_special.to_i * DISCOUNT_CHILD
	discount_senior_total = senior_special.to_i * DISCOUNT_SENIOR
	# TODO: 全てのチケット料金を計算して、変数total_feeに代入
	total_fee =
		raw_fee_adult - discount_adult_total +
		raw_fee_child - discount_child_total +
		raw_fee_senior - discount_senior_total
	raw_fee = total_fee

	details = "|        |   通常   |   割引   |\n+--------+----------+----------+\n|  大人  |  #{adult_normal} 名様 |  #{adult_special} 名様 |\n|  子供  |  #{child_normal} 名様 |  #{child_special} 名様 |\n| シニア |  #{senior_normal} 名様 |  #{senior_special} 名様 |\n+--------+----------+----------+"
	# puts "大人:#{adult_normal}\n子供:#{child_normal}\nシニア:#{senior_normal}\n大人（特別）:#{adult_special}\n子供（特別）:#{child_special}\nシニア（特別）:#{senior_special}"
	# TODO: impl
	puts "販売合計金額:#{total_fee}\n金額変更前合計金額:#{raw_fee}\n金額変更明細:\n#{details}\n"

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
