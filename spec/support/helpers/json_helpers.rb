module JsonHelpers
  def response_json
    json = JSON.parse(response.body)
    Rails.logger.info "[Request response] " + JSON.pretty_unparse(json)

    json
  end

  def send_request method, path, parameters = {}, headers = {}
    send method, path, params: parameters, headers: {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}.merge!(headers)
  end
end
