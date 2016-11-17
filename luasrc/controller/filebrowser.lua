module("luci.controller.filebrowser", package.seeall)

function index()

	page = entry({"admin", "system", "filebrowser"}, template("filebrowser"), _("File Browser"), 60)
	page.i18n = "base"
	page.dependent = true

	page = entry({"admin", "system", "filebrowser_list"}, call("filebrowser_list"), nil)
	page.leaf = true

	page = entry({"admin", "system", "filebrowser_open"}, call("filebrowser_open"), nil)
	page.leaf = true

end

function filebrowser_list()
	local fs = require "nixio.fs"
	local rv = { }
	local path = luci.http.formvalue("path")
	
    path = path:gsub(" ", "\\ ")
    rv = scandir(path)	

	if #rv > 0 then
		luci.http.prepare_content("application/json")
		luci.http.write_json(rv)
		return
	end

end

function filebrowser_open(file, filename)
	file = file:gsub("<>", "/")

	local io = require "io"
	local fs = require "nixio.fs"
	local http = require "luci.http"
	local ltn12 = require "luci.ltn12"
	local mime = to_mime(filename)

	local download_fpi = io.open(file, "r")
	luci.http.header('Content-Disposition', 'inline; filename="'..filename..'"' )
	luci.http.prepare_content(mime or "application/octet-stream")
	luci.ltn12.pump.all(luci.ltn12.source.file(download_fpi), luci.http.write)
end

function scandir(directory)
    local http = require "luci.http"
    local i, t, popen = 0, {}, io.popen
    
    local pfile = popen("ls -l "..directory.." | egrep '^d' ; ls -lh "..directory.." | egrep -v '^d'")
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

MIME_TYPES = {
    ["txt"]   = "text/plain";
    ["js"]    = "text/javascript";
    ["css"]   = "text/css";
    ["htm"]   = "text/html";
    ["html"]  = "text/html";
    ["patch"] = "text/x-patch";
    ["c"]     = "text/x-csrc";
    ["h"]     = "text/x-chdr";
    ["o"]     = "text/x-object";
    ["ko"]    = "text/x-object";

    ["bmp"]   = "image/bmp";
    ["gif"]   = "image/gif";
    ["png"]   = "image/png";
    ["jpg"]   = "image/jpeg";
    ["jpeg"]  = "image/jpeg";
    ["svg"]   = "image/svg+xml";

    ["zip"]   = "application/zip";
    ["pdf"]   = "application/pdf";
    ["xml"]   = "application/xml";
    ["xsl"]   = "application/xml";
    ["doc"]   = "application/msword";
    ["ppt"]   = "application/vnd.ms-powerpoint";
    ["xls"]   = "application/vnd.ms-excel";
    ["odt"]   = "application/vnd.oasis.opendocument.text";
    ["odp"]   = "application/vnd.oasis.opendocument.presentation";
    ["pl"]    = "application/x-perl";
    ["sh"]    = "application/x-shellscript";
    ["php"]   = "application/x-php";
    ["deb"]   = "application/x-deb";
    ["iso"]   = "application/x-cd-image";
    ["tgz"]   = "application/x-compressed-tar";

    ["mp3"]   = "audio/mpeg";
    ["ogg"]   = "audio/x-vorbis+ogg";
    ["wav"]   = "audio/x-wav";

    ["mpg"]   = "video/mpeg";
    ["mpeg"]  = "video/mpeg";
    ["avi"]   = "video/x-msvideo";
}

function to_mime(filename)
	if type(filename) == "string" then
		local ext = filename:match("[^%.]+$")

		if ext and MIME_TYPES[ext:lower()] then
			return MIME_TYPES[ext:lower()]
		end
	end

	return "application/octet-stream"
end