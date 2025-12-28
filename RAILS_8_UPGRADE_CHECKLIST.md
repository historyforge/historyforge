# Rails 8 Upgrade Checklist

## Current State
- **Rails Version**: 7.2.2.2
- **Ruby Version**: 3.4.5 ✅ (Rails 8 requires Ruby 3.2+)
- **Framework Defaults**: 7.0 (needs update to 8.0)

## Critical Issues to Address

### 1. Configuration Updates

#### 1.1 Framework Defaults
**File**: `config/application.rb:32`
- **Current**: `config.load_defaults 7.0`
- **Action**: Update to `config.load_defaults 8.0`
- **Note**: You may want to incrementally upgrade through 7.1 and 7.2 defaults first

#### 1.2 Deprecated Configuration
**File**: `config/application.rb:49`
- **Issue**: `config.quiet_assets = true` is deprecated in Rails 8
- **Action**: Remove this line (no longer needed)

**File**: `config/environments/development.rb:59`
- **Issue**: `config.assets.quiet = true` is deprecated
- **Action**: Remove this line

### 2. Controller Deprecations

#### 2.1 Class-level `respond_to` Declarations
**Files Affected**:
- `app/controllers/census_records/main_controller.rb:14-16`
- `app/controllers/buildings/main_controller.rb:21-23`
- `app/controllers/users/sessions_controller.rb:6`

**Issue**: Class-level `respond_to` is deprecated in Rails 8. Use instance-level `respond_to` blocks instead.

**Example Fix**:
```ruby
# Before (deprecated):
respond_to :json, only: :index
respond_to :csv, only: :index
respond_to :html

# After (Rails 8):
def index
  respond_to do |format|
    format.html
    format.json { ... }
    format.csv { ... }
  end
end
```

**Files to Update**:
- `app/controllers/census_records/main_controller.rb` (lines 14-16)
- `app/controllers/buildings/main_controller.rb` (lines 21-23)
- `app/controllers/users/sessions_controller.rb` (line 6)

### 3. Active Record Patterns

#### 3.1 `.attributes =` Assignment
**Issue**: While not deprecated, prefer `assign_attributes` or `update` for clarity and consistency.

**Files Affected**:
- `app/controllers/media_controller.rb:65`
- `app/controllers/flags_controller.rb:44`
- `app/controllers/census_records/main_controller.rb:46`
- `app/controllers/census_records/bulk_updates_controller.rb:28, 39`

**Recommendation**: Consider refactoring to use `assign_attributes`:
```ruby
# Current:
@asset.attributes = resource_params

# Preferred:
@asset.assign_attributes(resource_params)
```

#### 3.2 `find_by_sql` Usage
**File**: `app/services/census_stats.rb:19, 35`
- **Status**: Still works in Rails 8, but consider if there's a better Active Record approach
- **Action**: Review and potentially refactor if possible

### 4. Gem Compatibility

#### 4.1 Critical Gems to Verify
Check compatibility with Rails 8:
- `devise` - Verify Rails 8 compatibility
- `cancancan` - Check for Rails 8 updates
- `paper_trail` - Verify compatibility
- `ransack` - Check Rails 8 support
- `kaminari` - Verify compatibility
- `sassc` - **DEPRECATED**: Consider migrating to `dartsass-rails` or `sass-embedded`
- `sprockets-rails` - Still supported but Rails 8 prefers Propshaft

#### 4.2 Asset Pipeline Considerations
- **Current**: Using `sprockets-rails` and `sassc`
- **Rails 8**: Prefers Propshaft for assets
- **Action**: Consider migrating to Propshaft or ensure Sprockets compatibility

### 5. Environment Configuration

#### 5.1 Active Job Configuration
**Files**: `config/environments/*.rb`
- Current: Using `:inline` adapter
- **Rails 8**: Consider using Solid Queue (built-in) or Solid Cache
- **Action**: Review Active Job configuration

#### 5.2 Deprecation Warnings
**File**: `config/environments/production.rb:74`
- Current: `config.active_support.report_deprecations = false`
- **Action**: Set to `true` temporarily during upgrade to catch issues

### 6. Testing Considerations

#### 6.1 Test Framework
- Using RSpec ✅ (compatible with Rails 8)
- Ensure `rspec-rails` is updated to latest version

#### 6.2 Test Configuration
**File**: `config/environments/test.rb`
- Review test configuration for Rails 8 changes
- Check `config.action_controller.raise_on_missing_callback_actions = true` (already set ✅)

### 7. Migration Path Recommendations

#### Step 1: Update Framework Defaults Incrementally
1. First, update to `config.load_defaults 7.1`
2. Then update to `config.load_defaults 7.2`
3. Finally update to `config.load_defaults 8.0`

#### Step 2: Update Gems
1. Update Rails to latest 7.2.x patch version first
2. Update all gems to latest compatible versions
3. Check for Rails 8 compatible versions
4. Update Rails to 8.0

#### Step 3: Fix Deprecations
1. Remove `config.quiet_assets`
2. Convert class-level `respond_to` to instance-level
3. Review and update `.attributes =` usage

#### Step 4: Run Tests
1. Run full test suite
2. Address any failures
3. Check for deprecation warnings

#### Step 5: Update Configuration
1. Run `rails app:update` to get new Rails 8 config files
2. Carefully merge changes with existing configuration
3. Review new framework defaults initializer

### 8. Rails 8 New Features to Consider

#### 8.1 Solid Queue (Built-in Job Queue)
- Consider migrating from `:inline` to Solid Queue
- No external dependencies required

#### 8.2 Solid Cache (Built-in Cache Store)
- Consider using Solid Cache instead of current cache store
- Database-backed caching without Redis

#### 8.3 Propshaft (Asset Pipeline)
- Consider migrating from Sprockets to Propshaft
- Simpler and faster asset pipeline

### 9. Files Requiring Immediate Attention

**High Priority**:
1. `config/application.rb` - Update `load_defaults` and remove `quiet_assets`
2. `app/controllers/census_records/main_controller.rb` - Fix `respond_to`
3. `app/controllers/buildings/main_controller.rb` - Fix `respond_to`
4. `app/controllers/users/sessions_controller.rb` - Fix `respond_to`
5. `config/environments/development.rb` - Remove `config.assets.quiet`

**Medium Priority**:
6. `app/controllers/media_controller.rb` - Consider `assign_attributes`
7. `app/controllers/flags_controller.rb` - Consider `assign_attributes`
8. `app/controllers/census_records/bulk_updates_controller.rb` - Consider `assign_attributes`
9. `Gemfile` - Review gem versions for Rails 8 compatibility

**Low Priority**:
10. `app/services/census_stats.rb` - Review `find_by_sql` usage
11. Consider migrating from Sprockets to Propshaft
12. Consider migrating from `sassc` to `dartsass-rails`

### 10. Pre-Upgrade Checklist

- [ ] Backup database
- [ ] Ensure test suite passes on current Rails version
- [ ] Review and update all gem versions
- [ ] Check for Rails 8 compatible versions of all gems
- [ ] Review Rails 8 release notes and upgrade guide
- [ ] Set up staging environment for testing
- [ ] Enable deprecation warnings in development

### 11. Post-Upgrade Checklist

- [ ] Run full test suite
- [ ] Check for deprecation warnings
- [ ] Review application logs for errors
- [ ] Test critical user flows
- [ ] Verify Active Storage functionality
- [ ] Verify Active Job functionality
- [ ] Check asset compilation
- [ ] Review performance metrics
- [ ] Update documentation

## Additional Notes

- Ruby 3.4.5 is compatible with Rails 8 ✅
- The codebase follows good Rails conventions
- Most patterns are already compatible with Rails 8
- Main issues are configuration and deprecated `respond_to` usage

## Resources

- [Rails 8 Release Notes](https://edgeguides.rubyonrails.org/8_0_release_notes.html)
- [Rails Upgrade Guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html)
- [Rails 8 Upgrade Guide](https://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-7-2-to-rails-8-0)

