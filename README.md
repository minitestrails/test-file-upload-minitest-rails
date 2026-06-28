# Sample app for testing file uploads with Minitest Rails

Sample Rails app for a [blog post](https://minitestrails.com/blog/testing-file-uploads-rails-minitest) on testing [Active Storage](https://guides.rubyonrails.org/active_storage_overview.html) file uploads with Minitest. It demonstrates how to test uploads across model, integration, and system layers without hitting S3 or any cloud storage in CI.

## Prerequisites

- Ruby 4.0.2 (see `.ruby-version`)
- Rails 8.1.3
- Minitest 6.0.6
- SQLite (default Rails 8 database)
- Chrome or Chromium (system tests only)

## Local setup

```bash
git clone git@github.com:minitestrails/test-file-upload-minitest-rails.git
cd test-file-upload-minitest-rails
bin/setup --skip-server
```

Start the server:

```bash
bin/rails server
```

Visit [http://localhost:3000](http://localhost:3000) to browse recipes and upload photos on create/edit.

## App structure

| Piece | Notes |
|-------|-------|
| `Recipe` | `title` (required), `description`, `servings`, `prep_time` (positive if present) |
| `has_one_attached :photo` | JPEG/PNG only; multipart form on new/edit |
| Active Storage | `:local` in development, `:test` in test (`tmp/storage`) |
| `test_fixtures` service | Separate disk root for fixture attachments (`tmp/storage_fixtures`) |
| `test/fixtures/files/sample.jpg` | Committed JPEG for upload tests |
| `test/fixtures/files/sample.txt` | Used to assert disallowed content types |
| `test/support/upload_test_helper.rb` | `sample_photo_upload` wraps `file_fixture_upload` |

For the bare-minimum Recipe app without uploads, see [`docs/recipe-app-setup.md`](docs/recipe-app-setup.md).

## Tests

The suite exercises file uploads **without cloud storage**. Active Storage's `:test` service writes to disk under `tmp/storage`. No AWS or GCS credentials are needed in CI.

See the [blog post](https://minitestrails.com/blog/testing-file-uploads-rails-minitest) for the full walkthrough. This repo is the companion sample app.

### Setup

`config/environments/test.rb` points Active Storage at the `:test` service:

```ruby
config.active_storage.service = :test
```

`config/storage.yml` defines a separate `test_fixtures` service so fixture attachments stay apart from files uploaded during a test:

```yaml
test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

`test/test_helper.rb` loads support files and includes `UploadTestHelper`:

```ruby
Dir[Rails.root.join("test/support/**/*.rb")].sort.each { |f| require f }

module ActiveSupport
  class TestCase
    include UploadTestHelper
  end
end
```

Active Storage fixture attachments preload a photo on `recipes(:pancakes)`:

```yaml
# test/fixtures/active_storage/attachments.yml
pancakes_with_photo:
  name: photo
  record: pancakes (Recipe)
  blob: pancakes_photo_blob
```

```yaml
# test/fixtures/active_storage/blobs.yml
pancakes_photo_blob: <%= ActiveStorage::FixtureSet.blob filename: "sample.jpg", service_name: "test_fixtures" %>
```

### What is covered

| File | What it proves |
|------|----------------|
| `test/models/recipe_test.rb` | Title/servings/prep_time validations; attach with `file_fixture`; rejects disallowed content type; pancakes fixture has a preloaded photo |
| `test/integration/recipes_integration_test.rb` | Recipe CRUD over HTTP; multipart create with `file_fixture_upload`; photo replace on update |
| `test/system/recipes_test.rb` | Browser smoke for list, show, create, update, destroy; `attach_file` on create |

Most confidence comes from **model + integration** tests. The system test adds one happy-path upload smoke with a real file input.

### Run tests

```bash
# Model + integration
bin/rails test

# Everything including system tests (requires Chrome)
bin/rails test:all

# By layer
bin/rails test test/models/
bin/rails test test/integration/
bin/rails test:system
```

## What this app demonstrates

File upload testing splits cleanly by layer:

| Test type | Good for |
|-----------|----------|
| Model | Validations on type, `attach`/`purge` on the model, fixture preloads |
| Integration | Multipart POST through the controller, redirect, DB + attachment |
| System | Optional: file input in a real browser (smoke only) |

Patterns used in this repo:

- **Model:** `file_fixture("sample.jpg")` + `attach`, then assert `attached?`, filename, and content type
- **Integration:** `file_fixture_upload` (via `sample_photo_upload`) in a multipart POST, then assert redirect and attachment on the record
- **Fixtures:** Active Storage YAML fixtures for records that already have a photo before the test runs
- **System:** Capybara `attach_file` for one browser smoke

Direct uploads to S3 and virus-scan callbacks are out of scope. Test the server-side attach path first.
