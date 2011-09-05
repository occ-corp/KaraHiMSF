module SpecAuthenticationHelper
  def self.included(base)
    base.class_eval do
      def mock_user(stubs={ })
        @mock_user ||= mock_model(User, stubs).as_null_object
      end

      before :each do
        user = mock_user
        User.stub(:find_by_id).with(user.id) { user }
        User.stub(:find).with(user.id) { user }
        session[:user_id] = user.id
      end

      def current_user
        @mock_user
      end
    end
  end
end
