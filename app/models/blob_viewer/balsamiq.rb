module BlobViewer
  class Balsamiq < Base
    include Rich
    include ClientSide

    self.partial_name = 'balsamiq'
    self.extensions = %w(bmpr)
    self.binary = true
    self.switcher_icon = 'file-image-o'
    self.switcher_title = 'preview'
  end
end
