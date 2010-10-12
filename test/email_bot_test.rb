require 'rubygems'
require 'minitest/unit'


# gem install contest or github.com/citrusbyte/contest
require 'mail'
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'rmu_rapportive_clone'

MiniTest::Unit.autorun

class EmailBotTest < MiniTest::Unit::TestCase
  describe "send email" do
    setup do
      @bot = EmailBot.new
    end
  end
end
