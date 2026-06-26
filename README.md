# Sample app for testing file uploads with Minitest Rails

Sample Rails app for a [blog post](https://minitestrails.com/blog/testing-file-uploads-rails-minitest) on testing [Active Storage](https://guides.rubyonrails.org/active_storage_overview.html) file uploads with Minitest. It demonstrates how to test uploads across model, integration, and (optional) system layers without hitting S3 or any cloud storage in CI.

## Prerequisites

- Ruby 4.0.2 (see `.ruby-version`)
- Rails 8.1.3
- Minitest 6.0.6
- SQLite (default Rails 8 database)

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
| `Recipe` | `title` (required), `description`, `servings`, `prep_time` (rejects negatives) |
| `has_one_attached :photo` | JPEG/PNG only; multipart form on new/edit |
| Active Storage | `:local` in development, `:test` in test (`tmp/storage`) |
| `test/fixtures/files/sample.png` | Committed fixture file for upload tests |

Upload tests from the blog post land on the `test-file-upload` branch in [PR #4](https://github.com/minitestrails/test-file-upload-minitest-rails/pull/4).

## What this app demonstrates

File upload testing splits cleanly by layer. The blog post and this app cover each one:

| Test type | Good for |
|-----------|----------|
| Model | Validations on type/size, `attach`/`purge` on the model |
| Integration | Multipart POST through the controller, redirect, DB + attachment |
| System | Optional: a real file input in the browser (smoke only) |

Most confidence comes from **model + integration** tests. System tests are reserved for one happy-path smoke check.

## How it works

- The test environment uses Active Storage's `:test` service, which writes to `tmp/storage` (see `config/storage.yml` and `config/environments/test.rb`). No AWS or GCS credentials are needed in CI.
- Sample upload files live in `test/fixtures/files/` (e.g. `sample.png`) and are committed so CI can run the suite.
- Model tests attach files with `file_fixture` + `attach`, then assert `attached?`, filename, and content type.
- Integration tests post a multipart form with `file_fixture_upload`, then assert the redirect and the attachment on the record.
- Files uploaded during integration and system tests are cleaned up in an `after_teardown` callback, since Active Storage does not purge them automatically on rollback.

## Run tests

```bash
# Full suite
bin/rails test

# Full suite (with system tests)
bin/rails test:all

# Model tests only
bin/rails test test/models/

# Integration tests only
bin/rails test test/integration/

# Optional system smoke test (requires Chrome)
bin/rails test:system
```

See the [blog post](https://minitestrails.com/blog/testing-file-uploads-rails-minitest) for the full walkthrough. This repo is the companion sample app.
