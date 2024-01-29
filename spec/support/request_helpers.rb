# frozen_string_literal: true

module RequestHelpers
  def json(data)
    JSON.parse(data)
  end
end
