module LocaleSwitcher
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  private

  def set_locale
    Rails.logger.debug "Locale configuration:"
    Rails.logger.debug "  Default locale: #{I18n.default_locale}"
    Rails.logger.debug "  Available locales: #{I18n.available_locales}"
    Rails.logger.debug "  Extracted locale: #{extract_locale}"
    Rails.logger.debug "  Current locale before: #{I18n.locale}"

    I18n.locale = extract_locale || I18n.default_locale

    Rails.logger.debug "  Current locale after: #{I18n.locale}"
  end

  def extract_locale
    parsed_locale = params[:locale]
    return nil unless parsed_locale
    return nil unless I18n.available_locales.map(&:to_s).include?(parsed_locale)
    parsed_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end