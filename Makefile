all:
	mkdir -p build
	cd build && voc -s \
		../UnixPlatform.Mod \
		../lDefs.Mod \
		../List.Mod \
		../strutils.Mod \
		../StringList.Mod \
		../git.Mod \
		../git2plot.Mod -m

clean:
	rm -rf build/*
