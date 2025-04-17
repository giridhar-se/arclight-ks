# frozen_string_literal: true

# Application-wide helper behaviors
module ApplicationHelper
  def additional_locale_routing_scopes
    [blacklight, arclight_engine]
  end

  def render_barcode_list(options = {})
    doc = options[:document]
    normalized_title = doc['title_filing_ssi']

    Rails.logger.debug "[Barcode] Normalized title: #{normalized_title}"

    return 'Not available' unless normalized_title && doc['barcode_ssim']

    barcode_entry = doc['barcode_ssim'].find { |val| val.start_with?(normalized_title) }

    if barcode_entry
      _, barcode = barcode_entry.split('|', 2)
      barcode&.strip || 'Not available'
    else
      Rails.logger.debug "[Barcode] No matching barcode for #{normalized_title}"
      'Not available'
    end
  end
end
