module TimesheetsHelper

  def monthnames
    [["Jan", 1], ["Feb", 2], ["Mar", 3], ["Apr", 4], ["May", 5], ["Jun", 6], ["Jul", 7], ["Aug", 8], ["Sep", 9], ["Oct", 10], ["Nov", 11], ["Dec", 12]]
  end

  def monthname(num)
    Date::MONTHNAMES[num]
  end

  def dhm(hours)
    (hours/24).to_i.to_s + "d " + (hours%24).to_i.to_s.rjust(2, '0') + ":" + ((hours*60)%60).to_i.to_s.rjust(2, '0') 
  end

end
