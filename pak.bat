haxe -hl hxd.fmt.pak.Build.hl -lib heaps -main hxd.fmt.pak.Build
hl hxd.fmt.pak.Build.hl -res "assets" -out "assets" -check-ogg -exclude-path "preloader"
haxe -hl hxd.fmt.pak.Build.hl -lib heaps -main hxd.fmt.pak.Build
hl hxd.fmt.pak.Build.hl -res "assets" -out "preload" -include-path "fonts,preloader"
copy assets.pak C:\Users\Nick\Documents\Projects\Haxe\CreatureCollab\export\js
copy preload.pak C:\Users\Nick\Documents\Projects\Haxe\CreatureCollab\export\js