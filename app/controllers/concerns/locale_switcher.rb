module LocaleSwitcher
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  private

  def set_locale
    Rails.logger.debug "Default locale: #{I18n.default_locale}"
    Rails.logger.debug "Available locales: #{I18n.available_locales}"

    # Extract locale from URL
    extracted_locale = extract_locale_from_url
    Rails.logger.debug "Extracted locale from URL: #{extracted_locale}"

    # Set locale based on URL parameter or default
    I18n.locale = extracted_locale || I18n.default_locale
    Rails.logger.debug "Current locale before setting: #{I18n.locale}"

    # Store the current path for redirection
    @current_path = request.fullpath.gsub(/^\/#{extracted_locale}/, "") if extracted_locale

    # Redirect to default locale if no locale specified
    if extracted_locale.nil? && request.path == "/"
      Rails.logger.debug "Redirecting to default locale: #{I18n.default_locale}"
      redirect_to "/#{I18n.default_locale}"
    end
  end

  def extract_locale_from_url
    locale = params[:locale]
    return nil unless locale
    return nil unless I18n.available_locales.include?(locale.to_sym)
    locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
