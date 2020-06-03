require 'test_helper'

class BooksControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get books_new_url
    assert_response :success
  end

  test "should get create" do
    get books_create_url
    assert_response :success
  end

  test "should get index" do
    get books_index_url
    assert_response :success
  end

  test "should get new_book_and_author" do
    get books_new_book_and_author_url
    assert_response :success
  end

  test "should get book_new" do
    get books_book_new_url
    assert_response :success
  end

  test "should get book_create" do
    get books_book_create_url
    assert_response :success
  end

end
