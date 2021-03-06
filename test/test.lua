--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Created by: Hang Zhang
-- ECE Department, Rutgers University
-- Email: zhang.hang@rutgers.edu
-- Copyright (c) 2016
--
-- Feel free to reuse and distribute this software for research or 
-- non-profit purpose, subject to the following conditions:
--  1. The code must retain the above copyright notice, this list of
--     conditions.
--  2. Original authors' names are not deleted.
--  3. The authors' names are not used to endorse or promote products
--      derived from this software 
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

require "hzproc"
require 'image'
require 'math'

-- load the image
I = image.lena():cuda()
image.display(I)
img_width  = I:size(3)
img_height = I:size(2)

local function hzproc_testResize()
	local scale = 1.0/3;
	-- generating lookuptable for scaling
	local map = hzproc.Table.Resize(img_width, img_height, 
							img_width*scale, img_height*scale)
	-- mapping
	local O = hzproc.Remap.Bilinear(I, map)
	-- display the images
	image.display(O)
end

local function hzproc_testAffine()
	-- affine transformation matrix
	local mat = hzproc.Affine.RotateArround(-math.pi/8, img_width/2, img_height/2)
	mat = mat * hzproc.Affine.Scale(1.2, 0.8)
	mat = mat * hzproc.Affine.Shear(0.5, 0.2)
	mat = mat * hzproc.Affine.Shift(-0.1*img_width, -0.1*img_height)
	-- affine mapping
	local O = hzproc.Transform.Fast(I, mat);
	-- display the images
	image.display(O)
end

local function hzproc_testMat2Tab()
	local mat = torch.CudaTensor({{1,0,0},{0.3,1,0},{0,0,1}})
	-- affine to table
	local map = hzproc.Transform.ToTable(mat, img_width, img_height)
	-- mapping
	local O = hzproc.Remap.Fast(I, map)
	-- display the images
	image.display(O)
end

local function hzproc_testPadding()
	local scale = 2.0/3;
	-- generating lookuptable for scaling
	local map1 = hzproc.Table.Flip(img_width, img_height)
	scale = 1.3;
	-- generating lookuptable for padding
	local map2 = hzproc.Table.Pad(map1:size(3), map1:size(2),
							img_width*scale, img_height*scale)
	local map = hzproc.Remap.Combine(map1, map2)
	-- mapping
	local O = hzproc.Remap.Fast(I, map)
	-- display the images
	image.display(O)
end

local function hzproc_testCroping()
	local scale  = 0.6;
	local offset = (1-scale) / 2;
	-- generating lookuptable for cropping
	local map = hzproc.Table.Crop(img_width, img_height, 
							img_width*scale, img_height*scale, 
							img_width*offset, img_height*offset)
	-- mapping
	local O = hzproc.Remap.Fast(I, map)
	-- display the images
	image.display(O)
end

function hzproc_test()
	hzproc_testResize()	
	hzproc_testAffine()
	hzproc_testPadding()
	hzproc_testCroping()
	hzproc_testMat2Tab()
end

hzproc_test()
