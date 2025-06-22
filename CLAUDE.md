# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Lint/Test Commands

- Run server: `rails s` or `bundle exec rails server`
- Rails console: `rails c`
- **Lint modified files only**: `bundle exec standardrb --fix path/to/file.rb` (NEVER run on entire repo)
- Lint check (no fix): `bundle exec standardrb path/to/file.rb`
- **ERB files don't need linting with standardrb**
- **Run tests (parallel)**: `bin/test` (RECOMMENDED - clean output with coverage summary)
- **Check code standards**: `rake code_standards` (reports violations)
- **Lint modified files**: `rake code_standards:lint_modified` (StandardRB on changed files only)
- **Full standards workflow**: `rake code_standards:fix_all` (StandardRB + standards check)
- Run all tests: `rails test` (WARNING: Takes ages - only run when specifically requested)
- **Run tests in parallel**: `rails test -j` (verbose output)
- Run single test file: `rails test test/models/band_test.rb`
- Run single test: `rails test test/models/band_test.rb -n test_name`
- Run with verbose output: `rails test -v`
- Prepare parallel test databases: `rails db:test:prepare`

## Environment Notes

- **ripgrep (rg) is available via bin/find** - use `bin/find "search term"` for searching codebase
- **Full test suite is SLOW** - only run `rails test` when explicitly requested
- Prefer running individual test files or specific tests during development
- **Database locking**: If tests fail with "database is locked", just inform the user and wait for them to confirm it's unlocked
- **NEVER paste code into Rails console** - it never works. Instead write very specific Minitest tests

## Test Helper Scripts

Note: The test helper scripts (bin/test, bin/rspec-find, etc.) were copied from another project that uses RSpec. Since this project uses Minitest, these scripts would need to be adapted or replaced with Minitest-compatible versions.

For now, use the standard Rails test commands:
- `rails test` - Run all tests
- `rails test test/models/` - Run model tests  
- `rails test test/controllers/` - Run controller tests
- `rails test test/models/band_test.rb` - Run specific test file
- `rails test test/models/band_test.rb -n /pattern/` - Run tests matching pattern

## Core Development Principles

### Internationalization (i18n) - ALWAYS

- **EVERY string must use I18n** - no hardcoded text anywhere
- **Split locale files** - create new files in `config/locales/` instead of growing `en.yml`
- Organize keys logically: `bands.messages.member_added`
- Use I18n in tests: `I18n.t("bands.buttons.archive")`
- Structure: `controller.section.key` or `model.field.description`

### Form Conventions - STRICT REQUIREMENTS

All forms must follow these exact patterns:

1. **Always use form_context partial** for form wrapper:

   ```erb
   <%= render 'form/form_context',
     model: @model,
     i18n_base: 'forms.form_name' do |form|
   %>
   ```

2. **I18n structure for forms** - ALL forms must use `forms.` namespace:

   ```yaml
   en:
     forms:
       form_name:
         header: "Form Title" # Automatically rendered by form_context
         sections:
           section_name: "Section Title"
         fields: # ALL field labels MUST be in .fields namespace
           field_name: "Field Label"
           another_field: "Another Label"
         submit: "Submit Button Text" # Used by submit_button partial
   ```

3. **Field helpers expect translations in .fields namespace**:

   - `form_field_setup` looks for labels at `#{i18n_base}.fields.#{field}`
   - NO fallbacks - if field translation missing, it should error
   - This ensures all forms are properly internationalized

4. **Submit button automatically uses i18n**:

   ```erb
   <%= render 'form/submit_button' %>  # Looks for #{i18n_base}.submit
   ```

   - Never pass text parameter unless overriding default behavior
   - Submit button should find text at `#{@_current_i18n_base}.submit`

5. **Form partials set context automatically**:

   - `form_context` sets `@_current_form` and `@_current_i18n_base`
   - All nested partials can access these without passing parameters
   - Field partials use `form_field_setup` to get labels from i18n

6. **Standard form structure**:

   ```erb
   <%= render 'form/form_context',
     model: @band,
     i18n_base: 'forms.band' do |form|
   %>
     <%= render 'form/fieldset', legend_key: 'basic_info' do %>
       <%= render 'form/text_field', field: :name %>
       <%= render 'form/text_area', field: :description %>
     <% end %>
   <% end %>
   ```

   - Submit button is AUTOMATICALLY included by form_context
   - Never manually add submit buttons

7. **Non-model forms use scope**:
   ```erb
   <%= render 'form/form_context',
     model: nil,
     scope: :session,
     i18n_base: 'forms.session_new',
     url: login_path do |form|
   %>
   ```

### Testing Approach

- **Before editing ANY file** - identify what tests/test files are associated with it
- **Write integration tests for ALL new code** - no exceptions
- **No JavaScript in tests** - test the non-JS fallback behavior
- **Run tests immediately after editing** - run associated tests as soon as you edit a file
- **Never build up a backlog** - fix broken tests immediately, don't accumulate issues
- **NEVER delete tests unless 100% unnecessary** - fix rather than delete tests
- **Never delete tests that would reduce coverage** - always maintain or increase test coverage
- Use **Minitest** with **Shoulda-context** for descriptive test organization
- Use **Shoulda-matchers** for concise model/controller tests
- Use **Factory Bot** for test data creation
- Test both happy path and edge cases

#### Minitest with Shoulda Conventions

This project uses Minitest with Shoulda-context and Shoulda-matchers for testing:

**Model Tests** (in `test/models/`):

```ruby
class BandTest < ActiveSupport::TestCase
  # Shoulda-matchers for associations and validations
  should have_many :band_members
  should have_many :members
  should validate_presence_of(:name)
  
  setup do
    @band = create(:band)
  end
  
  context "validations" do
    should "be valid with valid attributes" do
      assert @band.valid?
    end
    
    should "not be deletable if has members" do
      refute @band.destroy
      assert_includes @band.errors.full_messages, "Cannot delete record"
    end
  end
  
  context "#url" do
    should "return correct url" do
      assert_equal edit_band_path(@band), @band.url
    end
  end
end
```

**Controller Tests** (in `test/controllers/`):

```ruby
class BandsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user_organiser)
    @band = create(:band, owner: @user)
  end
  
  context "#index" do
    context "when the user has bands" do
      should "get index" do
        log_in_as @user
        get bands_url
        assert_response :success
        assert assigns(:bands)
      end
    end
    
    context "when the user has no bands" do
      should "redirect to new band" do
        log_in_as create(:user)
        get bands_url
        assert_redirected_to new_band_url
      end
    end
  end
end
```

**Test Structure:**

- `setup` blocks for test data preparation
- `context` blocks for grouping related tests
- `should` blocks for individual test cases
- Use `assert` and `refute` for assertions
- Use `assert_response`, `assert_redirected_to` for controller tests
- `log_in_as` helper for authentication in integration tests

**IMPORTANT: Pattern Recognition & Batch Fixes**

- **When you spot a pattern** - use `grep` to find all occurrences
- **Fix similar issues together** - don't fix one-by-one when pattern is clear
- **Common patterns to batch-fix**:
  - Manual permission creation: `grep -r "create(:permission.*band:" test/`
  - Hardcoded strings: `grep -r '"Some Text"' test/`
  - Missing i18n: `grep -r 'assert_match "' test/`
  - Setup duplication: `grep -r "setup do" test/`
- **Always verify pattern** - check a few examples before batch fixing
- **Use tools efficiently** - `cut`, `sort`, `uniq` to identify affected files

#### What's Already Tested (Avoid Duplication)

- **Form i18n coverage**: Test files may use helper methods to verify ALL form sections and fields are rendered
- **Form i18n structure**: Tests validate form locale file structure
- **i18n usage tracking**: `lib/i18n_usage_tracker.rb` tracks all i18n key usage and finds unused keys
- **Helper methods available**: Commonly used test helpers for sign in, permission setup, etc.
- **DON'T write tests checking specific field presence** - if comprehensive i18n coverage tests exist

#### Helper Method Guidelines

- **Only extract helper methods when they add value**:
  - Used multiple times (DRY principle)
  - Hide genuinely complex logic that obscures test intent
  - Provide meaningful abstractions
- **Don't extract single-use methods** - if a method is only called once, it just splits logic unnecessarily
- **Keep test flow readable** - the test should tell a clear story without jumping to many helper methods
- **Inline simple expectations** - `expect(page).to have_content("text")` doesn't need a helper method

```ruby
# GOOD - Helper method used multiple times (already in test_helper.rb)
def log_in_as(user)
  post login_path, params: {
    user: {
      username: user.username,
      password: "password"
    }
  }
  follow_redirect!
end

# GOOD - Complex logic that helps readability
def grant_edit_permission(user, item)
  create(:permission, user: user, item: item, permission_type: :edit, status: :accepted)
end

# BAD - Single-use method that just splits logic
def assert_band_name_present(band)
  assert_match band.name, response.body
end

# GOOD - Just inline it instead
should "display band name" do
  get band_path(@band)
  assert_match @band.name, response.body
end
```

### Test Coverage Analysis

#### Coverage Targets & Reports

- **Coverage target**: 100% line and branch coverage for all files
- **HTML report**: `coverage/index.html` (detailed view with line-by-line coverage)
- **JSON data**: `coverage/.resultset.json` (raw coverage data from parallel test runs)
- **Coverage thresholds**:
  - Green (>90%): Good coverage
  - Yellow (80-90%): Needs improvement
  - Red (<80%): Poor coverage requiring immediate attention

#### Quick Coverage Commands

```bash
# Check coverage for a specific file (extracts from HTML report)
ruby coverage_check.rb app/models/band.rb
ruby coverage_check.rb app/controllers/bands_controller.rb

# View HTML report for detailed line-by-line analysis
# Open coverage/index.html in browser
```

#### Coverage Analysis Tool

**File Coverage Check** (`coverage_check.rb`):

- **Usage**: `ruby coverage_check.rb <file_path>`
- **Output**: Exact same figures as SimpleCov HTML report
- **Example output**:
  ```
  app/controllers/bands_controller.rb: 86.21% lines covered
  87 relevant lines. 75 lines covered and 12 lines missed.
  76.67% branches covered
  30 total branches, 23 branches covered and 7 branches missed.
  ```
- **Use when**: Checking coverage after editing a specific file

#### Coverage Workflow

1. **After editing a file**: Run `ruby coverage_check.rb <file_path>` to check coverage
2. **Before committing**: Ensure no coverage regression
3. **When coverage drops**: Write tests for uncovered lines immediately
4. **Focus areas**: Controllers, services, models (business logic)
5. **HTML report**: Use for detailed line-by-line analysis when needed

#### Coverage Standards

- **Target**: >90% line coverage, >80% branch coverage for all files
- **Priority files**: Controllers, services, models with business logic
- **Low coverage files**: Immediate attention required for < 80% coverage

### Code Organization

- **Create partials for repeated code** - DRY principle
- Extract common view code into partials immediately
- Use semantic naming for partials: `_band_details.haml`
- Keep partials focused on a single responsibility

### HTML & CSS Philosophy

- **Semantic HTML only** - use proper tags for their intended purpose
- **ABSOLUTELY NO CSS classes** - I hate CSS classes, never use them
- **NO class attributes at all** - rely entirely on semantic selectors
- **NO inline styles** - add CSS to dedicated CSS files using semantic selectors
- Use MVP.css framework's semantic styling only
- Structure: `<article>`, `<header>`, `<nav>`, `<main>` (avoid `<section>`)
- Forms: `<fieldset>`, `<legend>`, proper `<label>` associations
- Tables: `<thead>`, `<tbody>`, `<th>` with proper scope
- Buttons: use `<button>` or `<input type="submit">` without any classes

### Code Quality Standards

- **No defensive coding** - expect correct data, let it fail if wrong
- **No fallbacks** - if data is missing, that's an error to fix
- **Trust our own interfaces** - avoid `respond_to?` checks for methods we control; we know what our objects support
- **ABSOLUTELY NO hardcoded strings** - every user-facing string must use I18n, no exceptions
- **ABSOLUTELY NO unused methods** - delete any method that isn't called; unused code is technical debt
- **Update old code** - don't support legacy patterns, refactor to new standards
- **Use modern Ruby syntax** - leverage Ruby 3.0+ features for cleaner, more expressive code
- **Prioritise readability** - choose the newest, tidiest syntax that improves code clarity
- **Prefer to crash than quietly fail** - raise exceptions for error conditions, don't return false/nil
- Fix the root cause, not the symptom
- Explicit is better than implicit

### Development Philosophy & Architecture

### Frontend & UI Principles

- **Progressive enhancement** - HTML first, enhance with Turbo
- **Turbo-first** - use Turbo for form submissions and navigation
  - Use `data: { turbo_method: :patch }` instead of old Rails UJS
  - Use `data: { turbo_confirm: "message" }` for confirmations
  - Auto-submit forms with `onchange: "this.form.submit();"`
- **Accessibility** - proper labels, ARIA where needed, keyboard navigation

### Database & Models

- Use descriptive field names: `start_date` not `start`
- Write validations for data integrity
- Use scopes for complex queries: `Band.future_events`
- Make private helper methods for cleaner public interfaces
- Always validate associations and required fields

### Controllers & Business Logic

- Keep controllers thin - delegate to models/services
- Use semantic parameter names: "view", "edit", "all" not true/false strings
- Use proper HTTP methods (PATCH for updates, not GET)
- Let errors bubble up - don't rescue unless you can handle it properly
- Use Rails conventions - don't reinvent the wheel

### Code Style Guidelines

- Uses Standard Ruby for formatting (standardrb)
- Models: singular, CamelCase (Band)
- Controllers: plural, CamelCase (BandsController)
- Files/methods/variables: snake_case
- Constants: SCREAMING_SNAKE_CASE
- Service objects for complex business logic
- ActiveRecord validations for data integrity
- Error handling with begin/rescue with specific error messages
- Flash messages for user-facing errors

### Modern Ruby Syntax Preferences (Ruby 3.0+)

**Always prefer the newest, tidiest syntax available:**

- **Endless methods** for simple computation: `def member_count = members.count`
- **Hash shorthand** when key matches method: `{name:, description:}`
- **Numbered parameters** in simple blocks: `map { _1.upcase }`
- **Pattern matching** for complex dispatch: `case type in "band" then ...`
- **Rightward assignment** for clarity: `(a * b) => result`
- **Enhanced safe navigation**: `value&.method&.chain || default`
- **Modern enumerable methods**: `Hash#except`, `Enumerable#filter_map`

**Critical principle: Avoid unnecessary methods:**

- **Never create methods that just return constants** - use the constant directly
- **Use I18n for all user-facing strings** - no hardcoded English text
- **Endless methods should perform computation** - not just return static values

**String Interpolation Rule:**

- **Extract variables for complex interpolations** - nothing more complex than a single word with underscores should appear between `#{}` brackets
- Extract `#{hash[:key]}`, `#{object.method}`, `#{complex + calculation}` to variables first
- Keep simple: `#{variable}`, `#{method_name}`, `#{simple_var}`

**When refactoring, always upgrade to modern syntax** - don't maintain legacy patterns for compatibility

## Rails Style Guide & Code Standards

### Line Length & Formatting Standards (80 chars max)

**Breaking Long Lines (StandardRB Compatible):**

StandardRB will collapse excess whitespace, so use minimal formatting:

```ruby
# GOOD - Arrays/hashes: alphabetical order when order doesn't matter
ALLOWED_TYPES = %i[admin member organiser]  # Alphabetical, under 80 chars

# GOOD - Break one per line when over 80 chars, maintain alphabetical order
PERMISSION_STATUSES = %i[
  accepted
  owned
  pending
  rejected
]

# GOOD - Method calls: extract variables instead of parameter alignment
permission_params = { user: user, item: band, permission_type: :edit }
create(:permission, permission_params)

# GOOD - Use Ruby shorthand hash syntax when key matches method name
def attributes
  {name:, description:, start_date:, end_date:}
end

# BAD - Redundant explicit assignment
def attributes
  {name: name, description: description}
end

# GOOD - Use endless methods for simple one-liners (Ruby 3.0+)
def total_members = members.count
def has_future_events? = events.future.any?

# BAD - Traditional method definition for simple cases
def total_members
  members.count
end

# GOOD - Use numbered parameters in blocks (Ruby 2.7+)
bands.map { _1.name }
permissions.select { _1.accepted? }

# BAD - Unnecessary block parameter names
bands.map { |band| band.name }
permissions.select { |perm| perm.accepted? }

# GOOD - Pattern matching for complex dispatch (Ruby 3.0+)
case permission_type
in "view" then can_view_item?
in "edit" then can_edit_item?
else false
end

# GOOD - Long strings: extract to variables (NEVER use backslash continuation)
error_msg = "User does not have permission to access this band"

# GOOD - Comments: break at sentence boundaries (StandardRB preserves these)
# This method handles the complex permission logic for bands.
# It checks both direct permissions and inherited permissions.

# GOOD - SQL queries: use heredoc with line breaks before OR/AND
scope :search, ->(query) {
  if query.present?
    search_term = "%#{query}%"
    where(<<~SQL, search_term, search_term)
      name LIKE ?
      OR description LIKE ?
    SQL
  else
    all
  end
}

# BAD - All on one line when over 80 chars
LONG_ARRAY = [:pending, :accepted, :rejected, :owned, :archived]
```

**Array Ordering & Length Rules:**

```ruby
# GOOD - Alphabetical order when order doesn't matter
validates :email, :username, presence: true
USER_TYPES = %i[admin member organiser]

# GOOD - One per line when over 80 chars, alphabetical order
before_action :set_band, only: %i[
  destroy
  edit
  show
  update
]

# BAD - Random order, hard to scan
USER_TYPES = %i[member admin organiser]
```

### Method Design Principles

- **Maximum 20 lines per method** - if longer, extract private methods or delegate to other objects
- **Single responsibility** - each method should do one thing well
- **Descriptive names** - `grant_edit_permission` not `grant_perm` or `add_permission`
- **No deep nesting** - use guard clauses and early returns
- **Extract complex conditions** - use predicate methods like `user.can_edit_band?`

### Comments Policy

- **Only comment WHY, never WHAT** - code should be self-explanatory about what it does
- **Comments explain business context** - permission inheritance, edge cases, non-obvious decisions
- **No redundant comments** - `user.save # saves the user` is pointless
- **Self-documenting code first** - use descriptive method/variable names instead of comments
- **Remove outdated comments** - incorrect comments are worse than no comments
- **Use British English** - in comments, variable names, and method names (colour not color, organised not organized)

### Object-Oriented Design

- **Fat models, skinny controllers** - business logic belongs in models
- **Use service objects** for complex operations that span multiple models
- **Value objects** for data that doesn't belong in the database (calculations, transformations)
- **Concerns for shared behavior** - but prefer composition over inheritance
- **Delegate appropriately** - `delegate :name, to: :band, prefix: true`

### DRY Principles (Done Right)

- **DRY code, not DRY tests** - test clarity trumps test brevity
- **Extract methods for business logic** - not just to reduce lines
- **Partial extraction** - when the same view logic appears 3+ times
- **Don't abstract too early** - wait until you see the pattern clearly
- **Readable duplication > clever abstraction** - if it makes tests harder to understand, don't do it

### Rails Conventions (Always Follow)

- **Use Rails idioms** - `find_by` not `where(...).first`
- **Leverage ActiveRecord** - scopes, validations, callbacks where appropriate
- **RESTful routes** - use Rails routing helpers, avoid custom routes unless necessary
- **Standard CRUD actions** - index, show, new, create, edit, update, destroy
- **Rails naming conventions** - no exceptions, update old code to match

### No Backwards Compatibility Code

- **Update all references** when changing method signatures
- **Refactor immediately** - don't leave deprecated code paths
- **Fix at the source** - don't work around old patterns
- **Consistent codebase** - all code should follow current standards
- **Delete unused code** - if it's not called, remove it

### Factory Design (Test Data)

- **Minimal factories** - only set required attributes and uniqueness constraints
- **Use traits for variations** - `:admin`, `:with_bands`, `:confirmed`
- **Factory inheritance** sparingly - prefer traits over factory hierarchies
- **Realistic but simple data** - "Test Band" not "The Beatles"
- **Avoid factory dependencies** - each factory should be independently creatable

### Method Length & Complexity Examples

```ruby
# GOOD - Short, focused methods
def add_member_to_band(member, band)
  band_member = band.band_members.build(member: member)
  if band_member.save
    notify_band_members(band, member)
    log_member_addition(band, member)
    true
  else
    false
  end
end

private

def notify_band_members(band, new_member)
  band.members.each do |member|
    UserMailer.member_added(member, new_member, band).deliver_later
  end
end

def log_member_addition(band, member)
  Rails.logger.info "Member #{member.name} added to band #{band.name}"
end

# BAD - Too long, multiple responsibilities
def add_member_and_handle_everything
  # 25+ lines of mixed concerns
end
```

### Object Usage Examples

```ruby
# GOOD - Service object for complex operations
class EventSchedulingService
  def initialize(event, bands)
    @event = event
    @bands = bands
  end

  def schedule
    validate_availability
    assign_bands_to_event
    create_notifications
    update_calendars
  end

  private
  # ... implementation
end

# Usage in controller
def create
  service = EventSchedulingService.new(@event, params[:band_ids])
  if service.schedule
    flash[:success] = t("events.messages.scheduled")
    redirect_to @event
  else
    render :new
  end
end
```

### Factory Examples

```ruby
# GOOD - Minimal factory
FactoryBot.define do
  factory :band do
    name { "Band #{rand(10000)}" }
    description { "A test band" }

    trait :with_members do
      after(:create) do |band|
        create_list(:member, 3, bands: [band])
      end
    end
  end

  factory :user do
    username { "user#{rand(10000)}" }
    email { "user#{rand(10000)}@example.com" }
    password { "password123" }

    trait :admin do
      user_type { :admin }
    end

    trait :confirmed do
      confirmed { true }
    end
  end
end

# BAD - Over-specified factory
FactoryBot.define do
  factory :band do
    name { "The Beatles" }
    description { "Famous rock band from Liverpool" }
    genre { "Rock" }
    founded_year { 1960 }
    # ... unnecessary details
  end
end
```

### Test Clarity Examples

```ruby
# GOOD - Clear test even with some duplication
class BandPermissionsTest < ActionDispatch::IntegrationTest
  context "band access control" do
    should "prevent viewing when user has no permission" do
      band = create(:band)
      user = create(:user)
      
      log_in_as user
      get band_path(band)
      
      assert_response :forbidden
      assert_match "You don't have permission", response.body
    end

    should "allow viewing when user has view permission" do
      band = create(:band)
      user = create(:user)
      create(:permission, user: user, item: band, permission_type: :view)
      
      log_in_as user
      get band_path(band)
      
      assert_response :success
      assert_match band.name, response.body
    end
  end
end

# BAD - DRY but unclear
class BandPermissionsTest < ActionDispatch::IntegrationTest
  setup do
    @band = create(:band)
    @user = create(:user)
  end
  
  [:view, nil].each do |perm_type|
    context "when permission is #{perm_type || 'none'}" do
      setup do
        if perm_type
          create(:permission, user: @user, item: @band, permission_type: perm_type)
        end
      end
      
      should "handle access appropriately" do
        # ... test logic that's hard to follow
      end
    end
  end
end
```

### Comments

## Good:

- Explains WHY, business context (British English)
- Explains non-obvious business rule
- British English in variable names
- No comment needed, method name is clear

## Bad:

- American English spelling
- Explains WHAT the code does (obvious)

## Established Patterns & Examples

### Testing Patterns

```ruby
# Integration tests with Minitest/Shoulda
class BandManagementTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, :confirmed)
    @band = create(:band)
    create(:permission, user: @user, item: @band, permission_type: :edit)
  end

  context "editing band details" do
    should "update band name and description" do
      log_in_as @user
      get edit_band_path(@band)
      assert_response :success
      
      patch band_path(@band), params: {
        band: {
          name: "New Band Name",
          description: "Updated description"
        }
      }
      
      assert_redirected_to band_path(@band)
      follow_redirect!
      assert_match I18n.t("bands.messages.updated"), flash[:success]
      
      @band.reload
      assert_equal "New Band Name", @band.name
      assert_equal "Updated description", @band.description
    end
  end
end

# Model tests with Shoulda matchers
class BandTest < ActiveSupport::TestCase
  should have_many(:permissions)
  should have_many(:members).through(:band_members)
  should validate_presence_of(:name)
  
  # Model scopes for clean queries
  # (defined in the model, tested here)
  context "scopes" do
    should "filter by permission for user" do
      user = create(:user)
      band_with_permission = create(:band)
      band_without_permission = create(:band)
      create(:permission, user: user, item: band_with_permission, status: :accepted)
      
      bands = Band.with_permission_for(user)
      assert_includes bands, band_with_permission
      refute_includes bands, band_without_permission
    end
  end
end
```

### Turbo Form Patterns

```erb
<!-- Auto-submit dropdown -->
<%= form_with url: bands_path, method: :get, data: { turbo: false } do |form| %>
  <%= form.select :filter,
      options_for_select([
        ["All Bands", "all"],
        [t('bands.filters.my_bands'), "mine"],
        [t('bands.filters.public'), "public"]
      ], params[:filter]),
      {}, { onchange: "this.form.submit();" } %>
<% end %>

<!-- Action links with Turbo -->
<%= link_to t('bands.buttons.remove_member'),
      band_member_path(band, member),
      data: {
        turbo_method: :delete,
        turbo_confirm: "Remove #{member.name} from #{band.name}?"
      } %>
```

### Controller Patterns

```ruby
# Clean, chainable scopes
def index
  @bands = Band
    .with_permission_for(current_user)
    .includes(:members, :events)
    .order(:name)
end

# Semantic parameter handling
def update_permission
  @permission = Permission.find(params[:id])
  @permission.update(status: params[:status])
  flash[:success] = t("permissions.messages.#{params[:status]}")
  redirect_to permissions_path
end
```

### Model Helper Methods (DRY)

```ruby
def can_edit?(user)
  permissions.exists?(
    user: user,
    permission_type: :edit,
    status: :accepted
  )
end

def can_view?(user)
  permissions.exists?(
    user: user,
    permission_type: [:view, :edit],
    status: :accepted
  )
end

private

def has_permission?(user, types)
  Array(types).any? do |type|
    permissions.exists?(
      user: user,
      permission_type: type,
      status: :accepted
    )
  end
end
```

### DRY View Partials

```erb
<!-- app/views/bands/_member_list.html.haml -->
%ul
  - band.members.each do |member|
    %li
      = link_to member.name, member_path(member)
      - if can_edit_band?(band)
        = link_to t('bands.buttons.remove'),
              band_member_path(band, member),
              data: { turbo_method: :delete }

<!-- Usage -->
= render 'member_list', band: @band
```

## Business Rules Examples

### User Access Control

- Users can only see bands/events/members they have permissions for
- Permissions can be view or edit level
- Permissions can be owned, pending, accepted, or rejected
- Organiser users can grant permissions to others
- Admin users have full system access

### Data Validation

- All forms validate required fields with clear error messages
- Band names must be unique
- Event end dates must be after start dates
- Email addresses are validated and downcased
- Usernames must be unique and alphanumeric

### UI/UX Patterns

- Default views show filtered data based on user permissions
- Use clear filter options: "all", "mine", "public"
- Confirmation dialogs for destructive actions
- Success/error flash messages for user feedback
- Calendar integration for event scheduling