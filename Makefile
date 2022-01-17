all:
	Godot_v3.4.2-stable_mono_x11.64  --export BarClick_HTML
	Godot_v3.4.2-stable_mono_x11.64  --export BarClick_Linux
	Godot_v3.4.2-stable_mono_x11.64  --export BarClick_Android
	Godot_v3.4.2-stable_mono_x11.64  --export BarClick_Windows

edit:
	/home/user/data/19_Tools/Godot_v3.4.2-stable_mono_x11_64/Godot_v3.4.2-stable_mono_x11.64 -e --windowed --resolution 1920x1080 --position 0,0 .

clean:
	rm -f ./release/android/* ./release/windows/* ./release/linux/* ./release/html/*

.PHONY: all, edit, clean
