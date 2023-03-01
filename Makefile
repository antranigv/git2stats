all:
	mkdir -p build
	cd build && voc -s \
		../lDefs.Mod \
		../List.Mod \
		../strutils.Mod \
		../StringList.Mod \
		../git.Mod \
		../git2plot.Mod -m

clean:
	rm -rf build/*
