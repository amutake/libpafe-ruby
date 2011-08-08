# $Id: suica.rb,v 1.7 2008-02-17 04:49:57 hito Exp $
require "pasori"

class Suica
  Type1 = {
    0x03 => '������',
    0x05 => '�ֺ�ü��',
    0x07 => '���䵡',
    0x08 => '���䵡',
    0x12 => '���䵡',
    0x16 => '������',
    0x17 => '�ʰײ�����',
    0x18 => '���ü��',
    0x1A => '����ü��',
    0x1B => '��������',
    0x1C => '���������',
    0x1D => 'Ϣ�������',
    0xC7 => 'ʪ��ü��',
    0xC8 => '���ε�',
  }

  Type2 = {
    0x01 => '���»�ʧ',
    0x02 => '���㡼��',
    0x03 => '����',
    0x04 => '����',
    0x07 => '����',
    0x0D => '�Х�',
    0x0F => '�Х�',
    0x14 => '�����ȥ��㡼��',
    0x46 => 'ʪ��',
    0xC6 => 'ʪ��(����ʻ��)',
  }

  def initialize
    @pasori = Pasori.open
    @felica = @pasori.felica_polling(Felica::POLLING_SUICA)
  end

  def close
    @felica.close
    @pasori.close
  end

  def each(&block)
    @felica.foreach(Felica::SERVICE_SUICA_HISTORY) {|l|
      h = parse_history(l)
      yield(h)
    }
  end

  def check_val(hash, val)
    v = hash[val]
    if (v)
      v
    else
      sprintf("����(%02x)", val)
    end
  end

  def read_in_out(&b)
    @felica.each(Felica::SERVICE_SUICA_IN_OUT) {|l|
      yield(l)
    }
  end

  def parse_history(l)
    d = l.unpack('CCnnCCCCvN')
    h = {}
    h["type1"] = check_val(Type1, d[0])
    h["type2"] = check_val(Type2, d[1])
    h["type3"] = d[2]
    y = (d[3] >> 9) + 2000
    m = (d[3] >> 5) & 0b1111
    dd = d[3] & 0b11111
    begin
      h["date"] = Time.local(y, m, dd)
    rescue
      return nil
    end
    h["from"] = sprintf("%02x-%-2x", d[4], d[5])
    h["to"] = sprintf("%02x-%02x", d[6], d[7])
    h["balance"] = d[8]
    h["special"] = d[9]
    h
  end
end

Type3 = {
  0x20 => '�о�',
  0x40 => '����',
  0xa0 => '����',
  0xc0 => '����',
}



suica = Suica.new

i = 0
suica.read_in_out {|l|
  d = l.unpack('CCCCCCnnSN')

  y = (d[6] >> 9) + 2000
  m = (d[6] >> 5) & 0x0f
  dd = d[6] & 0x1f

  printf("%4s %02x-%02x %04d/%02d/%02d %02x:%02x %5d\n", Type3[d[0]], d[2], d[3], y, m, dd, d[7] >> 8, d[7] & 0xff, d[8])
}

suica.each {|h|
  printf("%16s %16s %04x %s %s%4s %s%4s %5d %08x\n",
         h["type1"],
         h["type2"],
         h["type3"],
         h["date"].strftime("%Y/%m/%d"),
         h["from"],
         if (h["type3"] == 3) then "(��)" else "" end,
         h["to"],
         if (h["type3"] == 4) then "(��)" else "" end,
         h["balance"],
         h["special"]
         )
}

suica.close

