require_relative '../lib/events_emitter'
require 'test_helper'

class TestEventsEmitter < MiniTest::Test
  include EventsEmitter

  def test_on_and_emit
    on(:test) do |a,b|
      assert_equal a , b
    end

    emit(:test,"a","a")
  end

  def test_emit_on_undefined_event_raises_argument_error
    assert_raises("ArgumentError"){ emit(:undefined) }
  end
end
