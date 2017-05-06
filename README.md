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

Specify `:ipfs` for the `:storage` option and `':gateway_url'` for the `:url`. For example:

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
