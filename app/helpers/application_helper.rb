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

  def email_bookmarks_mailto(documents)
    mailto = 'libsc@k-state.edu'
    subject = 'Request for Bookmarked Items'

    # NOTE: We use the host_url method to get the correct URL for the mailto link
    # This is necessary because the host URL may differ between development and production
    # environments, and we want to ensure that the link works correctly in both cases.

    Rails.logger.info("[Check response] email36 #{documents} bookmarked documents.")

    body = +"Hello " 
    body << " I would like to request access to the following items 
    %0A%0A"

    documents.each do |doc|
      title = doc[:normalized_title] || doc[:title_tesim]&.first
      context = doc[:ancestor_context] || doc[:breadcrumbs]&.join(' > ')
      containers = Array(doc[:containers]).join(', ')
      url = Rails.application.routes.url_helpers.solr_document_url(doc, host: host_url)
  
      body << "Title: #{title}%0A"
      body << "In: #{context}%0A" if context.present?
      body << "Containers: #{containers}%0A" if containers.present?
      body << "URL: <#{url}>%0A%0A"
    end

    body << "Thank you."

    "mailto:#{mailto}?subject=#{ERB::Util.url_encode(subject)}&body=#{body}"
  end

  def host_url
    options = Rails.application.config.action_mailer.default_url_options
    "#{options[:protocol] || 'https'}://#{options[:host] || 'localhost:3000'}"
  end

end
