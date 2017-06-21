--[[----------------------------------------------------------------------------

FTP Upload for Yellow CMS, based on the Adobe Sample plugin (see below). Copyright
for the original part is by Adobe, rest of the code is under GPL.

FtpUploadTask.lua
Upload photos via Ftp

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

-- Lightroom API
local LrPathUtils = import 'LrPathUtils'
local LrFtp = import 'LrFtp'
local LrFileUtils = import 'LrFileUtils'
local LrErrors = import 'LrErrors'
local LrDialogs = import 'LrDialogs'

--============================================================================--

FtpUploadTask = {}

--------------------------------------------------------------------------------

function FtpUploadTask.processRenderedPhotos( functionContext, exportContext )

	-- Make a local reference to the export parameters.

	local exportSession = exportContext.exportSession
	local exportParams = exportContext.propertyTable
	local ftpPreset = exportParams.ftpPreset

	-- Set progress title.

	local nPhotos = exportSession:countRenditions()

	local progressScope = exportContext:configureProgress {
						title = nPhotos > 1
							   and LOC( "$$$/FtpUpload/Upload/Progress=Uploading ^1 photos via Ftp", nPhotos )
							   or LOC "$$$/FtpUpload/Upload/Progress/One=Uploading one photo via Ftp",
					}

	-- Create an FTP connection.

	if not LrFtp.queryForPasswordIfNeeded( ftpPreset ) then
		return
	end

	local ftpInstance = LrFtp.create( ftpPreset, true )

	if not ftpInstance then

		-- This really shouldn't ever happen.

		LrErrors.throwUserError( LOC "$$$/FtpUpload/Upload/Errors/InvalidFtpParameters=The specified FTP preset is incomplete and cannot be used." )
	end

	-- Ensure target directory exists.
	local image_path_end = ""
	local index = 0
		while true do

		local subPath = string.sub( exportParams.fullPath_image, 0, index )
		ftpInstance.path = subPath

		local exists = ftpInstance:exists( '' )

		if exists == false then
			local success = ftpInstance:makeDirectory( '' )

			if not success then

				-- This is a possible situation if permissions don't allow us to create directories.

				LrErrors.throwUserError( LOC "$$$/FtpUpload/Upload/Errors/CannotMakeDirectoryForUpload=Cannot upload because Lightroom could not create the destination directory." )
			end

		elseif exists == 'file' then

			-- Unlikely, due to the ambiguous way paths for directories get tossed around.

			LrErrors.throwUserError( LOC "$$$/FtpUpload/Upload/Errors/UploadDestinationIsAFile=Cannot upload to a destination that already exists as a file." )
		elseif exists == 'directory' then

			-- Excellent, it exists, do nothing here.

		else

			-- Not sure if this would every really happen.

			LrErrors.throwUserError( LOC "$$$/FtpUpload/Upload/Errors/CannotCheckForDestination=Unable to upload because Lightroom cannot ascertain if the target destination exists." )
		end

		if index == nil then
			break
		end

		index = string.find( exportParams.fullPath_image, "/", index + 1 )

	end


	ftpInstance.path = exportParams.fullPath_image

	-- Iterate through photo renditions.

	local failures = {}

	for _, rendition in exportContext:renditions{ stopIfCanceled = true } do

		-- Wait for next photo to render.

		local success, pathOrMessage = rendition:waitForRender()

		-- Check for cancellation again after photo has been rendered.

		if progressScope:isCanceled() then break end

		if success then

			local filename = LrPathUtils.leafName( pathOrMessage )

			local success = ftpInstance:putFile( pathOrMessage, filename )

			if not success then

				-- If we can't upload that file, log it.  For example, maybe user has exceeded disk
				-- quota, or the file already exists and we don't have permission to overwrite, or
				-- we don't have permission to write to that directory, etc....

				table.insert( failures, filename )
			end

			-- When done with photo, delete temp file. There is a cleanup step that happens later,
			-- but this will help manage space in the event of a large upload.

			LrFileUtils.delete( pathOrMessage )

		end

	end

-- get path where images are uploaded
str = exportParams.fullPath_image
for w in str:gmatch("([^/]+)") do image_path_end = w end

-- create a file for blog_tag
--blog_name = "d:\\Projects\\lightroom\\Lightroom SDK 6.0\\Plugins\\test.txt"
--blog_name = os.date("blog_%Y-%m-%d_" .. exportParams.blog_title)
blog_name = os.date("blog_%Y-%m-%d_"..exportParams.blog_title..".txt")
--file = io.open(blog_name, "w")
--file = io.open("d:\\Projects\\lightroom\\Lightroom SDK 6.0\\Plugins\\test.txt", "w")
--file = io.open(blog_name, "w")
-- create temp file

-- tmp_path = LrFileUtils.chooseUniqueFileName(".")
-- temp_name = tmp_path.."tmp.txt"

temp_name = os.tmpname ()
file = io.open(temp_name, "w")
file:write("---\n")
file:write("Title: ")
file:write(exportParams.blog_title)
file:write("\n")
file:write("Published: ")
file:write(os.date("%Y-%m-%d %X"))
file:write("\n")
--2016-12-10 09:00:00\n")
file:write("Author: ")
file:write(exportParams.blog_author)
file:write("\n")
file:write("Tag: ")
file:write(exportParams.blog_tag)
file:write("\n")
file:write("---\n")
file:write(exportParams.blog_text)
-- file:write("Your text here ... \n")
-- file:write("[--more--]\n")
-- file:write("The link to the pics\n")
file:write("[gallery ")
file:write(image_path_end)
file:write(" photoswipe ")
file:write(exportParams.blog_thumbsize)
file:write("]\n")
-- file:write(os.date("blog_%Y-%m-%d_"..exportParams.blog_title))
-- file:write("\n")
-- file:write(temp_name)
file:close()
-- change upload path
ftpInstance.path = exportParams.fullPath_blog
local filename = LrPathUtils.leafName( blog_name )
-- upload file to destination
local success = ftpInstance:putFile( temp_name, filename )

if not success then

	-- If we can't upload that file, log it.  For example, maybe user has exceeded disk
	-- quota, or the file already exists and we don't have permission to overwrite, or
	-- we don't have permission to write to that directory, etc....

	table.insert( failures, blog_name )
end

-- delete file
--a, b = os.remove (temp_name)
a,b = LrFileUtils.delete(temp_name)
-- file = io.open("d:\\Projects\\lightroom\\Lightroom SDK 6.0\\Plugins\\test.txt", "w")
-- file:write(temp_name)
-- file:write(a)
-- file:write(b)
-- file:close()

	ftpInstance:disconnect()

	if #failures > 0 then
		local message
		if #failures == 1 then
			message = LOC "$$$/FtpUpload/Upload/Errors/OneFileFailed=1 file failed to upload correctly."
		else
			message = LOC ( "$$$/FtpUpload/Upload/Errors/SomeFileFailed=^1 files failed to upload correctly.", #failures )
		end
		LrDialogs.message( message, table.concat( failures, "\n" ) )
	end

end
