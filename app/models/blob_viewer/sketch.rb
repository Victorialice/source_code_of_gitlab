module BlobViewer
  class Sketch < Base
    include Rich
    include ClientSide

    self.partial_name = 'sketch'
    self.extensions = %w(sketch)
    self.binary = true
    self.switcher_icon = 'file-image-o'
    self.switcher_title = 'preview'
  end
end
