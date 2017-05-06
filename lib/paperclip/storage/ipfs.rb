# coding: utf-8
# frozen_string_literal: true

require 'tempfile'

module Paperclip
  module Storage
    module Ipfs
      def self.extended(base)
        begin
          require 'ipfs-api'
        rescue LoadError => e
          e.message << '(You may need to install the ipfs-api gem)'
          raise e
        end

        base.instance_eval do
          @api_url = @options[:ipfs_api_url] || 'http://127.0.0.1:5001'
          @ipfs = IPFS::Connection.new(@api_url)
        end

        Paperclip.interpolates(:item_hash) do |attachment, _|
          attachment.hash
        end
        Paperclip.interpolates(:directory) do |attachment, style_name|
          attachment.directory style_name
        end
        Paperclip.interpolates(:gateway_url) do |attachment, style_name|
          attachment.gateway_url style_name
        end
      end

      def hash
        instance_read('ipfs_hash'.to_sym)
      end

      def directory(style_name = default_style)
        "#{hash}/#{style_name}"
      end

      def gateway_url(style_name = default_style)
        filename = Paperclip::Interpolations.filename(self, style_name.to_sym)
        "https://gateway.ipfs.io/ipfs/#{directory style_name}/#{filename}"
      end

      def exists?(style_name = default_style)
        hash(style_name).present?
      end

      def copy_to_local_file(style_name = default_style, destination_path)
        File.open(destination_path, 'wb') do |fd|
          if @queued_for_write[style_name]
            IO.copy_stream(@queued_for_write[style_name], fd)
          else
            directory = directory(style_name)
            filename = Paperclip::Interpolations.filename(self, style_name.to_sym)
            fd.write(@ipfs.cat("#{directory}/#{filename}"))
          end
        end
      end

      def flush_writes #:nodoc:
        return if @queued_for_write.empty?

        Dir.mktmpdir do |tempdir|
          Dir.chdir(tempdir) do
            @attr = queued_for_write.each do |style_name, file|
              Dir.mkdir(style_name.to_s)
              File.open(Pathname.new(style_name.to_s).join(original_filename), 'wb') do |fd|
                IO.copy_stream(file, fd)
              end
            end
          end
          @ipfs.add Dir.new(tempdir) do |node|
            if node.name == File.basename(tempdir)
              instance_write('ipfs_hash'.to_sym, node.hash)
            end
          end
        end

        after_flush_writes
        @queued_for_write.clear
        instance.save
      end

      def flush_deletes #:nodoc:
        log('deleting is not supported on IPFS')
        @queued_for_delete.clear
      end
    end
  end
end
