Paperclip IPFS Storage
======================

This gem extends the [Paperclip](https://github.com/thoughtbot/paperclip) so that you can save file on [IPFS](https://ipfs.io/) network.

Installation
============

```bash
gem "paperclip-ipfs-storage"
```

or put it on the Gemfile.

Usage
=====

Add `attachment` type field into the schema as usual, then add `string` type field as `[field_name]_ipfs_hash`. For example:

```ruby
class CreateMediaAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :media_attachments do |t|
      t.attachment :file
      t.string :file_ipfs_hash, :file_ipfs_hash, null: true, default: nil
    end
  end
end
```

Then specify `:ipfs` for the `:storage` option and `':gateway_url'` for the `:url` in the model. For example:

```ruby
class MediaAttachment < ActiveRecord::Base
  has_attached_file :file,
    :storage => :ipfs,
    :url => ':gateway_url'
end
```

Limitation
==========

You cannot remove the file uploaded. This is due to the design of IPFS [^1].

[^1]: https://github.com/ipfs/faq/issues/9
