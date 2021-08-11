class SwaggerService < ApiService

  def holidays
    endpoint = "https://date.nager.at/api/v3/NextPublicHolidays/us"
    get_data(endpoint)
  end
end
