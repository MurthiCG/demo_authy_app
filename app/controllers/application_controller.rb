# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ::ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def record_not_found(exception)
    # notify_airbrake(exception, {user: current_user})
    render json: { error: exception.message }.to_json, status: 404
    nil
  end

  def render_error(resource, status)
    render json: resource.errors, status:
  end

  def current_user
    user = User.find_by(id: current_token['id'])

    raise ActiveRecord::RecordNotFound if user.nil?

    user
  end

  def current_token
    enc_token = request.headers[:Authorization]
    raise ActiveRecord::RecordNotFound if enc_token.nil?

    token = JwtAuth.decode(enc_token)
    raise ActiveRecord::RecordNotFound if token.nil?

    token
  end
end
