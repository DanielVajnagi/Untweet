RSpec.shared_context 'authenticated_user', shared_context: :metadata do
  before do
    sign_in user
  end
end
