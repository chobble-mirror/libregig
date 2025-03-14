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
      render inline: filter_link("Test Link", "/test", false)
      assert_select "a[href='/test']", text: "Test Link"
      assert_select "span", text: "Test Link", count: 0
    end

    should "return a span and no link when active" do
      render inline: filter_link("Test Link", "/test", true)
      assert_select "span", text: "Test Link"
      assert_select "a[href='/test']", text: "Test Link", count: 0
    end
  end

  context "#render_filter_group" do
    setup do
      @request = ActionDispatch::TestRequest.create
      @request.path_parameters.merge!(
        controller: "linked_devices",
        action: "index"
      )
      @controller = ApplicationController.new
      @controller.request = @request
    end

    should "render multiple filter links with correct active states" do
      # Let's simplify the test to check just the core functionality
      filters = [
        {label: "Option A", value: "a"},
        {label: "Option B", value: "b"}
      ]

      # First test - no selection, should default to nil
      html = render_filter_group(filters, :test_param)
      doc = Nokogiri::HTML.fragment(html)

      # Check wrapper
      assert_equal "p", doc.css("*")[0].name
      assert_equal "filter-group", doc.css("p")[0]["class"]

      # Both should be links since neither matches nil
      assert_equal 2, doc.css("a").length

      # Now set a parameter and test again
      params[:test_param] = "a"
      html = render_filter_group(filters, :test_param)
      doc = Nokogiri::HTML.fragment(html)

      # Should have one span and one link
      spans = doc.css("span")
      assert_equal 1, spans.length
      assert_equal "Option A", spans[0].text

      links = doc.css("a")
      assert_equal 1, links.length
      assert_equal "Option B", links[0].text
    end

    should "preserve specified parameters" do
      filters = [
        {label: "All", value: nil},
        {label: "Active", value: "active"}
      ]

      @request.params[:status] = nil
      @request.params[:device_type] = "api"

      html = render_filter_group(filters, :status, [:device_type])
      doc = Nokogiri::HTML.fragment(html)

      # Links should preserve device_type parameter
      assert doc.css("a")[0]["href"].include?("device_type=api")
    end

    should "support extra parameters in filter definitions" do
      filters = [
        {label: "Option A", value: "a", extra: {sort: "name", dir: "asc"}},
        {label: "Option B", value: "b"}
      ]

      html = render_filter_group(filters, :test_param)
      doc = Nokogiri::HTML.fragment(html)

      # First link should include extra parameters
      assert doc.css("a")[0]["href"].include?("sort=name")
      assert doc.css("a")[0]["href"].include?("dir=asc")

      # Second link should not have extra parameters
      assert_not doc.css("a")[1]["href"].include?("sort=")
    end

    should "use provided path generator" do
      filters = [{label: "Test", value: "test"}]

      # Set status=test so it won't be the active one
      @request.params[:status] = "something-else"

      html = render_filter_group(filters, :status) do |options|
        "/custom/path?#{options.to_query}"
      end

      doc = Nokogiri::HTML.fragment(html)
      # Check that we have a paragraph as wrapper
      assert_equal "p", doc.css("*")[0].name
      assert_equal "filter-group", doc.css("p")[0]["class"]
      # Check that we have the link with the correct href
      assert_equal "a", doc.css("p > *")[0].name
      assert doc.css("a")[0]["href"].start_with?("/custom/path")
    end
  end

  context "#table_header_sort" do
    setup do
      @request = ActionDispatch::TestRequest.create
      @request.path_parameters.merge!(
        controller: "events",
        action: "index"
      )
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

    should "use correct custom sort parameter name" do
      @request.params[:custom_sort] = "name asc"
      render inline: table_header_sort(:events, "name", "Name", nil, nil, :custom_sort)

      assert_select "a[href*=?]", "custom_sort=name+desc"
      assert_select "span", "▼"
    end

    should "not show sort icon when column doesn't match sort param" do
      @request.params[:effective_sort] = "source asc"
      render inline: table_header_sort(:events, "name", "Name", nil, nil, :effective_sort)

      assert_select "a[href*=?]", "effective_sort=name+asc"
      assert_select "span", {count: 0, text: /[▼▲]/}
    end

    should "respect default_sort_column when no sort is active" do
      @request.params[:sort] = nil
      render inline: table_header_sort(:events, "name", "Name", "name")

      assert_select "span", "▼"
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
