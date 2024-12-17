require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  context "#page_heading" do
    should "return an h1 tag with the given text" do
      render inline: page_heading("Test Heading")
      assert_select "h1", text: "Test Heading"
    end
  end

  context "#filter_link" do
    should "return a link and no span when not active" do
      render inline: filter_link("Test Link", "/test", "", false)
      assert_select "a[href='/test']", text: "Test Link"
      assert_select "span", text: "Test Link", count: 0
    end

    should "return a span and no link when active" do
      render inline: filter_link("Test Link", "/test", "", true)
      assert_select "span", text: "Test Link"
      assert_select "a[href='/test']", text: "Test Link", count: 0
    end
  end

  context "#table_header_sort" do
    setup do
      @request = ActionDispatch::TestRequest.create
      @controller = ApplicationController.new
      @controller.request = @request
    end

    [nil, "name asc", "name desc"].each do |sort|
      should "return correct link for #{sort || "unsorted"} state" do
        @request.params[:sort] = sort
        render inline: table_header_sort(:events, "name", "Name")

        expected_sort = (sort == "name asc") ? "desc" : "asc"
        assert_select "a[href*=?]", "sort=name+#{expected_sort}"

        if sort == "name asc"
          assert_select "span", "▼"
        elsif sort == "name desc"
          assert_select "span", "▲"
        else
          assert_select "span", {count: 0, text: /[▼▲]/}
        end
      end
    end
  end

  context "#flash_banner" do
    should "return correct structure for message" do
      render inline: flash_banner(:notice, "Testing, testing")
      assert_select "div.notice" do
        assert_select "div", text: "Testing, testing"
        assert_select "input[type=checkbox][id=banneralert-notice]"
        assert_select "label.close[for=banneralert-notice]", text: "Close"
      end
    end

    should "return correct structure for block" do
      render inline: flash_banner(:alert) { "Testing, testing" }
      assert_select "div.alert" do
        assert_select "div", text: "Testing, testing"
        assert_select "input[type=checkbox][id=banneralert-alert]"
        assert_select "label.close[for=banneralert-alert]", text: "Close"
      end
    end
  end
end
