--[[----------------------------------------------------------------------------

FTP Upload for Yellow CMS, based on the Adobe Sample plugin (see below). Copyright
for the original part is by Adobe, rest of the code is under GPL.

FtpUploadExportDialogSections.lua
Export dialog customization for Lightroom FTP uploader

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

-- Lightroom SDK
local LrView = import 'LrView'
local LrFtp = import 'LrFtp'

--============================================================================--

FtpUploadExportDialogSections = {}

-------------------------------------------------------------------------------

local function updateExportStatus( propertyTable )

	local message = nil

	repeat
		-- Use a repeat loop to allow easy way to "break" out.
		-- (It only goes through once.)

		if propertyTable.ftpPreset == nil then
			message = LOC "$$$/FtpUpload/ExportDialog/Messages/SelectPreset=Select or Create an FTP preset"
			break
		end

		if propertyTable.putInSubfolder_image and ( propertyTable.path_image == "" or propertyTable.path_image == nil ) then
			message = LOC "$$$/FtpUpload/ExportDialog/Messages/EnterSubPath=Enter a destination path for images"
			break
		end
		if propertyTable.putInSubfolder_blog and ( propertyTable.path_blog == "" or propertyTable.path_blog == nil ) then
			message = LOC "$$$/FtpUpload/ExportDialog/Messages/EnterSubPath=Enter a destination path for blog"
			break
		end

		local fullPath_image = propertyTable.ftpPreset.path_image or ""
		local fullPath_blog = propertyTable.ftpPreset.path_blog or ""

		if propertyTable.putInSubfolder_image then
			fullPath_image = LrFtp.appendFtpPaths( fullPath_image, propertyTable.path_image )
		end
		if propertyTable.putInSubfolder_blog then
			fullPath_blog = LrFtp.appendFtpPaths( fullPath_blog, propertyTable.path_blog )
		end

		propertyTable.fullPath_blog  = fullPath_blog
		propertyTable.fullPath_image = fullPath_image

	until true

	if message then
		propertyTable.message = message
		propertyTable.hasError = true
		propertyTable.hasNoError = false
		propertyTable.LR_cantExportBecause = message
	else
		propertyTable.message = nil
		propertyTable.hasError = false
		propertyTable.hasNoError = true
		propertyTable.LR_cantExportBecause = nil
	end

end

-------------------------------------------------------------------------------

function FtpUploadExportDialogSections.startDialog( propertyTable )

	propertyTable:addObserver( 'items', updateExportStatus )
	propertyTable:addObserver( 'path_image', updateExportStatus )
	propertyTable:addObserver( 'path_blog', updateExportStatus )
	propertyTable:addObserver( 'putInSubfolder_image', updateExportStatus )
	propertyTable:addObserver( 'putInSubfolder_blog', updateExportStatus )
	propertyTable:addObserver( 'ftpPreset', updateExportStatus )

	updateExportStatus( propertyTable )

end

-------------------------------------------------------------------------------

function FtpUploadExportDialogSections.sectionsForBottomOfDialog( _, propertyTable )

	local f = LrView.osFactory()
	local bind = LrView.bind
	local share = LrView.share
	local LrFtp = import 'LrFtp'

	local result = {

		{
			title = LOC "$$$/FtpUpload/ExportDialog/FtpSettings=FTP Server",

			synopsis = bind { key = 'fullPath_image', object = propertyTable },
			synopsis = bind { key = 'fullPath_blog', object = propertyTable },

			f:row {
				f:static_text {
					title = LOC "$$$/FtpUpload/ExportDialog/Destination=Destination:",
					alignment = 'right',
					width = share 'labelWidth'
				},

				LrFtp.makeFtpPresetPopup {
					factory = f,
					properties = propertyTable,
					valueBinding = 'ftpPreset',
					itemsBinding = 'items',
					fill_horizontal = 1,
				},
			},

			f:row {
				f:spacer {
					width = share 'labelWidth'
				},

				f:checkbox {
					title = LOC "$$$/FtpUpload/ExportDialog/PutInSubfolder_image=Subfolder for images:",
					value = bind 'putInSubfolder_image',
				},

				f:edit_field {
					value = bind 'path_image',
					enabled = bind 'putInSubfolder_image',
					validate = LrFtp.ftpPathValidator,
					truncation = 'middle',
					immediate = true,
					fill_horizontal = 1,
				},
			},

			f:column {
				place = 'overlapping',
				fill_horizontal = 1,

				f:row {
					f:static_text {
						title = LOC "$$$/FtpUpload/ExportDialog/FullPath_image=Full Path for images:",
						alignment = 'right',
						width = share 'labelWidth',
						visible = bind 'hasNoError',
					},

					f:static_text {
						fill_horizontal = 1,
						width_in_chars = 20,
						title = bind 'fullPath_image',
						visible = bind 'hasNoError',
					},
				},

				f:row {
					f:static_text {
						fill_horizontal = 1,
						title = bind 'message',
						visible = bind 'hasError',
					},
				},
			},

			f:row {
				f:spacer {
					width = share 'labelWidth'
				},

				f:checkbox {
					title = LOC "$$$/FtpUpload/ExportDialog/PutInSubfolder_blog=Subfolder for Blog:",
					value = bind 'putInSubfolder_blog',
				},

				f:edit_field {
					value = bind 'path_blog',
					enabled = bind 'putInSubfolder_blog',
					validate = LrFtp.ftpPathValidator,
					truncation = 'middle',
					immediate = true,
					fill_horizontal = 1,
				},
			},

			f:column {
				place = 'overlapping',
				fill_horizontal = 1,

				f:row {
					f:static_text {
						title = LOC "$$$/FtpUpload/ExportDialog/FullPath_blog=Full Path for Blog:",
						alignment = 'right',
						width = share 'labelWidth',
						visible = bind 'hasNoError',
					},

					f:static_text {
						fill_horizontal = 1,
						width_in_chars = 20,
						title = bind 'fullPath_blog',
						visible = bind 'hasNoError',
					},
				},

				f:row {
					f:static_text {
						fill_horizontal = 1,
						title = bind 'message',
						visible = bind 'hasError',
					},
				},
			},

			f:row {
				f:static_text {
					title = LOC "$$$/FtpUpload/ExportDialog/blog_author=Author:",
					alignment = 'right',
					width = share 'labelWidth',
					visible = bind 'hasNoError',
				},

				f:edit_field {
					value = bind 'blog_author',
					truncation = 'middle',
					immediate = true,
					fill_horizontal = 1,
				},
			},

			f:row {
				f:static_text {
					title = LOC "$$$/FtpUpload/ExportDialog/blog_title=Title:",
					alignment = 'right',
					width = share 'labelWidth',
					visible = bind 'hasNoError',
				},

				f:edit_field {
					value = bind 'blog_title',
					truncation = 'middle',
					immediate = true,
					fill_horizontal = 1,
				},
			},

			f:row {
				f:static_text {
					title = LOC "$$$/FtpUpload/ExportDialog/blog_tag=Tags:",
					alignment = 'right',
					width = share 'labelWidth',
					visible = bind 'hasNoError',
				},

				f:edit_field {
					value = bind 'blog_tag',
					truncation = 'middle',
					immediate = true,
					fill_horizontal = 1,
				},
			},

			f:row {
				f:static_text {
					title = LOC "$$$/FtpUpload/ExportDialog/blog_thumbsize=Thumbnail size:",
					alignment = 'right',
					width = share 'labelWidth',
					visible = bind 'hasNoError',
				},

				f:edit_field {
					value = bind 'blog_thumbsize',
					truncation = 'middle',
					immediate = true,
					fill_horizontal = 1,
				},
			},

			f:row {
				f:static_text {
					title = LOC "$$$/FtpUpload/ExportDialog/blog_text=Text:",
					alignment = 'right',
					width = share 'labelWidth',
					visible = bind 'hasNoError',
				},

				f:edit_field {
					value = bind 'blog_text',
					immediate = true,
					wraps = true,
					wrap = true,
					allow_newlines = true,
					height_in_lines = 5,
					fill_horizontal = 1,
				},
			},

		},
	}

	return result

end
