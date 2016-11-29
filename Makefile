all: luci-app-filebrowser.ipk

luci-app-filebrowser.ipk:
	rm -rf ipk
	mkdir -p ipk/usr/lib/lua/luci/controller/
	mkdir -p ipk/usr/lib/lua/luci/view/
	cp luasrc/controller/* ipk/usr/lib/lua/luci/controller/
	cp luasrc/view/* ipk/usr/lib/lua/luci/view/
	tar czvf control.tar.gz control
	cd ipk; tar czvf ../data.tar.gz .; cd ..
	echo 2.0 > debian-binary
	ar r luci-app-filebrowser_`date +%Y%m%d`.ipk control.tar.gz data.tar.gz  debian-binary

clean:
	rm -rf ipk
	rm -f debian-binary
	rm -f control.tar.gz
	rm -f data.tar.gz
	rm -f luci-app-filebrowser.ipk
	