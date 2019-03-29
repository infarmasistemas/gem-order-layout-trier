require 'date'
require 'net/ftp'

module OrderLayoutTrier

  $ftp_url = ''
  $ftp_port = 0
  $ftp_user = ''
  $ftp_password = ''
  $ftp_passive = false
  $codClient = 0
  $numOrder = 0
  $clientCnpjOrder = 0
  $currentUserName = ''
  $establishmentCnpj = 0
  $comment = ''
  $marketingPolicyId = 0
  $deadlineId = 0

  def self.set_connect ftp_url, ftp_port
    $ftp_url = ftp_url  #Rails.application.config.ftp_url
    $ftp_port = ftp_port #Rails.application.config.ftp_port
  end

  def self.set_login user, password
    $ftp_user = user #Rails.application.config.ftp_user
    $ftp_password = password #ails.application.config.ftp_password
  end

  def self.set_ftp_passive isPassive
    $ftp_passive = isPassive # Rails.application.config.ftp_passive
  end

  def self.set_establishmentCnpj establishmentCnpj
    $establishmentCnpj = establishmentCnpj
  end

  def self.set_codClient codClient
    $codClient = codClient
  end

  def self.set_numOrder numOrder
    $numOrder = numOrder
  end

  def self.set_clientCnpjOrder clientCnpjOrder
    $clientCnpjOrder = clientCnpjOrder
  end

  def self.set_currentUserName currentUserName
    $currentUserName = currentUserName
  end

  def self.set_comment comment
    $comment = comment
  end

  def self.set_marketingPolicyId marketingPolicyId
    $marketingPolicyId = marketingPolicyId
  end

  def self.set_deadlineId deadlineId
    $deadlineId = deadlineId
  end

  def self.set_totalOrders totalOrders
    $totalOrders = totalOrders
  end

  def self.set_totalUnits totalUnits
    $totalUnits = totalUnits
  end

  #===========================
  #=cria pasta, se não existir
  #===========================
  def self.create_folder directory_name
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
  end

  #=============================================
  #=Envia pedido via FTP para Pedido Eletrônico
  #=============================================
  def self.send_ftp directory_name

    # new(host = nil, user = nil, passwd = nil, acct = nil)
    # Creates and returns a new FTP object. If a host is given, a connection is made.
    # Additionally, if the user is given, the given user name, password, and (optionally) account are used to log in.
    ftp = Net::FTP.new(false)

    # connect(host, port = FTP_PORT)
    # Establishes an FTP connection to host, optionally overriding the default port.
    ftp.connect($ftp_url, $ftp_port)

    # login(user = "anonymous", passwd = nil, acct = nil)
    # string “anonymous” and the password is nil, a password of user@host is synthesized.
    # If the acct parameter is not nil, an FTP ACCT command is sent following the successful login.
    #ftp.login(Rails.application.config.ftp_user, Rails.application.config.ftp_password)
    ftp.login($ftp_user, $ftp_password)

    #When true, the connection is in passive mode. Default: false.
    #ftp.passive = Rails.application.config.ftp_passive
    ftp.passive = $ftp_passive

    #Changes the (remote) directory.
    ftp.chdir('/ped')

    ftp.put(directory_name)
    ftp.close

  end

  #========================
  #= Ler arquivo de pedido
  #========================
  def self.read_order txt
    header = {}
    details = []
    trailer = {}

    txt.each_line do |line|
      if line[0] == '1' # Header
        header = {
          register_type: line[0],
          client_code: line[1...16],
          order_number: line[16...28],
          order_date: line[28...36],
          purchase_type: line[36],
          return_type: line[37],
          business_condition_pointer: line[38...44],
          free_field: line[44...94]
        }
      elsif line[0] == '2' # Detalhe
        details << {
          register_type: line[0],
          order_number: line[1...13],
          product_code: line[13...26],
          amount: line[26...31],
          discount: line[31...36].insert(-3, '.').to_f
        }
      else # Trailer
        trailer = {
          register_type: line[0],
          order_number: line[1...13],
          number_of_units: line[13...18],
          number_of_items: line[18...28]
        }
      end
    end

    { header: header, details: details, trailer: trailer }
  end

  #=====================================
  #= Ler arquivo de pedido (versao 0.4)
  #=====================================
  def self.read_order_v040 txt
    {
      layout_identification: txt[0...2],
      client_code: txt[2...10],
      reserved_number: txt[10...20],
      product_barcode: txt[20...33],
      quantity_demanded: txt[33...38],
      payment_terms: txt[38...41],
      negotiation_date: txt[41...49],
      order_number: txt[49...59],
      provider_uf: txt[59...61],
      affiliate_code: txt[61...65],
      client_uf: txt[65...67],
      reserved: txt[67...114],
      sequential_number: txt[114...120]
    }
  end

  def self.read_order_file(text:, version: '')
    if version == '0.4'
      response_hash = read_order_v040 text
    else
      response_hash = read_order text
    end
    response_hash
  end

  #=========================
  #= Ler arquivo de retorno
  #=========================
  def self.read_return txt
    header = {}
    details = []
    trailer = {}

    txt.each_line do |line|
      if line[0] == '1' # Header
        header = {
            register_type: line[0],
            cnpj: line[1...16],
            order_number: line[16...28],
            processing_date: line[28...36],
            processing_hour: line[36...44],
            order_number_distributor: line[44...56],
            reason_code: line[56...59],
            reason_description: line[59...109],
            free_field: line[109...159]
        }
      elsif line[0] == '2' # Detalhe
        details << {
            register_type: line[0],
            product_code: line[1...14],
            order_numer: line[14...26],
            payment_term: line[26],
            number_of_served: line[27...32],
            discount: line[32...37],
            granted: line[37...40],
            number_of_not_served: line[40...45],
            reason_code: line[45...48],
            reason_description: line[48...98]
        }
      else # Trailer
        trailer = {
            register_type: line[0],
            order_number: line[1...13],
            number_of_lines: line[13...18],
            number_of_served_items: line[18...23],
            number_of_not_served_items: line[23...28]
        }
      end
    end

    { header: header, details: details, trailer: trailer }
  end

  #======================================
  #= Ler arquivo de retorno (versao 0.4)
  #======================================
  def self.read_return_v040 txt
    {
      layout_identification: txt[0...2],
      client_cod: txt[2...10],
      reserved_number: txt[10...20],
      product_barcode: txt[20...33],
      number_of_absences: txt[33...38],
      absence_return_cod: txt[38...41],
      absence_return_description: txt[41...81],
      order_number: txt[81...91],
      reserved: txt[91...134],
      sequential_number: txt[134...140]
    }
  end


  def self.read_return_file(text:, version: '')
    if version == '0.4'
      response_hash = read_return_v040 text
    else
      response_hash = read_return text
    end
    response_hash
  end

end
