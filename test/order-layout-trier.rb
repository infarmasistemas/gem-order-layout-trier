require 'minitest/autorun'
require 'gem-order-layout-trier'

class LayoutTrierTest < Minitest::Test
  def order_file
    "122222222222222233333333333326032019ET00000012345678981234567898123456789812345678981234567898\n233333333333344444444444440004001059\n233333333565464654644444440004001059\n233333331111111111144444440004001059\n3433333333333005000000001000\n"
  end

  def order_file_v04
    "AA111111110000000000222222222222233333002270320194444444444CE5555CE                                               666666"
  end

  def return_file
    "11111111111111112222222222222703201917520000333333333333444testetestetestetestetestetestetestetestetestetesteteste12345teste12345teste12345teste12345teste12345\n244444444444443333333333330010590307500504041444testetestetestetestetestetestetestetestetesteteste\n255555555555551111111111110010590307500504041444testetestetestetestetestetestetestetestetesteteste\n3433333333333005000202001080\n"
  end

  def return_file_v04
    "AA11111111000000000022222222222223333344455555555555555555555555555555555555555556666666666                                           777777"
  end

  def test_order_file_header_field
    order_hash = OrderLayout::read_order_file(text: order_file)
    h = order_hash[:header]
    test = [
      h[:register_type].to_s.length == 1,
      h[:client_code].to_s.length == 15,
      h[:order_number].to_s.length == 12,
      h[:order_date].to_s.length == 8,
      h[:purchase_type].to_s.length == 1,
      h[:return_type].to_s.length == 1,
      h[:business_condition_pointer].to_s.length == 6,
      h[:free_field].to_s.length == 50
    ].uniq

    assert (test.length == 1 && test[0] == true)
  end

  def test_order_file_details
    order_hash = OrderLayout::read_order_file(text: order_file)
    d = order_hash[:details]
    assert d.length == 3
  end

  def test_order_file_trailer_field
    order_hash = OrderLayout::read_order_file(text: order_file)
    t = order_hash[:trailer]
    test = [
        t[:register_type].to_s.length == 1,
        t[:order_number].to_s.length == 12,
        t[:number_of_units].to_s.length == 5,
        t[:number_of_items].to_s.length == 10
    ].uniq

    assert (test.length == 1 && test[0] == true)
  end

  def test_return_file_header_field
    order_hash = OrderLayout::read_return_file(text: return_file)
    h = order_hash[:header]
    test = [
        h[:register_type].to_s.length == 1,
        h[:cnpj].to_s.length == 15,
        h[:order_number].to_s.length == 12,
        h[:processing_date].to_s.length == 8,
        h[:processing_hour].to_s.length == 8,
        h[:order_number_distributor].to_s.length == 12,
        h[:reason_code].to_s.length == 3,
        h[:reason_description].to_s.length == 50,
        h[:free_field].to_s.length == 50
    ].uniq

    assert (test.length == 1 && test[0] == true)
  end

  def test_return_file_details
    order_hash = OrderLayout::read_return_file(text: return_file)
    d = order_hash[:details]
    assert d.length == 2
  end

  def test_return_file_trailer_field
    order_hash = OrderLayout::read_return_file(text: order_file)
    t = order_hash[:trailer]
    test = [
        t[:register_type].to_s.length == 1,
        t[:order_number].to_s.length == 12,
        t[:number_of_lines].to_s.length == 5,
        t[:number_of_served_items].to_s.length == 5,
        t[:number_of_not_served_items].to_s.length == 5
    ].uniq
    assert (test.length == 1 && test[0] == true)
  end

  def test_order_file_v04_field
    h = OrderLayout::read_order_file(text: order_file, version: '0.4')
    test = [
      h[:layout_identification].to_s.length == 2,
      h[:client_code].to_s.length == 8,
      h[:reserved_number].to_s.length == 10,
      h[:product_barcode].to_s.length == 13,
      h[:quantity_demanded].to_s.length == 5,
      h[:payment_terms].to_s.length == 3,
      h[:negotiation_date].to_s.length == 8,
      h[:order_number].to_s.length == 10,
      h[:provider_uf].to_s.length == 2,
      h[:affiliate_code].to_s.length == 4,
      h[:client_uf].to_s.length == 2,
      h[:reserved].to_s.length == 47,
      h[:sequential_number].to_s.length == 6
    ].uniq

    assert (test.length == 1 && test[0] == true)
  end

  def test_return_file_v04_field
    h = OrderLayout::read_return_file(text: order_file, version: '0.4')
    test = [
        h[:layout_identification].to_s.length == 2,
        h[:client_cod].to_s.length == 8,
        h[:reserved_number].to_s.length == 10,
        h[:product_barcode].to_s.length == 13,
        h[:number_of_absences].to_s.length == 5,
        h[:absence_return_cod].to_s.length == 3,
        h[:absence_return_description].to_s.length == 40,
        h[:order_number].to_s.length == 10,
        h[:reserved].to_s.length == 43,
        h[:sequential_number].to_s.length == 6
    ].uniq

    assert (test.length == 1 && test[0] == true)
  end

end

