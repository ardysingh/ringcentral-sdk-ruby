require './test/test_helper.rb'

class RingCentralSdkTest < Test::Unit::TestCase
  def testSetup

    rcsdk = RingCentralSdk::Sdk.new(
      "myAppKey",
      "myAppSecret",
      RingCentralSdk::Sdk::RC_SERVER_SANDBOX
    )

    assert_equal "RingCentralSdk::Sdk", rcsdk.class.name
    assert_equal "RingCentralSdk::Platform::Platform", rcsdk.platform.class.name

  end
end