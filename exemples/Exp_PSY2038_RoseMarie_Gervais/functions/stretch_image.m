function stretch = stretch_image(im_name)

im = double(im_name);

stretch = (im-min(im(:)))/(max(im(:))-min(im(:)));


