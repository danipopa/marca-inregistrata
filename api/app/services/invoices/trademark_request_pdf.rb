require "prawn"

module Invoices
  class TrademarkRequestPdf
    COMPANY_NAME = "Sandu si Asociatii IP Attorney SRL"
    COMPANY_EMAIL = "contact@inregistrare-marca.com"
    COMPANY_PHONE = "0770 898 767"

    def self.generate(trademark_request)
      new(trademark_request).generate
    end

    def initialize(trademark_request)
      @trademark_request = trademark_request
    end

    def generate
      Prawn::Document.new(page_size: "A4", margin: 48) do |pdf|
        register_fonts(pdf)
        header(pdf)
        parties(pdf)
        order_details(pdf)
        totals(pdf)
        footer(pdf)
      end.render
    end

    private

    attr_reader :trademark_request

    def register_fonts(pdf)
      regular = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
      bold = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
      return unless File.exist?(regular) && File.exist?(bold)

      pdf.font_families.update("DejaVuSans" => {
        normal: regular,
        bold: bold
      })
      pdf.font "DejaVuSans"
    end

    def header(pdf)
      pdf.text document_title, size: 24, style: :bold
      pdf.move_down 6
      pdf.text "Numar: #{document_number}", size: 11
      pdf.text "Data: #{trademark_request.created_at.strftime("%d.%m.%Y")}", size: 11
      pdf.text "Status comanda: #{status_label}", size: 11
      pdf.move_down 24
    end

    def parties(pdf)
      pdf.bounding_box([0, pdf.cursor], width: 235) do
        pdf.text "Furnizor", style: :bold
        pdf.text COMPANY_NAME
        pdf.text COMPANY_EMAIL
        pdf.text COMPANY_PHONE
      end

      pdf.bounding_box([285, pdf.cursor + 54], width: 235) do
        pdf.text "Client", style: :bold
        pdf.text trademark_request.owner_name.presence || trademark_request.email
        pdf.text "Tip titular: #{trademark_request.owner_type}" if trademark_request.owner_type.present?
        pdf.text "Identificator fiscal: #{trademark_request.tax_id}" if trademark_request.tax_id.present?
        pdf.text trademark_request.address.to_s if trademark_request.address.present?
        pdf.text trademark_request.email
        pdf.text trademark_request.phone
      end

      pdf.move_down 36
    end

    def order_details(pdf)
      pdf.text "Detalii comanda", style: :bold
      pdf.move_down 8
      pdf.stroke_color "DED8CF"
      pdf.stroke_bounds
      pdf.move_down 8
      pdf.indent(12) do
        pdf.text "Serviciu: #{trademark_request.product_name}", style: :bold
        pdf.text "Tip comanda: #{order_type_label}"
        pdf.text "Marca: #{trademark_request.mark}"
        pdf.text "Clase NISA: #{trademark_request.classes_count}"
        pdf.text "Modificare adresa/nume titular: Da" if trademark_request.owner_change_requested?
        pdf.text "Metoda plata: #{payment_label}"
        pdf.text "Total: #{trademark_request.formatted_total}", style: :bold
      end
      pdf.move_down 8
      pdf.stroke_horizontal_rule

      if trademark_request.primary_class.present? || trademark_request.goods.present?
        pdf.move_down 14
        pdf.text "Clase si produse/servicii", style: :bold
        pdf.text trademark_request.primary_class.to_s if trademark_request.primary_class.present?
        pdf.text trademark_request.goods.to_s if trademark_request.goods.present?
      end
    end

    def totals(pdf)
      pdf.move_down 24
      pdf.stroke_horizontal_rule
      pdf.move_down 12
      pdf.text "Total de plata: #{trademark_request.formatted_total}", size: 16, style: :bold, align: :right
      pdf.text payment_note, size: 10, align: :right
    end

    def footer(pdf)
      pdf.move_down 36
      pdf.text "Document generat automat pentru comanda ##{trademark_request.id}.", size: 9, color: "68635C"
      pdf.text "Pentru intrebari: #{COMPANY_EMAIL}", size: 9, color: "68635C"
    end

    def proforma?
      trademark_request.payment_method == "transfer"
    end

    def document_title
      proforma? ? "Factura proforma" : "Factura fiscala"
    end

    def document_number
      prefix = proforma? ? "PRO" : "INV"
      "#{prefix}-#{trademark_request.created_at.year}-#{trademark_request.id.to_s.rjust(6, "0")}"
    end

    def payment_label
      {
        "card" => "Card online",
        "paypal" => "PayPal",
        "transfer" => "Transfer bancar"
      }.fetch(trademark_request.payment_method, "Neselectata")
    end

    def order_type_label
      {
        "monitoring" => "Monitorizare marca",
        "renewal" => "Reinnoire marca",
        "registration" => "Inregistrare marca"
      }.fetch(trademark_request.order_type, trademark_request.order_type)
    end

    def status_label
      {
        "pending_payment" => "In asteptarea platii",
        "paid" => "Platita",
        "processing" => "In lucru",
        "completed" => "Finalizata"
      }.fetch(trademark_request.status, trademark_request.status)
    end

    def payment_note
      return "Proforma este emisa pentru plata prin transfer bancar." if proforma?

      "Factura emisa pentru plata online prin #{payment_label}."
    end
  end
end
