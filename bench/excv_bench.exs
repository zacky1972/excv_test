defmodule ExcvBench do
  use Benchfella

  setup_all do
  	ExcvTest.test_img(true)
  	{:ok, 0}
  end

  bench "Enum Excv CPU 100" do
  	ExcvTest.enum_test_img(false, 100)
	:ok
  end

  bench "Enum Excv GPU 100" do
  	ExcvTest.enum_test_img(true, 100)
	:ok
  end

  bench "Flow Excv CPU 100" do
  	ExcvTest.flow_test_img(false, 100)
	:ok
  end

  bench "Flow Excv GPU 100" do
  	ExcvTest.flow_test_img(true, 100)
	:ok
  end

  bench "PelemayFp Excv CPU 100" do
  	ExcvTest.pelemay_fp_test_img(false, 100)
	:ok
  end

  bench "PelemayFp Excv GPU 100" do
  	ExcvTest.pelemay_fp_test_img(true, 100)
	:ok
  end
end
