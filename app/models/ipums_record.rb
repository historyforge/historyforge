class IpumsRecord < ApplicationRecord
  def head?
    data['RELATE'] == '1'
  end

  def birth_year
    data['BIRTHYR'].to_i
  end

  def sex
    case data['SEX']
    when '1'
      'M'
    when '2'
      'F'
    end
  end

  def marital_status
    case data['MARST']
    when '4'
      'D'
    when '5'
      'Wd'
    when '6'
      'S'
    else
      %w[M_or_M1 M2_or_M3]
    end
  end

  def age
    data['AGE'].to_i
  end

  def year_immigrated
    case data['YRIMMIG']
    when '0'
      nil
    else
      data['YRIMMIG'].to_i
    end
  end

  def race
    case data['RACE']
    when '1'
      'W'
    when '2'
      'B'
    else
      nil
    end
  end
end
