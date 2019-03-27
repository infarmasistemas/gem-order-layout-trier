require 'minitest/autorun'
require 'gem-order-layout-trier'

class LayoutTrierTest < Minitest::Test
  @order_file = '122222222222222233333333333326032019ET00000012345678981234567898123456789812345678981234567898\n233333333333344444444444440004001059\n233333333565464654644444440004001059\n233333331111111111144444440004001059\n3433333333333005000000001000\n'
  @order_file_v04 = ''

  @return_file = '11111111111111112222222222222703201917520000333333333333444testetestetestetestetestetestetestetestetestetesteteste12345teste12345teste12345teste12345teste12345\n244444444444443333333333330010590307500504041444testetestetestetestetestetestetestetestetesteteste\n255555555555551111111111110010590307500504041444testetestetestetestetestetestetestetestetesteteste\n3433333333333005000202001080\n'
  @return_file_v04 = ''

  def test_order_file
    OrderLayout::read_order_file(text: @order_file)
  end

  def test_order_file_v04
    OrderLayout::read_order_file(text: @order_file_v04, version: '0.4')
  end

  def test_return_file
    OrderLayout::read_return_file(text: @return_file)
  end

  def test_return_file_v04
    OrderLayout::read_return_file(text: @return_file_v04, version: '0.4')
  end
end

