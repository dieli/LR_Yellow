--[[----------------------------------------------------------------------------

FTP Upload for Yellow CMS, based on the Adobe Sample plugin (see below). Copyright
for the original part is by Adobe, rest of the code is under GPL.

FtpUploadExportServiceProvider.lua
Export service provider description for Lightroom FtpUpload uploader

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

-- FtpUpload plug-in
require "FtpUploadExportDialogSections"
require "FtpUploadTask"


--============================================================================--

return {

	hideSections = { 'exportLocation' },

	allowFileFormats = nil, -- nil equates to all available formats

	allowColorSpaces = nil, -- nil equates to all color spaces

	exportPresetFields = {
		{ key = 'putInSubfolder_image', default = false },
		{ key = 'putInSubfolder_blog', default = false },
		{ key = 'path_image', default = '/media/images/' },
		{ key = 'path_blog', default = '/content/3-blog/' },
		{ key = "ftpPreset", default = nil },
		{ key = "fullPath_image", default = nil },
		{ key = "fullPath_blog", default = nil },
		{ key = "blog_author", default = 'tester' },
		{ key = "blog_title", default = 'new' },
		{ key = "blog_tag", default = "" },
		{ key = "blog_thumbsize", default = "150" },
		{ key = "blog_text", default = "Your text here ...\n		[--more--]\n		The link to the pics" },

	},

	startDialog = FtpUploadExportDialogSections.startDialog,
	sectionsForBottomOfDialog = FtpUploadExportDialogSections.sectionsForBottomOfDialog,

	processRenderedPhotos = FtpUploadTask.processRenderedPhotos,

}
