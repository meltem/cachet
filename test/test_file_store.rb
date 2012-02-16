require 'test_helper'

class FileStoreTest < Test::Unit::TestCase

  def setup
    FakeFS.activate!
    FakeFS::FileSystem.clear
    @test_store = Cachet::FileStore.new("~/testroot/")
  end

  def teardown
    FakeFS.deactivate!
  end

  def test_storage_path_creation
    assert_equal "~/testroot/test/2/7/15/25f9e794323b453885f5181f1b624d0b", @test_store.storage_path(:test, "123456789"), "Check storage path, hashing seems to be not working."
  end

  def test_idempotent_storage_paths
    assert_equal @test_store.storage_path(:test, "123456789"), @test_store.storage_path(:test, "123456789"), "Should always create same path for same entry."
  end

  def test_storage_options
    @test_store.dir_level = 10
    assert_equal "~/testroot/test/2/7/15/5/8/9/3/1/13/17/25f9e794323b453885f5181f1b624d0b", @test_store.storage_path(:test, "123456789"), "Should nest resourced under 10 recursive directories."
    @test_store.dir_count = 100
    assert_equal "~/testroot/test/77/64/48/36/52/64/48/36/52/64/25f9e794323b453885f5181f1b624d0b", @test_store.storage_path(:test, "123456789"), "Should allow 100 hundred directories under any directory."
    @test_store.optimize = FALSE
    assert_equal "~/testroot/test/25f9e794323b453885f5181f1b624d0b", @test_store.storage_path(:test, "123456789"), "Should not optimize paths since optimize is disabled."
  end

  def test_purging_entries
    file_name = @test_store.storage_path(:test, 'test_item_1')
    FileUtils.mkdir_p File.dirname(file_name), :mode => 755
    File.open(file_name, 'wb') { |f| f.write("Data") }
    assert_equal(true, File.exist?(file_name))
    @test_store.purge(:test, 'test_item_1')
    assert_equal(false, File.exist?(file_name))
  end

  def test_purging_nonexisting_entries
    file_name = @test_store.storage_path(:test, 'test_item_2')
    assert_equal(false, File.exist?(file_name))
    assert_nothing_thrown("FileStore should be slince while purging nonexisting entities") {
      @test_store.purge(:test, 'test_item_2')
    }
    assert_equal(false, File.exist?(file_name))
  end

  def test_reading_existing_entries
    @test_store.write(:test, 'test_item_3', "Some test data")
    assert_equal("Some test data", @test_store.read(:test, 'test_item_3'))
  end

  def test_reading_nonexisting_entries
    @test_store.purge(:test, 'test_item_4')
    assert_nil @test_store.read(:test, 'test_item_4')
  end
end
