module BookmarksHelper
    def bookmarked_response
      return Blacklight::Solr::Response.new({}, {}) unless controller.respond_to?(:fetch_bookmarked_documents)
  
      @bookmarked_response ||= controller.fetch_bookmarked_documents.first
    end
  
    # def bookmarked_documents
    #   return [] unless controller.respond_to?(:fetch_bookmarked_documents)
  
    #   @bookmarked_documents ||= controller.fetch_bookmarked_documents.last
    # end

    def bookmarked_documents
        user = current_or_guest_user
        return [] unless user.present?
        Rails.logger.info("[from helper] user: ID=#{user}")
        ids = user.bookmarks.pluck(:document_id)
        return [] if ids.blank?
        Rails.logger.info("[from helper] Bookmark: ID=#{ids}")
        search_service.fetch(ids).last
    end
      
  end
  