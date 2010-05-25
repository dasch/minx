
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'

COIN_SLOT   = Minx.channel
COKE_TRAY   = Minx.channel
CHANGE_TRAY = Minx.channel

VM = Minx.spawn do
  cokes_left = 100
  price = 3
  COIN_SLOT.each do |dollars|
    raise "no more cokes left" if cokes_left.zero?
    raise "please insert some coins" if dollars < 1

    cokes = dollars / price
    cokes = cokes_left if cokes_left < cokes

    cokes_left -= cokes
    change = dollars - (cokes * price)

    COKE_TRAY.write(cokes)
    CHANGE_TRAY.write(change)
  end
end
