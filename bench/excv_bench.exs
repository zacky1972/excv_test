defmodule ExcvBench do
  use Benchfella

  setup_all do
  	ExcvTest.test_img(true)
  	{:ok, 0}
  end

  bench "Enum Excv CPU 100" do
  	ExcvTest.enum_test_img(false, 100)
  end

  bench "Enum Excv GPU 100" do
  	ExcvTest.enum_test_img(true, 100)
  end

  bench "Flow Excv CPU 100" do
  	ExcvTest.flow_test_img(false, 100)
  end

  bench "Flow Excv GPU 100" do
  	ExcvTest.flow_test_img(true, 100)
  end
end
