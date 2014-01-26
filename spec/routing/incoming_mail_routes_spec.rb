require 'spec_helper'

describe IncomingMailController do
  describe 'routing' do
    it 'has a POST for incoming mail' do
      post('/incoming').should route_to('incoming_mail#create')
    end
  end
end
